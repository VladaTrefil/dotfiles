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
sway -C -c "$repo_dir/config/sway/config"
sway -C -c "$repo_dir/config/sway/config.virtualbox"
python3 "$repo_dir/tests/sway-checks.py"
