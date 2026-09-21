#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
trap 'printf "FAIL: unexpected error at line %s\n" "$LINENO" >&2' ERR
for tool in bwrap git python3 tar; do
    command -v "$tool" >/dev/null || fail "Required test tool is missing: $tool"
done
[[ -f $repo_dir/modules/dotbot/lib/pyyaml/lib/yaml/__init__.py ]] ||
    fail 'Initialize submodules first: git submodule update --init --recursive'

test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT
mkdir -p "$test_home/repo" "$test_home/tmp" "$test_home/logs"
# Keep the working copy (including uncommitted changes), with independent Git
# metadata so submodule initialization cannot write back to the source repo.
# Never copy excluded secret files, even if a later block adds local ones.
tar -C "$repo_dir" --exclude='*secret*env*' --exclude='*SECRET*ENV*' \
    --exclude=Documents --exclude=.state --exclude=.cache --exclude=__pycache__ \
    -cf - . | tar -C "$test_home/repo" -xf -

# No real HOME or its config is mounted. Only the fixture is writable; even
# /tmp outside the fixture belongs to the read-only sandbox root.
sandbox=(bwrap --die-with-parent --unshare-net)
for runtime in /usr /bin /lib /lib64; do
    if [[ -d $runtime ]]; then
        sandbox+=(--ro-bind "$runtime" "$runtime")
    fi
done
sandbox+=(--dev-bind /dev/null /dev/null --bind "$test_home" "$test_home"
    --chdir "$test_home/repo" --remount-ro / -- /usr/bin/env -i
    "HOME=$test_home" 'PATH=/usr/bin:/bin' 'LC_ALL=C'
    "TMPDIR=$test_home/tmp" "XDG_CONFIG_HOME=$test_home/.config"
    "XDG_STATE_HOME=$test_home/.local/state" "XDG_DATA_HOME=$test_home/.local/share"
    "XDG_CACHE_HOME=$test_home/.cache" 'GIT_CONFIG_NOSYSTEM=1'
    'GIT_CONFIG_GLOBAL=/dev/null' 'PYTHONDONTWRITEBYTECODE=1')

run_link() {
    "${sandbox[@]}" ./install "$@"
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
if ! run_link > "$test_home/logs/first" 2>&1; then
    cat "$test_home/logs/first"
    fail 'Clean/default run failed'
fi
cat "$test_home/logs/first"
[[ -L $test_home/.config/git ]] || fail 'Git target is not a symlink'
[[ $(readlink -f -- "$test_home/.config/git") == "$test_home/repo/config/git" ]] ||
    fail 'Git symlink points to the wrong source'
[[ -d $test_home/.config && -d $test_home/.local/state ]] || fail 'Missing expected directories'
printf 'PASS: clean/default run creates the Git link and XDG directories (exit 0).\n'

snapshot > "$test_home/logs/before.json"
if ! run_link link > "$test_home/logs/second" 2>&1; then
    cat "$test_home/logs/second"
    fail 'Second run failed'
fi
cat "$test_home/logs/second"
snapshot > "$test_home/logs/after.json"
cmp -s "$test_home/logs/before.json" "$test_home/logs/after.json" || fail 'Second run changed installed state'
printf 'PASS: idempotence (exit 0; paths, bytes, link targets, inodes, modes, owners, mtime and ctime unchanged).\n'

rm -- "$test_home/.config/git"
printf 'unmanaged Git target\nkeep these bytes\000\377\n' > "$test_home/logs/expected-conflict"
cp -- "$test_home/logs/expected-conflict" "$test_home/.config/git"
if run_link link > "$test_home/logs/conflict" 2>&1; then
    fail 'Conflict run unexpectedly succeeded'
fi
cat "$test_home/logs/conflict"
[[ -f $test_home/.config/git && ! -L $test_home/.config/git ]] || fail 'Conflict file was replaced'
cmp -s "$test_home/logs/expected-conflict" "$test_home/.config/git" || fail 'Conflict file bytes changed'
grep -q 'already exists' "$test_home/logs/conflict" || fail 'Conflict was not reported'
printf 'PASS: conflict refused (nonzero exit); unmanaged file is byte-for-byte unchanged.\n'

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
