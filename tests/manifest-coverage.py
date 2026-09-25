#!/usr/bin/env python3
"""Ensure runtime commands in linked scripts have explicit package providers."""
from pathlib import Path
import re


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

# These packages implement two halves of one documented feature.  Keeping the
# daemon while dropping its PAM module would leave Secret Service available but
# make login-time auto-unlock impossible again.
companions = {
    'gnome-keyring': 'gnome-keyring-pam',
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
