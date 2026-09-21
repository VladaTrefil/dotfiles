#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd -- "$repo_dir"

lint_shell() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        printf 'SKIP: shellcheck is not on PATH; shell lint was not run.\n'
        return
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
# Add independent config checks here as their application blocks land:
# lint_sway (sway -C), lint_zsh (zsh -n), etc.
