#!/usr/bin/env bash
set -euo pipefail
choice=$(printf '%s\n' 'Lock screen' 'Suspend' 'Hibernate' 'Log out' 'Reboot' 'Shut down' | rofi -dmenu -p 'Power') || exit 0
case "$choice" in
    'Lock screen') exec "$HOME/.config/sway/bin/lock" ;;
    Suspend) exec systemctl suspend ;;
    Hibernate) exec systemctl hibernate ;;
    Reboot|'Shut down'|'Log out')
        # Keep confirmation for actions that end the session.
        ;;
    '') exit 0 ;;
    *) exit 2 ;;
esac
confirm=$(printf '%s\n' 'No' 'Yes' | rofi -dmenu -p "Confirm $choice") || exit 0
[[ $confirm == Yes ]] || exit 0
case "$choice" in
    'Log out') exec swaymsg exit ;;
    Reboot) exec systemctl reboot ;;
    'Shut down') exec systemctl poweroff ;;
esac
