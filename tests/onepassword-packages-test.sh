#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
plan=$("$repo_dir/install" packages --group onepassword --dry-run)
python3 - "$repo_dir" "$plan" <<'PY'
from pathlib import Path
import shlex
import sys

root = Path(sys.argv[1])
commands = [shlex.split(line) for line in sys.argv[2].splitlines()
            if line.startswith(('rpm ', 'install ', 'dnf '))]
assert commands == [
    ['rpm', '--import', 'https://downloads.1password.com/linux/keys/1password.asc'],
    ['install', '-m', '0644', '--', str(root / 'provision/1password.repo'),
     '/etc/yum.repos.d/1password.repo'],
    ['dnf', 'install', '-y', '--', '1password', '1password-cli'],
], 'the focused group must configure the official repository and only 1Password packages'
assert 'checksum-pinned RPMs' not in sys.argv[2]
assert 'kernel' not in sys.argv[2]
PY
printf 'PASS: focused 1Password package plan includes desktop integration without unrelated apps.\n'
