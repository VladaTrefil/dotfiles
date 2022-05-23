#!/bin/bash

PERMISSION="$(echo "$USER all=(all) nopasswd: all" | tr '[:lower:]' '[:upper:]')"
if [ -z "$(sudo cat /etc/sudoers | grep -o "`echo $PERMISSION`")" ]; then
  echo "add $USER to sudoers"
  echo $PERMISSION | sudo tee -a /etc/sudoers
fi

# Disable ipv6
if [ -z "$(sudo cat /etc/sysctl.conf | grep -o "net.ipv6.conf.all.disable_ipv6 = 1")" ]; then
  echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
fi

# Build font cache
fc-cache -f

# Reload Sysctl config
sudo sysctl -p

chmod +x $XDG_CONFIG_HOME/x11/xresources

echo $DOTFILES_PATH
sudo cp $DOTFILES_PATH/config/x11/plasma-i3.desktop /usr/share/xsessions/plasma-i3.desktop

rm $HOME/.zsh*
rm $HOME/.bash*
rm $HOME/.profile
rm $HOME/.mkshrc
rm $HOME/.xsession-errors

rm -rf $HOME/Desktop
rm -rf $HOME/Templates
rm -rf $HOME/Pictures
rm -rf $HOME/Public
