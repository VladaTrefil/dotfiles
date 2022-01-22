#!/bin/bash

# Check if Homebrew is installed
if [ ! -f "`which brew`" ]; then
  echo 'Installing homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check if TMUX is installed
if [ ! -f "`which tmux`" ]; then
  echo 'Installing tmux'
  brew install tmux
fi

# Check if NVIM is installed
if [ ! -f "`which nvim`" ]; then
  echo 'Installing nvim'
  brew install nvim
fi

# Check if oh-my-zsh is installed
OMZDIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZDIR" ]; then
  echo 'Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

if [ -f "`sudo cat /etc/sudoers`" ]; then
  echo "add $USER to sudoers"
  echo "$USER   all=(all) nopasswd: all" | tr '[:lower:]' '[:upper:]' | sudo tee -a /etc/sudoers
fi

# Change default shell
if [ -z "`echo $SHELL | grep zsh`" ]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh
else
  echo 'Already using zsh'
fi

# Config bat
if [ -d "$(bat --config-dir)" ]; then
  ln -s "$HOME/development/dotfiles/config/bat" "$(bat --config-dir)"
  bat cache --build
  bat --list-themes
fi