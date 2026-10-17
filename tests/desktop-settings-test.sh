#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
config_home="$fixture/config"
state="$fixture/gsettings"
wayland_log="$fixture/swaymsg.log"
mkdir -p "$config_home/environment.d" "$state"
cp "$repo_dir/config/environment.d/50-desktop.conf" "$config_home/environment.d/50-desktop.conf"

run_configure() {
    env HOME="$fixture" XDG_CONFIG_HOME="$config_home" \
        FAKE_GSETTINGS_STATE="$state" \
        FAKE_SWAYMSG_LOG="$wayland_log" SWAYSOCK="$fixture/sway.sock" \
        PATH="$repo_dir/tests/fixtures:/usr/bin:/bin" \
        "$repo_dir/bin/configure-desktop"
}

run_configure
[[ $(< "$state/cursor-theme") == catppuccin-mocha-pink-cursors ]] ||
    fail 'desktop cursor theme was not synchronized with environment.d'
[[ $(< "$state/cursor-size") == 32 ]] ||
    fail 'desktop cursor size was not synchronized with environment.d'
expected_refresh=$'-q\t-t\tget_version\n-q\tseat\t*\txcursor_theme\tcatppuccin-mocha-pink-cursors\t33\n-q\tseat\t*\txcursor_theme\tcatppuccin-mocha-pink-cursors\t32'
[[ $(< "$wayland_log") == "$expected_refresh" ]] ||
    fail 'Sway cursor manager was not forced to rebuild at the configured theme and size'

before=$(stat -c '%i:%s:%Y:%Z' "$state/cursor-theme" "$state/cursor-size")
run_configure
after=$(stat -c '%i:%s:%Y:%Z' "$state/cursor-theme" "$state/cursor-size")
[[ $after == "$before" ]] || fail 'matching desktop cursor settings were written again'
[[ $(wc -l < "$wayland_log") == 6 ]] ||
    fail 'Sway cursor refresh did not run exactly once per desktop configuration pass'

printf 'PASS: desktop portal and Sway cursor settings synchronize to Pink/32.\n'
