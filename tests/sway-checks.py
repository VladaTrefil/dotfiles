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
