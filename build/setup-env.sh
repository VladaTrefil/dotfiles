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

# Add hosts
if [ -z "$(cat /etc/hosts | grep -of "$DOTFILES_PATH/config/hosts")" ]; then
  cat "$DOTFILES_PATH/config/hosts" | sudo tee -a /etc/hosts
fi

if [ ! -f "/usr/share/xsessions/plasma-i3.desktop" ]; then
  sudo cp $DOTFILES_PATH/config/x11/plasma-i3.desktop /usr/share/xsessions/plasma-i3.desktop
fi

if [ ! -f "$XDG_CONFIG_HOME/x11/xresources" ]; then
  chmod +x $XDG_CONFIG_HOME/x11/xresources
fi

# Build font cache
fc-cache -f

# Reload Sysctl config
sudo sysctl -p

# Cleanup
[[ -s "$HOME/.zshrc" ]] && rm $HOME/.zsh*
[[ -s "$HOME/.bashrc" ]] && rm $HOME/.bash*
[[ -s "$HOME/.profile" ]] && rm $HOME/.profile
[[ -s "$HOME/.mkshrc" ]] && rm $HOME/.mkshrc

rm -rf $HOME/Desktop
rm -rf $HOME/Templates
rm -rf $HOME/Public
