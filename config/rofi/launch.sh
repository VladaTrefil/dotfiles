#!/usr/bin/env bash
set -euo pipefail
theme="$HOME/.config/rofi/launcher/theme.rasi"
case "${1:-drun}" in
    drun) exec rofi -show drun -theme "$theme" ;;
    powermenu) exec "$HOME/.config/rofi/power_menu/script.sh" ;;
    *) printf 'Unknown rofi mode: %s\n' "$1" >&2; exit 2 ;;
esac
