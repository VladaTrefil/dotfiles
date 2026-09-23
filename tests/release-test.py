#!/usr/bin/env python3
"""Pinned releases install idempotently and corrupt artifacts fail closed."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import zipfile


root = Path(__file__).resolve().parent.parent
production = json.loads((root / 'provision/releases.json').read_text())
assert production['eww'] == {
    'kind': 'rpm',
    'groups': ['desktop'],
    'version': '0.6.0^20260705g4ded063-1.fc44',
    'url': 'https://download.copr.fedorainfracloud.org/results/dturner/eww/fedora-44-x86_64/10704169-eww/eww-0.6.0%5E20260705g4ded063-1.fc44.x86_64.rpm',
    'sha256': 'cdea82650b8b485b65cfbeac31299a3103f81db499ae2741cc81ba214d6fdc96',
    'size': 4351828,
}
assert production['lens'] == {
    'kind': 'rpm',
    'groups': ['apps'],
    'version': '2026.9.181013~latest-1',
    'url': 'https://downloads.k8slens.dev/rpm/packages/Lens-2026.9.181013-latest.x86_64.rpm',
    'sha256': '6faf2a62a2f9ea26071effc5651f57411bef7229478676df4dbeaa349ee5736a',
    'size': 170112665,
}
assert production['qmk']['kind'] == 'python-wheel-set'
assert production['qmk']['version'] == '1.2.0'
assert production['qmk']['entry_point'] == 'qmk_cli.script_qmk:main'
assert len(production['qmk']['artifacts']) == 7
assert production['qmk']['artifacts'][0]['sha256'] == (
    '77fa04a24d36feb7f19f19f190eaf350b78a5caf5ef6a783251902e853fd1809'
)
assert production['op'] == {
    'version': '2.39.0',
    'url': 'https://cache.agilebits.com/dist/1P/op2/pkg/v2.39.0/op_linux_amd64_v2.39.0.zip',
    'sha256': '6fba7f376b6c6dec49f41b06408930a43ad064cce103c6a2ce5b3d0413a86434',
    'size': 14997542,
    'member': 'op',
}
assert production['iosevka-nerd-font'] == {
    'kind': 'font',
    'version': 'v3.5.1',
    'url': 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Iosevka.tar.xz',
    'sha256': '3b94ea1dc3955756762f977b7677bca671947dd56bc755a6f8465a8e83b5f257',
    'members': [
        'IosevkaNerdFont-Regular.ttf',
        'IosevkaNerdFont-Bold.ttf',
        'IosevkaNerdFont-Italic.ttf',
    ],
}
assert production['meslolgs-nerd-font'] == {
    'kind': 'font',
    'version': 'v3.5.1',
    'url': 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Meslo.tar.xz',
    'sha256': '6b6624632dc6873dfb7681c3f818e7c01ab601ab707690b6440933bbe57e2b11',
    'members': [
        'MesloLGSNerdFont-Regular.ttf',
        'MesloLGSNerdFont-Bold.ttf',
        'MesloLGSNerdFont-Italic.ttf',
    ],
}


def checksum(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot(directory):
    rows = []
    for path in sorted(directory.rglob('*')):
        stat = path.lstat()
        rows.append((
            str(path.relative_to(directory)), stat.st_ino, stat.st_mode,
            stat.st_size, stat.st_mtime_ns,
            checksum(path) if path.is_file() else None,
        ))
    return rows


fixture_fonts = []
for candidate in subprocess.run(
    ['fc-list', '-f', '%{file}\n'], check=True, text=True, capture_output=True,
).stdout.splitlines():
    path = Path(candidate)
    if path.is_file() and path not in fixture_fonts:
        fixture_fonts.append(path)
    if len(fixture_fonts) == 2:
        break
assert len(fixture_fonts) == 2, 'fontconfig did not resolve two fixture fonts'

with tempfile.TemporaryDirectory() as directory:
    base = Path(directory)
    fixture_repo = base / 'repo'
    (fixture_repo / 'bin').mkdir(parents=True)
    (fixture_repo / 'provision').mkdir()
    shutil.copy2(root / 'bin/install-releases', fixture_repo / 'bin/install-releases')

    source_archives = base / 'archives'
    source_archives.mkdir()
    definitions = {
        'iosevka-nerd-font': [
            'IosevkaNerdFont-Regular.ttf',
            'IosevkaNerdFont-Bold.ttf',
            'IosevkaNerdFont-Italic.ttf',
        ],
        'meslolgs-nerd-font': [
            'MesloLGSNerdFont-Regular.ttf',
            'MesloLGSNerdFont-Bold.ttf',
            'MesloLGSNerdFont-Italic.ttf',
        ],
    }
    releases = {}
    source_by_release = {}
    for fixture_number, (name, members) in enumerate(definitions.items()):
        archive = source_archives / (name + '.tar.xz')
        with tarfile.open(archive, 'w:xz') as package:
            for member in members:
                package.add(fixture_fonts[fixture_number], arcname=member)
        releases[name] = {
            'kind': 'font',
            'version': 'fixture',
            'url': f'https://example.invalid/{archive.name}',
            'sha256': checksum(archive),
            'members': members,
        }
        source_by_release[name] = archive
    tool_source = source_archives / 'asdf'
    tool_source.write_bytes(b'#!/bin/sh\nprintf "fixture asdf\\n"\n')
    tool_archive = source_archives / 'asdf.tar.gz'
    with tarfile.open(tool_archive, 'w:gz') as package:
        package.add(tool_source, arcname='asdf')
    releases['asdf'] = {
        'version': 'fixture',
        'url': 'https://example.invalid/asdf.tar.gz',
        'sha256': checksum(tool_archive),
        'member': 'asdf',
    }
    source_by_release['asdf'] = tool_archive
    op_source = source_archives / 'op'
    op_source.write_bytes(b'#!/bin/sh\nprintf "fixture op 2.39.0\\n"\n')
    op_archive = source_archives / 'op.zip'
    with zipfile.ZipFile(op_archive, 'w') as package:
        package.write(op_source, arcname='op')
        package.writestr('op.sig', 'fixture signature')
    releases['op'] = {
        'version': '2.39.0',
        'url': 'https://example.invalid/op.zip',
        'sha256': checksum(op_archive),
        'size': op_archive.stat().st_size,
        'member': 'op',
    }
    source_by_release['op'] = op_archive
    wheel_source = source_archives / 'qmk-fixture.whl'
    with zipfile.ZipFile(wheel_source, 'w') as package:
        package.writestr(
            'fixture_cli.py',
            'def main():\n    print("fixture qmk")\n',
        )
        package.writestr('qmk_fixture-1.0.dist-info/METADATA', 'Name: qmk-fixture\nVersion: 1.0\n')
    releases['qmk'] = {
        'kind': 'python-wheel-set',
        'version': 'fixture',
        'entry_point': 'fixture_cli:main',
        'artifacts': [{
            'url': 'https://example.invalid/qmk-fixture.whl',
            'sha256': checksum(wheel_source),
            'size': wheel_source.stat().st_size,
        }],
    }
    source_by_release['qmk'] = [wheel_source]
    rpm_source = source_archives / 'eww.rpm'
    rpm_source.write_bytes(b'fixture RPM bytes')
    releases['eww'] = {
        'kind': 'rpm',
        'version': 'fixture',
        'url': 'https://example.invalid/eww.rpm',
        'sha256': checksum(rpm_source),
        'size': rpm_source.stat().st_size,
    }
    source_by_release['eww'] = rpm_source
    (fixture_repo / 'provision/releases.json').write_text(json.dumps(releases))

    def prepare_home(name, corrupt=None):
        home = base / name
        cache = home / '.cache/dotfiles/releases'
        cache.mkdir(parents=True)
        for release_name, spec in releases.items():
            artifacts = spec.get('artifacts', [spec])
            sources = source_by_release[release_name]
            if not isinstance(sources, list):
                sources = [sources]
            for artifact, source in zip(artifacts, sources, strict=True):
                target = cache / (artifact['sha256'] + Path(artifact['url']).name)
                if release_name == corrupt:
                    target.write_bytes(b'not the release archive')
                else:
                    shutil.copy2(source, target)
        return home

    home = prepare_home('home')
    env = dict(
        os.environ,
        HOME=str(home),
        XDG_CACHE_HOME=str(home / '.cache'),
        XDG_DATA_HOME=str(home / '.local/share'),
    )
    command = [str(fixture_repo / 'bin/install-releases'), '--fonts', '--offline']
    first = subprocess.run(command, env=env, text=True, capture_output=True)
    assert first.returncode == 0, first
    font_root = home / '.local/share/fonts/dotfiles-releases'
    installed = sorted(path.name for path in font_root.rglob('*.ttf'))
    assert installed == sorted(sum(definitions.values(), [])), installed
    subprocess.run(['fc-cache', str(font_root)], env=env, check=True)
    listed = set(subprocess.run(
        ['fc-list', '-f', '%{file}\n'], env=env, check=True,
        text=True, capture_output=True,
    ).stdout.splitlines())
    for name in definitions:
        release_paths = {str(path) for path in (font_root / name).glob('*.ttf')}
        assert release_paths & listed, f'{name} is absent from fc-list'
    for path in font_root.rglob('*.ttf'):
        scanned = subprocess.run(
            ['fc-scan', '-f', '%{family}\n', str(path)], check=True,
            text=True, capture_output=True,
        ).stdout.strip()
        assert scanned, f'{path} is not readable by fontconfig'
    assert not (home / '.local/bin').exists(), '--fonts installed an executable'

    before = snapshot(font_root)
    second = subprocess.run(command, env=env, text=True, capture_output=True)
    assert second.returncode == 0, second
    assert snapshot(font_root) == before, 'second run changed installed fonts'
    print('PASS: selected font faces install, appear in fc-list, and remain byte/metadata-idempotent')

    tool = subprocess.run(
        [str(fixture_repo / 'bin/install-releases'), '--offline'],
        env=env, text=True, capture_output=True,
    )
    assert tool.returncode == 0, tool
    installed_tool = home / '.local/bin/asdf'
    assert installed_tool.read_bytes() == tool_source.read_bytes(), installed_tool
    assert os.access(installed_tool, os.X_OK), 'installed executable is not executable'
    installed_op = home / '.local/bin/op'
    assert installed_op.read_bytes() == op_source.read_bytes(), installed_op
    assert os.access(installed_op, os.X_OK), 'installed op is not executable'
    qmk = subprocess.run(
        [str(home / '.local/bin/qmk')], env=env, text=True, capture_output=True,
    )
    assert qmk.returncode == 0 and qmk.stdout.strip() == 'fixture qmk', qmk
    release_root = home / '.local/share/dotfiles-releases/qmk-fixture'
    before_qmk = snapshot(release_root)
    before_launcher = snapshot(home / '.local/bin')
    repeated_tools = subprocess.run(
        [str(fixture_repo / 'bin/install-releases'), '--offline'],
        env=env, text=True, capture_output=True,
    )
    assert repeated_tools.returncode == 0, repeated_tools
    assert snapshot(release_root) == before_qmk
    assert snapshot(home / '.local/bin') == before_launcher
    print('PASS: default release mode installs executable and pinned wheel-set tools idempotently')

    rpm = subprocess.run(
        [str(fixture_repo / 'bin/install-releases'), '--rpm', '--offline'],
        env=env, text=True, capture_output=True,
    )
    assert rpm.returncode == 0, rpm
    assert Path(rpm.stdout.strip()).read_bytes() == rpm_source.read_bytes()
    print('PASS: packages phase receives only a verified pinned RPM path')

    corrupt_rpm_home = prepare_home('corrupt-rpm-home', corrupt='eww')
    corrupt_rpm_env = dict(env, HOME=str(corrupt_rpm_home),
                           XDG_CACHE_HOME=str(corrupt_rpm_home / '.cache'))
    corrupt_rpm = subprocess.run(
        [str(fixture_repo / 'bin/install-releases'), '--rpm', '--offline'],
        env=corrupt_rpm_env, text=True, capture_output=True,
    )
    assert corrupt_rpm.returncode != 0 and 'mismatch' in corrupt_rpm.stderr, corrupt_rpm
    print('PASS: corrupt RPM is rejected before dnf can receive its path')

    corrupt_op_home = prepare_home('corrupt-op-home', corrupt='op')
    corrupt_op_env = dict(
        os.environ,
        HOME=str(corrupt_op_home),
        XDG_CACHE_HOME=str(corrupt_op_home / '.cache'),
        XDG_DATA_HOME=str(corrupt_op_home / '.local/share'),
    )
    corrupt_op = subprocess.run(
        [str(fixture_repo / 'bin/install-releases'), '--offline'],
        env=corrupt_op_env, text=True, capture_output=True,
    )
    assert corrupt_op.returncode != 0 and 'SHA-256 mismatch' in corrupt_op.stderr, corrupt_op
    assert not (corrupt_op_home / '.local/bin').exists(), (
        'an executable was installed before the corrupt op archive was rejected'
    )
    print('PASS: a corrupt op archive is rejected before any executable installation')

    corrupt_home = prepare_home('corrupt-home', corrupt='meslolgs-nerd-font')
    corrupt_env = dict(
        os.environ,
        HOME=str(corrupt_home),
        XDG_CACHE_HOME=str(corrupt_home / '.cache'),
        XDG_DATA_HOME=str(corrupt_home / '.local/share'),
    )
    result = subprocess.run(command, env=corrupt_env, text=True, capture_output=True)
    assert result.returncode != 0 and 'SHA-256 mismatch' in result.stderr, result
    corrupt_root = corrupt_home / '.local/share/fonts/dotfiles-releases'
    assert not corrupt_root.exists(), 'a font was installed before all archive checks passed'
    print('PASS: a corrupt font archive fails closed before any font installation')
