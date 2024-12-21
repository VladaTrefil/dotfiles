#!/bin/bash

function notify() {
  dunstify --appname="i3wm" "$1"
}

function start_initial() {
  # Start XDG autostart .desktop files using dex. See also
  # https://wiki.archlinux.org/index.php/XDG_Autostart

  # Launch ibus
  ibus-daemon -d &

  bluetoothctl power on &

  # protonmail-bridge &
  syncthing &

  eww daemon &> /dev/null
  while [ -z  "$(eww ping 2> /dev/null)" ]; do
    sleep 0.2s
  done

  # Open window
  eww open bar &> /dev/null

  touch "$HOME/testing-eww.txt"
}

picom --config "/home/vlada/.config/i3/picom.conf" &

if [ "$1" == "initial" ]
then
  # Only run when starting i3 for the first time
  notify "Setting up Desktop Environment ..."
  start_initial &
else
  notify "Reloading Desktop Environment ..."
fi

killall dunst && sleep 1 && dunst &

# Set desktop wallpapers, if fehbg exists
if [ -f ~/.fehbg ]; then
  ~/.fehbg &
else
  feh --bg-scale -g 3840x1440 ~/.background/mountains-blue-and-beige.jpg \
    -g 1920x1080 ~/.background/mountains-blue-and-gold.jpg &
fi
echo "feh"

# Launch picom compositor
eww reload &
