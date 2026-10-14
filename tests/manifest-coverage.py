#!/usr/bin/env python3
"""Ensure runtime commands in linked scripts have explicit package providers."""
from pathlib import Path
import re
import shlex
import subprocess


root = Path(__file__).resolve().parent.parent


def manifest_packages():
    packages = set()
    for manifest in (root / 'packages').glob('*.txt'):
        if manifest.name in {'copr.txt', 'flatpak.txt'}:
            continue
        for raw_line in manifest.read_text().splitlines():
            package = raw_line.split('#', 1)[0].strip()
            if package:
                packages.add(package)
    return packages


# Keep this inventory narrow and evidence-based: these commands are invoked by
# linked desktop scripts, are not shell/core utilities, and previously failed
# silently because their Fedora providers were absent from every manifest.
requirements = {
    'bluez': {
        'binary': 'bluetoothctl',
        'scripts': ['config/eww/bar/scripts/bluetooth'],
    },
    'jq': {
        'binary': 'jq',
        'scripts': [
            'config/eww/bar/scripts/bluetooth',
            'config/eww/bar/scripts/workspace',
        ],
    },
    'lxqt-policykit': {
        'binary': '/usr/libexec/lxqt-policykit-agent',
        'active_command': True,
        'scripts': ['config/sway/bin/start-autostart'],
    },
}

packages = manifest_packages()
failures = []

sway_entrypoints = [
    root / 'config/sway/config',
    root / 'config/sway/config.virtualbox',
]
if any('include /etc/sway/config.d/*' in entry.read_text() for entry in sway_entrypoints):
    if 'sway-systemd' not in packages:
        failures.append(
            "the Sway entrypoints include Fedora's session integration, but "
            "provider package 'sway-systemd' is absent from packages/*.txt"
        )

apps_plan = subprocess.run(
    [str(root / 'install'), 'packages', '--group', 'apps', '--dry-run'],
    cwd=root,
    check=True,
    capture_output=True,
    text=True,
).stdout
dnf_commands = [
    shlex.split(line)
    for line in apps_plan.splitlines()
    if line.startswith('dnf install -y -- ')
]
if not any('iwlwifi-mvm-firmware' in command for command in dnf_commands):
    failures.append(
        "the apps package plan omits 'iwlwifi-mvm-firmware', so the Intel "
        'AX210 cannot load its Wi-Fi or Bluetooth firmware'
    )

# Each package below needs its companion for the documented feature to work
# end to end; retaining only the first package leaves a silently incomplete
# desktop integration.
companions = {
    'gnome-keyring': 'gnome-keyring-pam',
    'gvfs': 'gvfs-mtp',
}
for package, companion in companions.items():
    if package in packages and companion not in packages:
        failures.append(
            f'{package!r} is present, but required companion {companion!r} '
            'is absent from packages/*.txt'
        )

for package, requirement in requirements.items():
    binary = requirement['binary']
    if requirement.get('active_command'):
        pattern = re.compile(
            rf'^[ \t]*(?:exec[ \t]+)?{re.escape(binary)}(?=[ \t]|$)',
            re.MULTILINE,
        )
    else:
        pattern = re.compile(
            rf'(?<![A-Za-z0-9_.-]){re.escape(binary)}(?![A-Za-z0-9_.-])'
        )
    for relative in requirement['scripts']:
        script = root / relative
        if not script.is_file():
            failures.append(f'{relative}: tracked runtime script is missing')
        elif not pattern.search(script.read_text()):
            failures.append(f'{relative}: expected invocation of {binary!r} is missing')
    if package not in packages:
        paths = ', '.join(requirement['scripts'])
        failures.append(
            f'{binary} is invoked by {paths}, but provider package {package!r} '
            'is absent from packages/*.txt'
        )

if failures:
    for failure in failures:
        print(f'FAIL: {failure}')
    raise SystemExit(1)

print(
    'PASS: linked script runtime dependencies have manifest providers: '
    + ', '.join(sorted(requirements))
    + '; package companions: '
    + ', '.join(f'{package}+{companion}' for package, companion in companions.items())
)
