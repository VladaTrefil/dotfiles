#!/usr/bin/env bash

theme="$HOME/.config/rofi/launcher/theme.rasi"

case $1 in
  "powermenu")
    script="$HOME/.config/rofi/power_menu/script.sh"
    rofi -show power-menu -modi power-menu:"$script" -theme "$theme"
    ;;
esac

if [ -z "$1" ]; then
  theme="$HOME/.config/rofi/launcher/theme.rasi"
  rofi -show drun -theme "$theme"
  exit
fi
