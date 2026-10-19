#!/usr/bin/env python3
from pathlib import Path
import subprocess


repo_dir = Path(__file__).resolve().parent.parent
config_path = repo_dir / 'config/kitty/kitty.conf'
probe = r'''
from kitty.config import load_config
from kitty.options.utils import parse_shortcut
import sys

bad_lines = []
options = load_config(sys.argv[1], accumulate_bad_lines=bad_lines)
if bad_lines:
    raise SystemExit(f'FAIL: invalid Kitty config: {bad_lines}')

shortcut = parse_shortcut('ctrl+shift+s')
definitions = options.keyboard_modes[''].keymap.get(shortcut, ())
if not definitions or definitions[-1].definition:
    actions = [definition.definition for definition in definitions]
    raise SystemExit(
        'FAIL: Ctrl-Shift-S must pass through Kitty; '
        f'effective actions: {actions}'
    )

print('PASS: Ctrl-Shift-S passes through Kitty.')
'''

subprocess.run(
    ['kitty', '+runpy', probe, str(config_path)],
    check=True,
)
