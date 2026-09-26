#!/usr/bin/env bash
# shellcheck disable=SC2016 # Single-quoted programs are evaluated by child Zsh.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
for tool in bwrap zsh git python3 sort tar nvim wget; do
    command -v "$tool" >/dev/null || fail "Required test tool is missing: $tool"
done
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/repo" "$fixture/logs"

# Derive the writable fixture from the real link manifest. Dotbot's bundled
# safe YAML loader avoids a host package dependency. Sources must stay relative
# to the repository; environment expansion and globs would weaken that bound.
if ! PYTHONPATH="$repo_dir/modules/dotbot/lib/pyyaml/lib" \
    python3 - "$repo_dir/install.conf.yaml" > "$fixture/link-sources" <<'PY'
from pathlib import Path, PurePosixPath
import os
import sys

import yaml

manifest_path = Path(sys.argv[1])
try:
    manifest = yaml.safe_load(manifest_path.read_text(encoding='utf-8'))
except Exception as error:
    raise SystemExit(f'FAIL: cannot read {manifest_path.name}: {error}') from error
if not isinstance(manifest, list):
    raise SystemExit(f'FAIL: {manifest_path.name} must contain a list of directives')

default_glob = False
sources = []
for directive in manifest:
    if not isinstance(directive, dict):
        raise SystemExit(f'FAIL: invalid directive in {manifest_path.name}: {directive!r}')
    defaults = directive.get('defaults')
    if isinstance(defaults, dict) and isinstance(defaults.get('link'), dict):
        default_glob = bool(defaults['link'].get('glob', default_glob))
    links = directive.get('link')
    if links is None:
        continue
    if not isinstance(links, dict):
        raise SystemExit(f'FAIL: link directive in {manifest_path.name} must be a mapping')
    for destination, spec in links.items():
        use_glob = default_glob
        if isinstance(spec, str):
            source = spec
        elif spec is None and isinstance(destination, str):
            basename = os.path.basename(destination)
            source = basename[1:] if basename.startswith('.') else basename
        elif isinstance(spec, dict):
            source = spec.get('path')
            use_glob = bool(spec.get('glob', use_glob))
            if source is None and isinstance(destination, str):
                basename = os.path.basename(destination)
                source = basename[1:] if basename.startswith('.') else basename
        else:
            source = None
        if not isinstance(source, str) or not source:
            raise SystemExit(
                f'FAIL: {manifest_path.name} link {destination!r} has no usable source'
            )
        path = PurePosixPath(source)
        unsafe = (
            path.is_absolute()
            or path == PurePosixPath('.')
            or '..' in path.parts
            or source.startswith('~')
            or '$' in source
        )
        if unsafe:
            raise SystemExit(
                f'FAIL: {manifest_path.name} link source escapes the tracked fixture: {source}'
            )
        if use_glob:
            raise SystemExit(
                f'FAIL: {manifest_path.name} link source uses an unsupported fixture glob: {source}'
            )
        lowered = source.lower()
        if path.parts[0] == 'Documents' or ('secret' in lowered and 'env' in lowered):
            raise SystemExit(f'FAIL: forbidden fixture link source: {source}')
        if source not in sources:
            sources.append(source)

sys.stdout.buffer.write(b''.join(os.fsencode(source) + b'\0' for source in sources))
PY
then
    fail 'could not derive fixture inputs from install.conf.yaml'
fi

mapfile -d '' -t link_sources < "$fixture/link-sources"
((${#link_sources[@]})) || fail 'install.conf.yaml has no link sources'
tracked_inputs="$fixture/tracked-inputs"
source_inputs="$fixture/source-inputs"
printf 'install.conf.yaml\0bin/configure-tools\0config/codespell/codespellrc\0' > "$tracked_inputs"
pathspec_excludes=(
    ':(exclude,glob)**/*secret*env*' ':(exclude,glob)*secret*env*'
    ':(exclude,glob)**/*SECRET*ENV*' ':(exclude,glob)*SECRET*ENV*'
    ':(exclude)Documents' ':(exclude,glob)Documents/**'
)
for source in "${link_sources[@]}"; do
    if ! git -C "$repo_dir" ls-files --recurse-submodules -z -- \
        "$source" "${pathspec_excludes[@]}" > "$source_inputs"; then
        fail "could not enumerate tracked fixture source: $source"
    fi
    [[ -s $source_inputs ]] ||
        fail "install.conf.yaml link source is not provided by tracked repository files: $source"
    cat "$source_inputs" >> "$tracked_inputs"
done
LC_ALL=C sort -zu "$tracked_inputs" > "$fixture/tracked-inputs-sorted"

# Only manifest-selected, Git-tracked paths cross into the writable fixture.
# No host HOME is mounted, and tar never recurses into untracked directory data.
tar -C "$repo_dir" --null --verbatim-files-from --no-recursion \
    --files-from="$fixture/tracked-inputs-sorted" -cf - |
    tar -C "$fixture/repo" -xf -

# Git-aware shell configuration must see the pinned identities of selected
# submodules. Mount their pointer files read-only; do not copy metadata into the
# writable fixture or expose submodules unrelated to manifest link sources.
if ! git -C "$repo_dir" submodule foreach --recursive --quiet \
    'printf "%s\0" "$displaypath"' > "$fixture/submodule-paths"; then
    fail 'could not enumerate repository submodules'
fi
mapfile -d '' -t submodule_paths < "$fixture/submodule-paths"

sandbox=(bwrap --die-with-parent --unshare-pid)
for runtime in /usr /bin /lib /lib64 /etc; do
    [[ ! -d $runtime ]] || sandbox+=(--ro-bind "$runtime" "$runtime")
done
sandbox+=(--proc /proc --dev /dev --bind "$fixture" "$fixture"
    --ro-bind "$repo_dir/.git" "$fixture/repo/.git"
    --ro-bind "$repo_dir/modules/dotbot" "$fixture/repo/modules/dotbot")
for submodule in "${submodule_paths[@]}"; do
    selected=false
    for source in "${link_sources[@]}"; do
        if [[ $submodule == "$source" || $submodule == "$source/"* ]]; then
            selected=true
            break
        fi
    done
    if [[ $selected == true ]]; then
        [[ -e $repo_dir/$submodule/.git ]] ||
            fail "selected submodule has no Git pointer: $submodule"
        sandbox+=(--ro-bind "$repo_dir/$submodule/.git" \
            "$fixture/repo/$submodule/.git")
    fi
done
sandbox+=(--chdir "$fixture" --remount-ro / -- /usr/bin/env -i
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
# Only installer-owned locations may precede the inherited PATH. The link
# manifest creates BIN_PATH; `install runtimes` creates the shims later, so a
# fresh link-only install must not require the shims directory to exist yet.
expected_startup_path_prefix=("$ASDF_DATA_DIR/shims" "$BIN_PATH")
for (( index = 1; index <= $#expected_startup_path_prefix; index++ )); do
  [[ $path[index] == $expected_startup_path_prefix[index] ]] || {
    print -u2 -r -- "EXPECTED PATH PREFIX: ${(j.:.)expected_startup_path_prefix}" "ACTUAL PATH: $PATH"
    fail "startup PATH entry $index differs"
  }
done
for entry in "${path[@]}"; do
  [[ $entry != "$BIN_PATH/usr" ]] || fail 'BIN_PATH/usr is present in startup PATH'
done
unique_startup_path=("${path[@]}")
typeset -U unique_startup_path
(( $#path == $#unique_startup_path )) || fail 'duplicate entries in startup PATH'
[[ -d $BIN_PATH ]] || fail 'BIN_PATH was not created by the link manifest'
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
    # install link runs configure-tools after linking.  Start from the corrupt
    # first-login state seen on the acceptance VM and require the installer to
    # replace it before any real interactive login can read it.
    printf 'not a compiled zsh dump\n' > "$cache/zsh/.zcompdump.zwc"
    if ! "${sandbox[@]}" "${env_args[@]}" "$fixture/repo/bin/configure-tools" \
        > "$fixture/logs/configure-$layout" 2>&1; then
        cat "$fixture/logs/configure-$layout"
        fail 'configure-tools completion warm-up'
    fi
    if grep -Fq 'invalid zwc file' "$fixture/logs/configure-$layout"; then
        cat "$fixture/logs/configure-$layout"
        fail 'configure-tools read the invalid completion cache'
    fi
    [[ -s $cache/zsh/.zcompdump && -s $cache/zsh/.zcompdump.zwc ]] ||
        fail 'configure-tools did not warm the completion cache'
    zsh -fc 'zcompile -t "$1"' shell-test "$cache/zsh/.zcompdump.zwc" \
        > "$fixture/logs/zcompile-$layout" 2>&1 || {
        cat "$fixture/logs/zcompile-$layout"
        fail 'configure-tools produced an invalid compiled completion cache'
    }
    completion_stat=$(stat -c '%i:%Y:%s' "$cache/zsh/.zcompdump" "$cache/zsh/.zcompdump.zwc")
    "${sandbox[@]}" "${env_args[@]}" "$fixture/repo/bin/configure-tools" \
        > "$fixture/logs/configure-again-$layout" 2>&1 ||
        fail 'configure-tools second completion warm-up'
    completion_stat_after=$(stat -c '%i:%Y:%s' "$cache/zsh/.zcompdump" "$cache/zsh/.zcompdump.zwc")
    if [[ $completion_stat != "$completion_stat_after" ]]; then
        printf 'BEFORE: %s\nAFTER: %s\n' "$completion_stat" "$completion_stat_after" >&2
        fail 'configure-tools rewrote a valid completion cache'
    fi
    printf 'PASS: %s installer replaces an invalid completion cache and is idempotent.\n' "$layout"
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
