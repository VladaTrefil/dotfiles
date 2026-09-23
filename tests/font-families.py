#!/usr/bin/env python3
"""Check that desktop config font families have declared installation sources."""
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
fonts = (root / 'packages/fonts.txt').read_text()
desktop = (root / 'packages/desktop.txt').read_text()
releases = json.loads((root / 'provision/releases.json').read_text())

provided = set(re.findall(r'^# private-font-family: (.+?) \(', fonts, re.M))
package_families = {
    'google-noto-sans-jp-fonts': 'Noto Sans JP',
    'google-noto-color-emoji-fonts': 'Noto Color Emoji',
    'fontawesome-6-free-fonts': 'Font Awesome 6 Free',
}
for package, family in package_families.items():
    if re.search(rf'^{re.escape(package)}$', fonts + desktop, re.M):
        provided.add(family)
release_families = {
    'iosevka-nerd-font': 'Iosevka Nerd Font',
    'meslolgs-nerd-font': 'MesloLGS Nerd Font',
}
for release, family in release_families.items():
    if release in releases and releases[release].get('kind') == 'font':
        provided.add(family)

def read(path):
    return (root / path).read_text()

scss_variables = dict(re.findall(
    r'^\$([\w-]+):\s*[\'"]([^\'"]+)[\'"]', read('config/eww/variables.scss'), re.M))
eww_fonts = {}
for stylesheet in sorted((root / 'config/eww').rglob('*.scss')):
    values = re.findall(r'font-family:\s*([^;]+);', stylesheet.read_text())
    if values:
        eww_fonts[str(stylesheet.relative_to(root))] = [
            scss_variables[value.strip()[1:]] if value.strip().startswith('$')
            else value.strip().strip('\'"') for value in values
        ]

uses = {
    **eww_fonts,
    'dunst/dunstrc': re.findall(
        r'^\s*font\s*=\s*"(.+?)"', read('config/dunst/dunstrc'), re.M),
    'sway/conf.d/10-appearance.conf': re.findall(
        r'^font pango:(.+)$', read('config/sway/conf.d/10-appearance.conf'), re.M),
    'kitty/kitty.conf': re.findall(
        r'^font_family\s+(.+)$', read('config/kitty/kitty.conf'), re.M),
    'rofi/theme.rasi': re.findall(
        r'^\s*font:\s*"(.+?)"', read('config/rofi/theme.rasi'), re.M),
    'qt6ct/qt6ct.conf': re.findall(
        r'^(?:fixed|general)="([^,]+),', read('config/qt6ct/qt6ct.conf'), re.M),
}
missing = []
for path, values in uses.items():
    assert values, f'No font setting parsed in {path}'
    for value in values:
        for family in value.split(',') if path.startswith('config/eww/') else [value]:
            family = re.sub(r'\s+\d+(?:\.\d+)?$', '', family.strip().strip('"'))
            if family not in provided:
                missing.append(f'{path}: {family}')
assert not missing, 'Undeclared font families: ' + '; '.join(missing)
print('PASS: desktop font families have declared font sources.')
