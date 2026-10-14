#!/usr/bin/env python3
"""Assert profile isolation and a shared lock entry point."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1] / 'config'
sway = root / 'sway'
physical = (sway / 'config').read_text()
vm = (sway / 'config.virtualbox').read_text()
for name, content, selected in (
    ('physical', physical, 'physical'),
    ('virtualbox', vm, 'virtualbox'),
):
    profiles = re.findall(r'^include profiles/([^\s]+)\.conf$', content, re.M)
    assert profiles == [selected], f'{name}: expected one {selected} profile, got {profiles}'
    assert 'include conf.d/60-session.conf' in content

physical_profile = (sway / 'profiles/physical.conf').read_text()
vm_profile = (sway / 'profiles/virtualbox.conf').read_text()
vm_launcher = (sway / 'bin/start-virtualbox').read_text()
physical_launcher = (sway / 'bin/start-physical').read_text()


def output_settings(profile, name):
    prefix = f'output {name} '
    tokens = next(line for line in profile.splitlines() if line.startswith(prefix)).split()

    def values_after(directive, count=1):
        if directive not in tokens:
            return None
        index = tokens.index(directive)
        values = tokens[index + 1:index + 1 + count]
        return values[0] if count == 1 else tuple(values)

    return {
        'mode': values_after('mode'),
        'position': values_after('position', 2),
        'scale': values_after('scale'),
    }


assert output_settings(physical_profile, 'DP-1') == {
    'mode': '3840x2160@143.963Hz',
    'position': ('0', '0'),
    'scale': '1',
}, 'G3223Q must be the left 4K/143.963 Hz primary output'
assert output_settings(physical_profile, 'DP-2') == {
    'mode': '2560x1440@59.951Hz',
    'position': ('3840', '0'),
    'scale': '1',
}, 'U2720Q must be the adjacent right 2K/59.951 Hz output'

assert 'VBoxClient' not in physical + physical_profile
assert 'WLR_RENDERER_ALLOW_SOFTWARE' not in physical + physical_profile
assert 'LIBGL_ALWAYS_SOFTWARE' not in physical + physical_profile
assert 'VBoxClient --clipboard --session-type wayland' in vm_profile
assert 'WLR_RENDERER_ALLOW_SOFTWARE=1' in vm_launcher
assert 'LIBGL_ALWAYS_SOFTWARE=1' in vm_launcher
assert 'config.virtualbox' in vm_launcher
assert 'config.virtualbox' not in physical_launcher
assert 'config/sway/config' in physical_launcher
assert 'WLR_RENDERER_ALLOW_SOFTWARE' not in physical_launcher
assert 'LIBGL_ALWAYS_SOFTWARE' not in physical_launcher

lock = '$HOME/.config/sway/bin/lock'
bindings = (sway / 'conf.d/40-bindings.conf').read_text()
idle = (sway / 'conf.d/60-session.conf').read_text()
power = (root / 'rofi/power_menu/script.sh').read_text()
assert f'exec {lock}' in bindings
assert f'bindsym $mod+Shift+l move right' in bindings
assert f'bindsym $mod+Ctrl+l exec {lock}' in bindings
assert f'    bindsym l exec {lock}, mode "default"' in bindings
assert idle.count(lock) == 2, 'Idle and before-sleep must use one lock path'
assert lock in power
assert 'swaylock' not in bindings + idle + power
print('PASS: one profile per entry point, VM isolation, and shared lock path.')
