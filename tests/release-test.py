#!/usr/bin/env python3
"""Pinned font releases install idempotently and corrupt archives fail closed."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile


root = Path(__file__).resolve().parent.parent
production = json.loads((root / 'provision/releases.json').read_text())
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
    (fixture_repo / 'provision/releases.json').write_text(json.dumps(releases))

    def prepare_home(name, corrupt=None):
        home = base / name
        cache = home / '.cache/dotfiles/releases'
        cache.mkdir(parents=True)
        for release_name, spec in releases.items():
            target = cache / (spec['sha256'] + Path(spec['url']).name)
            if release_name == corrupt:
                target.write_bytes(b'not the release archive')
            else:
                shutil.copy2(source_by_release[release_name], target)
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
    print('PASS: the default release mode retains executable-only installation')

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
