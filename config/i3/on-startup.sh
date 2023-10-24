#!/bin/bash

LOCKFILE_DIR="$XDG_RUNTIME_DIR/desktop_env"
EWW_LOCKFILE="$LOCKFILE_DIR/eww.lock"
PICOM_LOCKFILE="$LOCKFILE_DIR/picom.lock"

function start_initial() {
  # Start XDG autostart .desktop files using dex. See also
  # https://wiki.archlinux.org/index.php/XDG_Autostart
  dex --autostart --environment i3

  # Launch ibus
  ibus-daemon -d

  pulseaudio --start
  bluetoothctl power on

  syncthing &
  protonmail-bridge &
  dunst &
}

killall -q dunst
killall -q eww
killall -q picom
sleep 1

if [ "$1" == "initial" ]
then
  # Only run when starting i3 for the first time
  start_initial
fi

# Set desktop wallpapers
feh --bg-scale -g 3840x1440 ~/.background/mountains-blue-and-beige.jpg \
               -g 1920x1080 ~/.background/mountains-blue-and-gold.jpg

# Launch picom compositor
picom --experimental-backends --config "$XDG_CONFIG_HOME/i3/picom.conf" &

# Launch eww bar
sleep 1; sh "$XDG_CONFIG_HOME/eww/bar/launch_bar" &
