#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd -- "$repo_dir"
test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT
export HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config"
export XDG_CACHE_HOME="$test_home/.cache" XDG_STATE_HOME="$test_home/.local/state"
export XDG_DATA_HOME="$test_home/.local/share"

lint_shell() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        printf 'FAIL: shellcheck is required (Fedora: ShellCheck).\n' >&2
        return 1
    fi

    local path first_line
    local -a scripts=()
    # Git enumerates this repo's files without traversing third-party submodules.
    # Include untracked scripts so a new migration block is checked before commit.
    while IFS= read -r -d '' path; do
        [[ -f $path && ! -L $path ]] || continue
        case "$path" in
            *.sh|*.bash|*.ksh) scripts+=("$path") ;;
            *)
                first_line=''
                IFS= read -r first_line < "$path" || true
                if [[ $first_line =~ ^\#!.*[/[:space:]](ba|da|k)?sh([[:space:]]|$) ]]; then
                    scripts+=("$path")
                fi
                ;;
        esac
    done < <(git ls-files -z --cached --others --exclude-standard -- . \
        ':(exclude,glob)**/*secret*env*' ':(exclude,glob)*secret*env*' \
        ':(exclude,glob)**/*SECRET*ENV*' ':(exclude,glob)*SECRET*ENV*')

    if ((${#scripts[@]})); then
        printf 'ShellCheck: %s\n' "$(command -v shellcheck)"
        printf '  %s\n' "${scripts[@]}"
        shellcheck -- "${scripts[@]}"
        printf 'PASS: shellcheck (%s scripts).\n' "${#scripts[@]}"
    else
        printf 'SKIP: no repository-owned shell scripts found.\n'
    fi
}

lint_shell
# ShellCheck does not support Zsh; parse our startup/config files with Zsh.
for path in config/zsh/.zshenv config/zsh/.zprofile config/zsh/.zshrc config/zsh/p10k.zsh; do
    env -i HOME=/nonexistent PATH=/usr/bin:/bin zsh -dfn "$path"
done
shellcheck -s sh config/shell/profile
printf 'PASS: portable profile lint and Zsh syntax (4 files).\n'
if ! command -v sway >/dev/null 2>&1; then
    printf 'FAIL: sway is required for config validation.\n' >&2
    exit 1
fi
# `sway -C` still initialises a wlroots backend, so without these it fails on any
# machine with no seat (SSH, CI) for reasons unrelated to the config. A headless
# backend plus software rendering lets the parser run anywhere; verified that it
# still reports real errors (unknown directives, bad keysyms) under these settings.
sway_check() {
    local config="$1" log status
    log=$(mktemp)
    WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
    WLR_RENDERER_ALLOW_SOFTWARE=1 LIBGL_ALWAYS_SOFTWARE=1 \
        sway -C -c "$config" >"$log" 2>&1 || true
    # sway -C exits 0 even on config errors, so match the parser's own messages and
    # ignore backend/renderer noise, which says nothing about config validity.
    if grep -qE '\[sway/config\.c:[0-9]+\] Error' "$log"; then
        printf 'FAIL: sway config errors in %s\n' "$config" >&2
        grep -E '\[sway/config\.c:[0-9]+\] Error' "$log" >&2
        status=1
    else
        status=0
    fi
    rm -f "$log"
    return "$status"
}
sway_check "$repo_dir/config/sway/config"
sway_check "$repo_dir/config/sway/config.virtualbox"
printf 'PASS: sway config parses (both entry points).\n'
python3 "$repo_dir/tests/sway-checks.py"
python3 "$repo_dir/tests/sway-bindings.py"
python3 "$repo_dir/tests/eww-checks.py"
python3 "$repo_dir/tests/font-families.py"
