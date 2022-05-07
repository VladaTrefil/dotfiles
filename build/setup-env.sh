#!/bin/bash

PERMISSION="$(echo "$USER all=(all) nopasswd: all" | tr '[:lower:]' '[:upper:]')"
if [ -z "$(sudo cat /etc/sudoers | grep -o "`echo $PERMISSION`")" ]; then
  echo "add $USER to sudoers"
  echo $PERMISSION | sudo tee -a /etc/sudoers
fi

fc-cache -f

chmod +x $HOME/.xresources

sudo cp $HOME/development/dotfiles/xorg/plasma-i3.desktop /usr/share/xsessions/plasma-i3.desktop
