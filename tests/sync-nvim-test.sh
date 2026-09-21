#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT
mkdir -p "$test_home/home" "$test_home/parent/bin"
# Isolate identity, configuration, and all writes. Only local Git transport is
# allowed; no test invokes --push or needs a hosted remote.
fixture_env=(env "HOME=$test_home/home" 'GIT_CONFIG_NOSYSTEM=1'
    'GIT_CONFIG_GLOBAL=/dev/null' 'GIT_ALLOW_PROTOCOL=file'
    'GIT_AUTHOR_NAME=Sync test' 'GIT_AUTHOR_EMAIL=sync@example.invalid'
    'GIT_COMMITTER_NAME=Sync test' 'GIT_COMMITTER_EMAIL=sync@example.invalid'
    "GIT_TRACE=$test_home/git.trace")
git_fixture() { "${fixture_env[@]}" git "$@"; }
parent="$test_home/parent"
nvim="$parent/modules/nvim"
upstream="$test_home/upstream"
sync_nvim() { "${fixture_env[@]}" "$parent/bin/sync-nvim" "$@"; }
expect_refusal() {
    local message=$1
    if sync_nvim > "$test_home/refusal" 2>&1; then
        fail "Sync unexpectedly accepted: $message"
    fi
    grep -Fq -- "$message" "$test_home/refusal" || {
        cat "$test_home/refusal"
        fail "Missing refusal: $message"
    }
    cat "$test_home/refusal"
}

git_fixture init -q -b main "$upstream"
printf 'initial\n' > "$upstream/config.txt"
git_fixture -C "$upstream" add config.txt
git_fixture -C "$upstream" commit -qm initial
git_fixture init -q -b main "$parent"
cp -- "$repo_dir/bin/sync-nvim" "$parent/bin/sync-nvim"
git_fixture -C "$parent" submodule add -q -b main "$upstream" modules/nvim
git_fixture -C "$parent" add bin/sync-nvim
git_fixture -C "$parent" commit -qm initial
original_parent=$(git_fixture -C "$parent" rev-parse HEAD)
original_nvim=$(git_fixture -C "$nvim" rev-parse HEAD)

sync_nvim > "$test_home/no-change" 2>&1
grep -q 'No change:' "$test_home/no-change" || fail 'No-op was not reported'
[[ $(git_fixture -C "$parent" rev-parse HEAD) == "$original_parent" ]] || fail 'No-op created a commit'
printf 'PASS: unchanged upstream exits 0 without a parent commit.\n'

printf 'upstream update\n' >> "$upstream/config.txt"
git_fixture -C "$upstream" commit -qam update
updated=$(git_fixture -C "$upstream" rev-parse HEAD)
sync_nvim --dry-run
[[ $(git_fixture -C "$nvim" rev-parse HEAD) == "$original_nvim" ]] || fail 'Dry-run moved HEAD'
[[ $(git_fixture -C "$nvim" rev-parse origin/main) == "$original_nvim" ]] || fail 'Dry-run fetched'
[[ $(git_fixture -C "$parent" rev-parse HEAD) == "$original_parent" ]] || fail 'Dry-run committed'
printf 'PASS: dry-run neither fetches nor moves either repository.\n'

printf 'work in progress\n' > "$nvim/untracked.txt"
expect_refusal 'has uncommitted changes'
rm -- "$nvim/untracked.txt"
printf 'local edit\n' >> "$nvim/config.txt"
expect_refusal 'has uncommitted changes'
git_fixture -C "$nvim" add config.txt
expect_refusal 'has uncommitted changes'
git_fixture -C "$nvim" restore --staged --worktree config.txt
printf 'PASS: untracked, unstaged, and staged submodule work is refused.\n'

git_fixture -C "$nvim" checkout -qb work-in-progress
expect_refusal "on branch 'work-in-progress'"
git_fixture -C "$nvim" checkout -q --detach
expect_refusal 'has a detached HEAD'
git_fixture -C "$nvim" checkout -q main
printf 'PASS: another branch and detached HEAD are refused.\n'

printf 'unrelated parent work\n' > "$parent/unrelated.txt"
git_fixture -C "$parent" add unrelated.txt
expect_refusal 'parent repository has staged changes'
[[ $(git_fixture -C "$parent" show :unrelated.txt) == 'unrelated parent work' ]] || fail 'Staged work changed'
git_fixture -C "$parent" restore --staged unrelated.txt
# Keep unrelated untracked work present during a successful sync.
sync_nvim > "$test_home/updated" 2>&1
[[ $(git_fixture -C "$nvim" rev-parse HEAD) == "$updated" ]] || fail 'Submodule did not fast-forward'
[[ $(git_fixture -C "$parent" rev-parse HEAD:modules/nvim) == "$updated" ]] || fail 'Pointer not committed'
[[ $(git_fixture -C "$parent" show --format= --name-only HEAD) == modules/nvim ]] || fail 'Commit includes unrelated work'
short_sha=$(git_fixture -C "$nvim" rev-parse --short HEAD)
[[ $(git_fixture -C "$parent" log -1 --format=%s) == "Update nvim submodule to $short_sha" ]] || fail 'Commit message lacks SHA'
[[ $(cat "$parent/unrelated.txt") == 'unrelated parent work' ]] || fail 'Unrelated work changed'
printf 'PASS: fast-forward records only modules/nvim with its new SHA; unrelated parent work is preserved.\n'

printf 'local commit\n' >> "$nvim/config.txt"
git_fixture -C "$nvim" commit -qam local
local_head=$(git_fixture -C "$nvim" rev-parse HEAD)
expect_refusal 'unpublished or divergent commits'
[[ $(git_fixture -C "$nvim" rev-parse HEAD) == "$local_head" ]] || fail 'Local commit was moved'
printf 'different upstream commit\n' >> "$upstream/config.txt"
git_fixture -C "$upstream" commit -qam diverge
expect_refusal 'unpublished or divergent commits'
[[ $(git_fixture -C "$nvim" rev-parse HEAD) == "$local_head" ]] || fail 'Divergent local commit was moved'
[[ $(git_fixture -C "$parent" rev-parse HEAD:modules/nvim) == "$updated" ]] || fail 'Refusal changed parent pointer'
printf 'PASS: ahead and divergent local commits remain intact.\n'

if grep -q 'built-in: git push' "$test_home/git.trace"; then
    fail 'Sync attempted a push without --push'
fi
printf 'PASS: sync-nvim tests; Git trace confirms no push command.\n'
