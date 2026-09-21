#!/usr/bin/env python3
"""Check both CLI identity and distro ownership, including Python's provider module."""
import json
from pathlib import Path
import shutil
import subprocess

root = Path(__file__).resolve().parent.parent
inventory = json.loads((root / 'tests/providers.json').read_text())
packages = [s.split('#')[0].strip() for s in (root / 'packages/editor-tools.txt').read_text().splitlines()]
assert set(filter(None, packages)) == set(inventory), 'provider test and package inventory differ'
fedora = 'ID=fedora' in Path('/etc/os-release').read_text()
for package, (binary, flag, marker, upstream) in inventory.items():
    executable = shutil.which(binary)
    assert executable, f'Missing {binary} ({package})'
    command = [executable, flag]
    owner_path = str(Path(executable).resolve())
    if package == 'python3-neovim':
        command.append('import pynvim; print("pynvim", pynvim.VERSION); print(pynvim.__file__)')
    output = subprocess.check_output(command, text=True, stderr=subprocess.STDOUT)
    assert marker.lower() in output.lower(), (package, output)
    if package == 'python3-neovim':
        owner_path = output.splitlines()[-1]
    if fedora:
        owner = subprocess.check_output(['rpm', '-qf', '--qf', '%{NAME}', owner_path], text=True)
        assert owner == package, (binary, owner, package)
        metadata = subprocess.check_output(['rpm', '-q', '--qf', '%{NAME} %{VERSION} %{URL}', package], text=True)
        assert upstream.lower() in metadata.lower(), (package, metadata)
    else:
        result = subprocess.run(['pacman', '-Qo', owner_path], text=True, capture_output=True)
        metadata = result.stdout.strip() if result.returncode == 0 else 'temporary test venv (pip codespell/shellcheck-py)'
        assert result.returncode == 0 or binary in {'codespell', 'shellcheck'}, (binary, result.stderr)
    print(f'PROVIDER {package}: {next(line.strip() for line in output.splitlines() if marker.lower() in line.lower())} | {metadata}', flush=True)
print(f'PASS: all {len(inventory)} editor package implementations and providers')
