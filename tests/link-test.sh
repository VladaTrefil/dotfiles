#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
trap 'printf "FAIL: unexpected error at line %s\n" "$LINENO" >&2' ERR
for tool in bwrap git python3 tar timeout; do
    command -v "$tool" >/dev/null || fail "Required test tool is missing: $tool"
done

test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT
mkdir -p "$test_home/repo" "$test_home/tmp" "$test_home/logs"
# Keep scaffold edits, but copy neither Git metadata nor submodule contents.
# A fresh index below records only the gitlink SHAs, never their objects.
# Never copy excluded secret files, even if a later block adds local ones.
tar -C "$repo_dir" --exclude='*secret*env*' --exclude='*SECRET*ENV*' \
    --exclude=Documents --exclude=.state --exclude=.cache --exclude=__pycache__ \
    --exclude=.git --exclude=./modules \
    -cf - . | tar -C "$test_home/repo" -xf -

# No real HOME or its config is mounted. Only the fixture is writable; even
# /tmp outside the fixture belongs to the read-only sandbox root.
sandbox=(bwrap --die-with-parent)
for runtime in /usr /bin /lib /lib64; do
    if [[ -d $runtime ]]; then
        sandbox+=(--ro-bind "$runtime" "$runtime")
    fi
done
# DNS configuration and CA certificates are needed for real HTTPS clones.
# Include Fedora's /etc/pki and Arch's /etc/ca-certificates trust stores, which
# /etc/ssl certificate symlinks may reference.
for network_config in /etc/resolv.conf /etc/hosts /etc/nsswitch.conf \
    /etc/ssl/certs /etc/ssl/cert.pem /etc/pki /etc/ca-certificates; do
    if [[ -e $network_config ]]; then
        sandbox+=(--ro-bind "$network_config" "$network_config")
    fi
done
sandbox+=(--dev-bind /dev/null /dev/null --bind "$test_home" "$test_home"
    --chdir "$test_home/repo" --remount-ro / -- /usr/bin/env -i
    "HOME=$test_home" 'PATH=/usr/bin:/bin' 'LC_ALL=C'
    "TMPDIR=$test_home/tmp" "XDG_CONFIG_HOME=$test_home/.config"
    "XDG_STATE_HOME=$test_home/.local/state" "XDG_DATA_HOME=$test_home/.local/share"
    "XDG_CACHE_HOME=$test_home/.cache" 'GIT_CONFIG_NOSYSTEM=1'
    'GIT_CONFIG_GLOBAL=/dev/null' 'GIT_TERMINAL_PROMPT=0'
    'GIT_ALLOW_PROTOCOL=https' 'PYTHONDONTWRITEBYTECODE=1')

run_link() {
    timeout --kill-after=10s 300s "${sandbox[@]}" ./install "$@"
}

# Only the superproject's pinned gitlink entries cross into the empty index.
"${sandbox[@]}" git -c init.templateDir= init -q
git -C "$repo_dir" ls-files --stage -- modules/dotbot modules/nvim |
    "${sandbox[@]}" git update-index --index-info
"${sandbox[@]}" python3 - <<'PY'
from pathlib import Path

assert not Path('modules').exists(), 'Fixture contains submodule content'
assert not Path('.git/modules').exists(), 'Fixture contains submodule metadata'
assert not any(p.is_file() for p in Path('.git/objects').rglob('*')), 'Fixture contains Git objects'
print('PASS: fresh fixture has no submodule content, metadata, or Git objects; clones must use HTTPS remotes.')
PY

check_run_failure() {
    local status=$1 log=$2
    cat "$log"
    if [[ $status == 124 || $status == 137 ]]; then
        printf 'ERROR [NETWORK/REMOTE]: installer exceeded 300 seconds; GitHub/network may be unavailable. No checks were skipped.\n' >&2
        exit 2
    fi
    if grep -Eq 'Failed to clone|Unable to fetch in submodule path|fatal: (unable to access|could not read Username|repository .* not found|remote error:|unable to connect|transport .* not allowed)|did not contain [0-9a-f]+|Could not resolve|Failed to connect|Connection timed out' "$log"; then
        printf 'ERROR [NETWORK/REMOTE]: submodule download failed; check GitHub reachability, HTTPS/DNS/CA configuration, remote access, and pinned commits. See Git output above. No checks were skipped.\n' >&2
        exit 2
    fi
}

snapshot() {
    python3 - "$test_home" <<'PY'
import hashlib
import json
import os
from pathlib import Path
import stat
import sys

home = Path(sys.argv[1])
rows = []

def visit(path):
    info = path.lstat()
    row = [str(path.relative_to(home)), info.st_mode, info.st_uid, info.st_gid,
           info.st_ino, info.st_size, info.st_mtime_ns, info.st_ctime_ns]
    if stat.S_ISLNK(info.st_mode):
        row.append(os.readlink(path))
    elif stat.S_ISREG(info.st_mode):
        row.append(hashlib.sha256(path.read_bytes()).hexdigest())
    rows.append(row)
    if stat.S_ISDIR(info.st_mode):
        for child in sorted(path.iterdir()):
            visit(child)

for name in ['.config', '.local']:
    visit(home / name)
print(json.dumps(rows, indent=2))
PY
}

# The default subcommand must perform the same clean link operation.
if run_link > "$test_home/logs/first" 2>&1; then
    cat "$test_home/logs/first"
else
    check_run_failure "$?" "$test_home/logs/first"
    fail 'Clean/default run failed'
fi
[[ -f $test_home/repo/modules/dotbot/lib/pyyaml/lib/yaml/__init__.py &&
   -f $test_home/repo/modules/nvim/init.lua ]] || fail 'Recursive remote initialization is incomplete'
# shellcheck disable=SC2016 # Git supplies sha1 to the per-submodule shell.
"${sandbox[@]}" git submodule foreach --recursive \
    'test "$(git rev-parse HEAD)" = "$sha1" && printf "FETCHED: %s at %s from %s\n" "$displaypath" "$sha1" "$(git remote get-url origin)"' ||
    fail 'Submodule checkout differs from its recorded commit'
[[ -L $test_home/.config/git ]] || fail 'Git target is not a symlink'
[[ $(readlink -f -- "$test_home/.config/git") == "$test_home/repo/config/git" ]] ||
    fail 'Git symlink points to the wrong source'
[[ -L $test_home/.config/nvim ]] || fail 'Neovim target is not a symlink'
[[ $(readlink -f -- "$test_home/.config/nvim") == "$test_home/repo/modules/nvim" ]] ||
    fail 'Neovim symlink points to the wrong source'
[[ -d $test_home/.config && -d $test_home/.local/state ]] || fail 'Missing expected directories'
printf 'PASS: clean/default run creates the Git and Neovim links and XDG directories (exit 0).\n'

snapshot > "$test_home/logs/before.json"
if run_link link > "$test_home/logs/second" 2>&1; then
    cat "$test_home/logs/second"
else
    check_run_failure "$?" "$test_home/logs/second"
    fail 'Second run failed'
fi
snapshot > "$test_home/logs/after.json"
cmp -s "$test_home/logs/before.json" "$test_home/logs/after.json" || fail 'Second run changed installed state'
printf 'PASS: idempotence (exit 0; paths, bytes, link targets, inodes, modes, owners, mtime and ctime unchanged).\n'

for app in git nvim; do
    rm -- "$test_home/.config/$app"
    printf 'unmanaged %s target\nkeep these bytes\000\377\n' "$app" > "$test_home/logs/expected-conflict"
    cp -- "$test_home/logs/expected-conflict" "$test_home/.config/$app"
    if run_link link > "$test_home/logs/conflict" 2>&1; then
        fail 'Conflict run unexpectedly succeeded'
    else
        check_run_failure "$?" "$test_home/logs/conflict"
    fi
    [[ -f $test_home/.config/$app && ! -L $test_home/.config/$app ]] || fail "$app conflict file was replaced"
    cmp -s "$test_home/logs/expected-conflict" "$test_home/.config/$app" || fail "$app conflict file bytes changed"
    grep -q 'already exists' "$test_home/logs/conflict" || fail 'Conflict was not reported'
    printf 'PASS: %s conflict refused (nonzero exit); unmanaged file is byte-for-byte unchanged.\n' "$app"
    rm -- "$test_home/.config/$app"
    if run_link link > "$test_home/logs/restore" 2>&1; then
        :
    else
        check_run_failure "$?" "$test_home/logs/restore"
        fail "Failed to restore $app link after conflict check"
    fi
done

# A negative control proves the same sandbox used above rejects an actual write
# outside HOME, rather than just relying on HOME/XDG environment variables.
if "${sandbox[@]}" python3 -c 'from pathlib import Path; Path("/tmp/dotfiles-escape-probe").touch()' \
    > "$test_home/logs/escape" 2>&1; then
    fail 'Sandbox allowed a write outside the temporary HOME'
fi
grep -q 'Read-only file system' "$test_home/logs/escape" || {
    cat "$test_home/logs/escape"
    fail 'Write probe failed for an unexpected reason'
}
printf 'PASS: all installer runs confined to temporary HOME; outside write probe rejected by read-only filesystem.\n'
printf 'PASS: link-test (4/4 checks).\n'
