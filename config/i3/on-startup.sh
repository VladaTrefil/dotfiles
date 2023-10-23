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

  syncthing

  start_dunst &
}

function start_eww() {
  sh "$XDG_CONFIG_HOME/eww/bar/launch_bar"
}

function start_picom() {
  picom --experimental-backends --config "$XDG_CONFIG_HOME/i3/picom.conf"
}

function start_dunst() {
  dunst
}

function set_background() {
  feh --bg-scale -g 3840x1440 ~/.background/mountains-blue-and-beige.jpg \
                 -g 1920x1080 ~/.background/mountains-blue-and-gold.jpg

}

killall -q dunst
killall -q eww
killall -q picom
sleep 1

if [ "$1" == "initial" ]
then
  start_initial
fi

set_background
start_picom &
sleep 1
start_eww &
