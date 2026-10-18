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
    assert content.count('include /etc/sway/config.d/*') == 1, (
        f'{name}: Fedora session integration must be included exactly once'
    )
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
        'background': values_after('bg', 3),
    }


assert output_settings(physical_profile, 'DP-1') == {
    'mode': '3840x2160@143.963Hz',
    'position': ('0', '0'),
    'scale': '1',
    'background': ('~/.background/mountains-blue-and-beige.jpg', 'fill', '$bg'),
}, 'G3223Q must be the left 4K/143.963 Hz primary output'
assert output_settings(physical_profile, 'DP-2') == {
    'mode': '2560x1440@59.951Hz',
    'position': ('3840', '0'),
    'scale': '1',
    'background': ('~/.background/mountains-blue-and-gold.jpg', 'fill', '$bg'),
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
ibus_unit_path = root / 'systemd/user/ibus-wayland.service'
assert ibus_unit_path.is_file(), 'The supervised IBus Wayland user unit is missing'
ibus_unit = ibus_unit_path.read_text()
assert 'PartOf=sway-session.target' in ibus_unit
assert 'After=sway-session.target' in ibus_unit
assert 'ConditionEnvironment=WAYLAND_DISPLAY' in ibus_unit
assert 'ExecStart=/usr/libexec/ibus-ui-gtk3 --enable-wayland-im --exec-daemon' in ibus_unit
assert 'Restart=always' in ibus_unit
assert 'dbus-update-activation-environment' not in idle
assert 'ibus start --type wayland' not in idle
assert f'exec {lock}' in bindings
assert f'bindsym $mod+Shift+l move right' in bindings
assert f'bindsym $mod+Ctrl+l exec {lock}' in bindings
assert f'    bindsym l exec {lock}, mode "default"' in bindings
assert idle.count(lock) == 2, 'Idle and before-sleep must use one lock path'
assert lock in power
assert 'swaylock' not in bindings + idle + power
print('PASS: profile isolation, Fedora session lifecycle, supervised IBus, and shared lock path.')
