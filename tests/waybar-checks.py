#!/usr/bin/env python3
"""Check the bar layout, declared modules, and desktop startup contract."""
import json
from pathlib import Path
import re
import subprocess

root = Path(__file__).resolve().parents[1]
assert not (root / 'config' / ('ew' + 'w')).exists()
assert not (root / 'config/waybar/config.json').exists(), 'Waybar ignores config.json'
bar = json.loads((root / 'config/waybar/config.jsonc').read_text())
layout = [name for side in ('left', 'center', 'right')
          for name in bar[f'modules-{side}']]
expected = {'sway/workspaces', 'clock', 'network', 'cpu', 'memory', 'disk',
            'bluetooth', 'pulseaudio', 'tray'}
assert len(layout) == len(set(layout)), 'duplicate module in layout'
assert set(layout) == expected, f'wrong bar modules: {layout}'
assert all(isinstance(bar.get(name), dict) for name in layout), \
    'layout module lacks a definition'
assert bar['modules-left'] == ['sway/workspaces']
assert bar['modules-center'] == ['clock']
assert bar['modules-right'][-1] == 'tray'
assert '{calendar}' in bar['clock']['tooltip-format']
assert bar['disk']['path'] == '/'
assert 'idle_inhibitor' not in str(bar)

session = (root / 'config/sway/conf.d/60-session.conf').read_text()
assert re.search(r'^exec dex-autostart --autostart --environment sway$', session, re.M)
assert re.search(r'^exec waybar$', session, re.M)
assert 'QT_QPA_PLATFORMTHEME=qt6ct' in (root / 'config/environment.d/50-desktop.conf').read_text()
assert 'QT_QPA_PLATFORMTHEME' not in session
assert 'color_scheme_path=~/.config/qt6ct/colors/Catppuccin-Mocha.conf' in (root / 'config/qt6ct/qt6ct.conf').read_text()
assert 'qt5ct.conf' not in (root / 'install.conf.yaml').read_text()

# Git's file list excludes third-party submodule contents. Docs intentionally
# describe the old configuration, but owned live files may not refer to it.
paths = subprocess.check_output(
    ['git', 'ls-files', '-co', '--exclude-standard', '-z', '--', '.',
     ':(exclude,glob)**/*secret*env*', ':(exclude,glob)*secret*env*',
     ':(exclude,glob)**/*SECRET*ENV*', ':(exclude,glob)*SECRET*ENV*'], cwd=root,
).decode().split('\0')
for name in paths:
    if not name or name.startswith('docs/') or name == '.secret-env':
        continue
    path = root / name
    if path.is_file() and not path.is_symlink():
        assert not re.search('ew' + 'w', path.read_text(errors='ignore'), re.I), path
print('PASS: JSON bar layout, modules, session autostart, and removed config references.')
