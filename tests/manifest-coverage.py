#!/usr/bin/env python3
"""Ensure runtime dependencies in linked scripts have explicit package providers."""
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


# Keep this inventory narrow and evidence-based: these dependencies are used by
# linked desktop scripts and previously failed silently when their Fedora
# providers were absent from every manifest.
requirements = {
    'bluez': {
        'marker': 'org.bluez',
        'scripts': ['config/eww/bar/scripts/bluetooth'],
    },
    'jq': {
        'binary': 'jq',
        'scripts': ['config/eww/bar/scripts/workspace'],
    },
    'python3-gobject-base': {
        'marker': 'from gi.repository import Gio, GLib',
        'scripts': ['config/eww/bar/scripts/bluetooth'],
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
apps_plan_lines = apps_plan.splitlines()
dnf_commands = [
    shlex.split(line)
    for line in apps_plan_lines
    if line.startswith('dnf install -y -- ')
]
dnf_upgrade_commands = [
    shlex.split(line)
    for line in apps_plan_lines
    if line.startswith('dnf upgrade -y -- ')
]
onepassword_key_command = [
    'rpm',
    '--import',
    'https://downloads.1password.com/linux/keys/1password.asc',
]
onepassword_repo_command = [
    'install',
    '-m',
    '0644',
    '--',
    str(root / 'provision/1password.repo'),
    '/etc/yum.repos.d/1password.repo',
]
parsed_plan_lines = [shlex.split(line) for line in apps_plan_lines]
if onepassword_key_command not in parsed_plan_lines:
    failures.append(
        'the apps package plan does not import the official 1Password signing key'
    )
if onepassword_repo_command not in parsed_plan_lines:
    failures.append(
        'the apps package plan does not install the reviewed 1Password repository file'
    )
if not any('1password' in command for command in dnf_commands):
    failures.append(
        "the apps package plan omits the native '1password' desktop package"
    )
if not any('iwlwifi-mvm-firmware' in command for command in dnf_commands):
    failures.append(
        "the apps package plan omits 'iwlwifi-mvm-firmware', so the Intel "
        'AX210 cannot load its Wi-Fi or Bluetooth firmware'
    )
if not any('restic' in command for command in dnf_commands):
    failures.append(
        "the apps package plan omits 'restic', so the documented backup "
        'restore workflow cannot inspect or restore repositories'
    )
if not any('VirtualBox' in command for command in dnf_commands):
    failures.append(
        "the apps package plan omits 'VirtualBox', so restored virtual "
        'machines cannot be validated or started'
    )
if not any(command == ['dnf', 'upgrade', '-y', '--', 'kernel'] for command in dnf_upgrade_commands):
    failures.append(
        "the apps package plan does not synchronize Fedora's full 'kernel' "
        "package, so VirtualBox's kernel-devel-matched dependency can create "
        'a bootable kernel-core installation that lacks kernel-modules drivers'
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
    marker = requirement.get('marker', requirement.get('binary'))
    if 'marker' in requirement:
        pattern = re.compile(re.escape(marker))
    elif requirement.get('active_command'):
        pattern = re.compile(
            rf'^[ \t]*(?:exec[ \t]+)?{re.escape(marker)}(?=[ \t]|$)',
            re.MULTILINE,
        )
    else:
        pattern = re.compile(
            rf'(?<![A-Za-z0-9_.-]){re.escape(marker)}(?![A-Za-z0-9_.-])'
        )
    for relative in requirement['scripts']:
        script = root / relative
        if not script.is_file():
            failures.append(f'{relative}: tracked runtime script is missing')
        elif not pattern.search(script.read_text()):
            failures.append(f'{relative}: expected runtime marker {marker!r} is missing')
    if package not in packages:
        paths = ', '.join(requirement['scripts'])
        failures.append(
            f'{marker} is used by {paths}, but provider package {package!r} '
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
