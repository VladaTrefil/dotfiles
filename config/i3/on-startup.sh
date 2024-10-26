#!/bin/bash

function notify() {
  dunstify --appname="i3wm" "$1"
}

function start_initial() {
  # Start XDG autostart .desktop files using dex. See also
  # https://wiki.archlinux.org/index.php/XDG_Autostart
  dex --autostart --environment i3

  # Launch ibus
  ibus-daemon -d

  pulseaudio --start
  bluetoothctl power on

  # protonmail-bridge &
  syncthing
}

if [ "$1" == "initial" ]
then
  # Only run when starting i3 for the first time
  notify "Setting up Desktop Environment ..."
  start_initial &
else
  notify "Reloading Desktop Environment ..."
fi

killall dunst && sleep 1 && dunst

# Set desktop wallpapers
feh --bg-scale -g 3840x1440 ~/.background/mountains-blue-and-beige.jpg \
  -g 1920x1080 ~/.background/mountains-blue-and-gold.jpg

# Launch picom compositor
killall -q picom && sleep 1
picom --experimental-backends --config "$XDG_CONFIG_HOME/i3/picom.conf" && sleep 1
