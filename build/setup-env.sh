#!/bin/bash

PERMISSION="$(echo "$USER all=(all) nopasswd: all" | tr '[:lower:]' '[:upper:]')"

if ! sudo grep -qo "$PERMISSION" /etc/sudoers
then
  echo "add $USER to sudoers"
  echo "$PERMISSION" | sudo tee -a /etc/sudoers
fi

# Disable ipv6
if ! grep -qo "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf
then
  echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
fi

# Add hosts
if ! grep -of "$DOTFILES_PATH/config/hosts" /etc/hosts
then
  cat "$DOTFILES_PATH/config/hosts" | sudo tee -a /etc/hosts
fi

if [ ! -f "/usr/share/xsessions/plasma-i3.desktop" ]; then
  sudo cp "$DOTFILES_PATH/config/x11/plasma-i3.desktop" "/usr/share/xsessions/plasma-i3.desktop"
fi

if [ ! -f "$XDG_CONFIG_HOME/x11/xresources" ]; then
  chmod +x "$XDG_CONFIG_HOME/x11/xresources"
fi

# Build font cache
fc-cache -f

# Reload Sysctl config
sudo sysctl -p

# Disable gnome keyboard layout switcher window
if [ -f "$(which ibus)" ]; then
  gsettings set org.freedesktop.ibus.general switcher-delay-time '-1'
fi

# Cleanup
[[ -f "$HOME/.zshrc" ]] && rm "$HOME/.zshrc"
[[ -f "$HOME/.bashrc" ]] && rm "$HOME/.bashrc"
[[ -f "$HOME/.profile" ]] && rm "$HOME/.profile"
[[ -f "$HOME/.mkshrc" ]] && rm "$HOME/.mkshrc"

rm -rf "$HOME/Desktop"
rm -rf "$HOME/Templates"
rm -rf "$HOME/Public"
