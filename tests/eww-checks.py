#!/usr/bin/env python3
"""Check the eww window and Sway startup contracts."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
config = (root / 'config/eww')
yuck = '\n'.join(path.read_text() for path in config.rglob('*.yuck'))
windows = set(re.findall(r'^\(defwindow\s+(\w+)', yuck, re.M))
assert windows == {'bar', 'calendar', 'system', 'bluetooth_menu'}, windows
bar = (config / 'bar/eww.yuck').read_text()
assert re.search(r'\(defwindow bar \[monitor\]\s+:monitor monitor', bar)
assert ':exclusive true' in bar
assert '(systray)' in bar
assert all(token in bar for token in ('(workspaces)', '(clock)', '(volume)',
                                      '(bluetooth)', '(network)', '(system_widget)'))
for profile, output in [('physical', 'DP-1'), ('virtualbox', 'Virtual-1')]:
    startup = (root / f'config/sway/profiles/{profile}.conf').read_text()
    assert f'eww daemon && eww update bar_monitor={output} && eww open --arg monitor={output} bar' in startup
session = (root / 'config/sway/conf.d/60-session.conf').read_text()
assert re.search(r'^exec dex-autostart --autostart --environment sway$', session, re.M)
assert 'waybar' not in session
assert not (root / 'config/waybar').exists()
assert 'waybar' not in (root / 'packages/desktop.txt').read_text()
assert '$XDG_CONFIG_HOME/eww: config/eww' in (root / 'install.conf.yaml').read_text()
for removed in ('bar/widgets/lang.yuck', 'bar/widgets/langs.json', 'bar/scripts/langs',
                'assets/langs', 'bar/widgets/mediaplayer.yuck', 'bar/scripts/mediaplayer',
                'bar/launch_bar'):
    assert not (config / removed).exists(), removed
assert 'language_menu' not in yuck
assert 'mediaplayer' not in yuck
assert 'swaymsg -t get_workspaces' in (config / 'bar/scripts/workspace').read_text()
assert '/sys/class/net/' in (config / 'bar/scripts/network').read_text()
assert ':text volume_icon' in (config / 'bar/widgets/audio.yuck').read_text()
print('PASS: eww windows, Sway startup, tray, removed widgets and live data sources.')
