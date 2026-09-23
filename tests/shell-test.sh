#!/usr/bin/env bash
# shellcheck disable=SC2016 # Single-quoted programs are evaluated by child Zsh.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
for tool in bwrap zsh git python3 tar nvim wget; do
    command -v "$tool" >/dev/null || fail "Required test tool is missing: $tool"
done
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/repo/modules/nvim" "$fixture/logs"
# Only named public shell inputs cross into the writable fixture. No host HOME
# is mounted. The copied .git pointers resolve through read-only Git metadata.
tar -C "$repo_dir" --exclude='*secret*env*' --exclude='*SECRET*ENV*' \
    --exclude=Documents --exclude=work.sh -cf - \
    config/shell/profile config/shell/aliases.sh config/shell/inputrc \
    config/zsh config/git config/wgetrc install.conf.yaml \
    config/asdf config/stylelint config/stylua config/rubocop config/solargraph \
    config/codespell config/npm config/pry config/bat config/lazygit config/pylintrc \
    config/sway config/eww config/qt6ct config/qt-palette config/rofi config/dunst \
    config/kitty config/gtk-3.0 config/gtk-4.0 config/environment.d \
    config/mimeapps.list config/compose |
    tar -C "$fixture/repo" -xf -

sandbox=(bwrap --die-with-parent --unshare-pid)
for runtime in /usr /bin /lib /lib64 /etc; do
    [[ ! -d $runtime ]] || sandbox+=(--ro-bind "$runtime" "$runtime")
done
sandbox+=(--proc /proc --dev /dev --bind "$fixture" "$fixture"
    --ro-bind "$repo_dir/.git" "$fixture/repo/.git"
    --ro-bind "$repo_dir/modules/dotbot" "$fixture/repo/modules/dotbot"
    --chdir "$fixture" --remount-ro / -- /usr/bin/env -i
    'PATH=/usr/bin:/bin' 'TERM=xterm-256color' 'LANG=C.UTF-8'
    'GIT_CONFIG_NOSYSTEM=1' 'GIT_TERMINAL_PROMPT=0'
    'PYTHONDONTWRITEBYTECODE=1')

snapshot() {
    python3 - "$fixture/repo" <<'PY'
import hashlib
import json
import os
from pathlib import Path
import sys

root = Path(sys.argv[1])
rows = []
for directory, dirs, files in os.walk(root):
    # These are read-only mounts, not fixture working-tree inputs.
    dirs[:] = sorted(d for d in dirs if d not in {'.git', 'modules'})
    for name in sorted(dirs + files):
        path = Path(directory) / name
        info = path.lstat()
        rows.append((str(path.relative_to(root)), info.st_mode, info.st_size,
                     info.st_mtime_ns, info.st_ctime_ns,
                     hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None))
print(json.dumps(rows))
PY
}

# Tests use an actual blank environment: no inherited ZDOTDIR or shell profile.
cat > "$fixture/check.zsh" <<'ZSH'
fail() { print -u2 -r -- "FAIL: $*"; exit 1; }
[[ $ZDOTDIR == $XDG_CONFIG_HOME/zsh ]] || fail 'wrong ZDOTDIR'
[[ $EDITOR == nvim && $TERMINAL == kitty && $BROWSER == chromium ]] || fail 'profile missing'
[[ $ZSH == $ZDOTDIR/oh-my-zsh && $ZSH_CUSTOM == $ZDOTDIR/custom ]] || fail 'framework paths'
(( $+functions[_zsh_autosuggest_start] && $+functions[_zsh_highlight] && $+functions[p10k] )) || fail 'plugins/theme missing'
[[ -o sharehistory && ! -o incappendhistorytime && ! -o incappendhistory ]] || fail 'history options'
[[ $path[1] == $ASDF_DATA_DIR/shims ]] || fail 'shims are not first'
[[ ! -v ASDF_DIR && ! -v NVM_DIR && ! -v GOPATH && ! -v ASDF_DEFAULT_TOOL_VERSIONS_FILENAME ]] || fail 'legacy environment'
[[ ! -v XINITRC && ! -v KDEHOME && ! -v GTK2_RC_FILES && ! -v THEME_BACKGROUND ]] || fail 'desktop environment'
[[ $BUNDLE_USER_CONFIG == $XDG_CONFIG_HOME/bundle/config && -d ${BUNDLE_USER_CONFIG:h} ]] || fail 'Bundler config path'
[[ ! -e $XDG_CONFIG_HOME/shell/work.sh && ! -e $XDG_CONFIG_HOME/dotfiles-private/login.sh ]] || fail 'optional fixture unexpectedly exists'
[[ $ZSH_COMPDUMP == $XDG_CACHE_HOME/zsh/.zcompdump && -s $ZSH_COMPDUMP ]] || fail 'completion cache'
[[ $__p9k_root_dir == $XDG_CACHE_HOME/zsh/powerlevel10k-* ]] || fail 'theme cache'

# A failed mkdir and a failed cd must both return to the same shell.
mkdir() { return 17; }
mkcd "$HOME/no-directory"
[[ $? == 17 ]] || fail 'mkcd lost mkdir failure'
mkdir() { return 0; }
cd() { return 19; }
mkcd "$HOME/no-directory"
[[ $? == 19 ]] || fail 'mkcd lost cd failure'
unfunction mkdir cd
mkcd "$HOME/new directory" || fail 'mkcd success'
[[ $PWD == "$HOME/new directory" ]] || fail 'mkcd did not cd'
mkcd "$HOME/new directory" 2> "$HOME/expected-mkdir-error"
[[ $? != 0 ]] || fail 'mkcd unexpectedly accepts an existing directory'
print 'PASS: mkcd failures return nonzero; shell survives; new directory works.'

git init -q "$HOME/git fixture" || fail 'git init'
builtin cd "$HOME/git fixture"
git -c user.name=Test -c user.email=test@example.invalid commit -qm fixture --allow-empty || fail 'git commit'
editor=$(git config --get core.editor)
[[ -n $editor && -x ${commands[$editor]} ]] || fail 'Git editor does not resolve'
print -r -- "EDITOR: $editor -> ${commands[$editor]}"
for graph in gr gra grd grad; do
  git --no-pager "$graph" -1 > "$HOME/log-$graph" || fail "git $graph"
  [[ -s $HOME/log-$graph ]] || fail "empty git $graph"
done
git check-ignore --no-index .tool-versions >/dev/null
[[ $? == 1 ]] || fail 'global tool-versions ignore remains'
git check-ignore --no-index example.log >/dev/null || fail 'XDG global ignore not found'
command mkdir -p child
builtin cd child
cdgr || fail 'cdgr in repository'
[[ $PWD == "$HOME/git fixture" ]] || fail 'cdgr wrong root'
builtin cd "$HOME"
cdgr 2> "$HOME/expected-cdgr-error"
[[ $? != 0 && $PWD == "$HOME" ]] || fail 'cdgr outside repository'
print 'PASS: Git editor, four graph aliases, XDG ignore and cdgr.'

# Stub the clipboard transport; never contact a real compositor.
wl-copy() { command cat > "$HOME/clipboard-result"; }
printf 'binary\000clipboard\377\n' > "$HOME/clipboard-input"
clip "$HOME/clipboard-input" || fail 'clip file'
command cmp "$HOME/clipboard-input" "$HOME/clipboard-result" || fail 'clip file bytes'
command cat "$HOME/clipboard-input" | clip
command cmp "$HOME/clipboard-input" "$HOME/clipboard-result" || fail 'clip stdin bytes'
unfunction wl-copy
print 'PASS: clip preserves file and stdin bytes through wl-copy.'

# A nested shell inherits ZDOTDIR/PATH; loading again must not duplicate PATH.
expected_path=$PATH
actual_path=$(zsh -ic 'print -r -- "$PATH"') || fail 'nested interactive shell'
[[ $expected_path == $actual_path ]] || { print -r -- "EXPECTED: $expected_path" "ACTUAL: $actual_path"; fail 'PATH is not idempotent'; }
if (( $+commands[asdf] )); then
  print -r -- "ASDF: executable available at $commands[asdf]; not invoked during startup."
else
  print 'ASDF: absent; startup and shims PATH work silently.'
fi
print 'PASS: shell startup, optional-file guards, history, environment and cache.'
ZSH

for layout in default inherited; do
    test_home="$fixture/$layout home"
    mkdir -p "$test_home"
    config="$test_home/.config"
    cache="$test_home/.cache"
    data="$test_home/.local/share"
    state="$test_home/.local/state"
    env_args=("HOME=$test_home" "TMPDIR=$test_home")
    if [[ $layout == inherited ]]; then
        config="$test_home/custom config"; cache="$test_home/custom cache"
        data="$test_home/custom data"; state="$test_home/custom state"
        env_args+=("XDG_CONFIG_HOME=$config" "XDG_CACHE_HOME=$cache"
            "XDG_DATA_HOME=$data" "XDG_STATE_HOME=$state"
            "ASDF_DATA_DIR=$test_home/custom asdf")
    fi
    # Use the real manifest; explicit defaults mimic install's normalization.
    "${sandbox[@]}" "HOME=$test_home" "XDG_CONFIG_HOME=$config" \
        "XDG_CACHE_HOME=$cache" "XDG_DATA_HOME=$data" "XDG_STATE_HOME=$state" \
        "$fixture/repo/modules/dotbot/bin/dotbot" --base-directory "$fixture/repo" \
        --config-file "$fixture/repo/install.conf.yaml" --no-color \
        > "$fixture/logs/link-$layout" 2>&1 || { cat "$fixture/logs/link-$layout"; fail 'fixture links'; }
    revision=$(git -C "$repo_dir/config/zsh/custom/themes/powerlevel10k" rev-parse HEAD)
    theme_cache="$cache/zsh/powerlevel10k-$revision"
    mkdir -p "$theme_cache"
    git -C "$repo_dir/config/zsh/custom/themes/powerlevel10k" archive HEAD | tar -xf - -C "$theme_cache"
    # No gitstatus provisioning: the config sets POWERLEVEL9K_DISABLE_GITSTATUS=true so
    # p10k uses its pure-zsh git backend. Running p10k's installer here would fetch an
    # unpinned prebuilt binary from GitHub - the behaviour this configuration removes.
    if [[ -e "$cache/gitstatus" ]]; then
        fail 'gitstatus cache created; the runtime binary download was not disabled'
    fi
    snapshot > "$fixture/logs/before-$layout"
    for mode in -ic -lic; do
        # Each probe needs a fresh HOME-local new-directory success case.
        rm -rf -- "$test_home/new directory"
        if ! "${sandbox[@]}" "${env_args[@]}" zsh "$mode" \
            'source "$1"' shell-test "$fixture/check.zsh" \
            > "$fixture/logs/out" 2> "$fixture/logs/err"; then
            cat "$fixture/logs/out" "$fixture/logs/err"
            fail "$layout $mode"
        fi
        cat "$fixture/logs/out"
        [[ ! -s $fixture/logs/err ]] || { cat "$fixture/logs/err"; fail 'startup stderr is not empty'; }
        printf 'PASS: %s HOME with spaces, zsh %s; stderr = 0 bytes.\n' "$layout" "$mode"
    done
    # Login scripts get the environment without requiring an interactive shell.
    "${sandbox[@]}" "${env_args[@]}" zsh -lc '[[ $EDITOR == nvim && -n $ASDF_DATA_DIR ]]' \
        > "$fixture/logs/out" 2> "$fixture/logs/err" || fail 'noninteractive login'
    [[ ! -s $fixture/logs/err ]] || fail 'noninteractive login stderr'
    "${sandbox[@]}" "${env_args[@]}" zsh -c '[[ $ZDOTDIR == $XDG_CONFIG_HOME/zsh && ! -v ZSH ]]' \
        > "$fixture/logs/out" 2> "$fixture/logs/err" || fail 'minimal noninteractive environment'
    [[ ! -s $fixture/logs/err ]] || fail 'noninteractive stderr'
    # Render a real first prompt too: p10k's deferred initialization runs here,
    # whereas -ic alone would only register its hooks.
    python3 - "$fixture/logs" "$test_home" "${sandbox[@]}" "${env_args[@]}" zsh -i <<'PY'
import errno
import fcntl
import os
from pathlib import Path
import pty
import select
import subprocess
import sys
import termios
import time

logs = Path(sys.argv[1])
marker = Path(sys.argv[2]) / 'pty-ran'
master, slave = pty.openpty()
def session():
    os.setsid()
    fcntl.ioctl(slave, termios.TIOCSCTTY, 0)

with (logs / 'pty-stderr').open('wb') as errors:
    child = subprocess.Popen(sys.argv[3:], stdin=slave, stdout=slave, stderr=errors, preexec_fn=session)
os.close(slave)
os.write(master, b'print -r -- B1B_PTY_READY > "$HOME/pty-ran"\nexit\n')
output = bytearray()
deadline = time.monotonic() + 30
while time.monotonic() < deadline:
    if select.select([master], [], [], 0.1)[0]:
        try:
            chunk = os.read(master, 65536)
        except OSError as error:
            if error.errno == errno.EIO:
                break
            raise
        if not chunk:
            break
        output.extend(chunk)
    elif child.poll() is not None:
        break
else:
    child.kill()
    raise SystemExit('FAIL: real-terminal startup timed out')
os.close(master)
status = child.wait(timeout=5)
(logs / 'pty-output').write_bytes(output)
errors = (logs / 'pty-stderr').read_bytes()
if status or errors or not marker.exists() or marker.read_text() != 'B1B_PTY_READY\n':
    sys.stdout.buffer.write(output)
    sys.stderr.buffer.write(errors)
    raise SystemExit(f'FAIL: real-terminal startup (exit {status}, stderr {len(errors)} bytes)')
print('PASS: real-terminal first prompt rendered and ran a command; stderr = 0 bytes.')
PY
    # Wget must parse the concrete tilde path rather than a quoted $XDG value.
    printf '# HSTS 1.0 Known Hosts database for GNU Wget.\n' > "$test_home/.cache/wget-hsts"
    "${sandbox[@]}" "${env_args[@]}" zsh -lc \
        'wget --debug --spider --tries=1 --timeout=1 http://127.0.0.1:1' \
        > "$fixture/logs/wget-out" 2> "$fixture/logs/wget-err" && fail 'unexpected loopback server'
    grep -Fq "Reading HSTS entries from $test_home/.cache/wget-hsts" "$fixture/logs/wget-err" || {
        cat "$fixture/logs/wget-err"
        fail 'Wget did not expand the HSTS cache path'
    }
    printf 'PASS: %s Wget reads HSTS from the expanded ~/.cache/wget-hsts path.\n' "$layout"
    snapshot > "$fixture/logs/after-$layout"
    cmp -s "$fixture/logs/before-$layout" "$fixture/logs/after-$layout" || fail 'startup changed the repository tree'
    printf 'PASS: %s noninteractive modes; repository bytes, paths and metadata unchanged.\n' "$layout"
done

printf 'PASS: shell-test; all runtime writes confined to temporary HOME.\n'
