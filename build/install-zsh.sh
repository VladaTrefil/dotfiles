#!/bin/bash

if [ -f "`which apt`" ]; then
  if [ ! -f "`which zsh`" ]; then
    echo 'Installing ZSH...'
    sudo apt install zsh
  fi

  if [ ! -f "`which curl`" ]; then
    echo 'Installing Curl...'
    sudo apt install curl
  fi
fi

OMZDIR="$HOME/.config/oh-my-zsh"
if [ ! -d "$OMZDIR" ]; then
  echo 'Installing Oh-My-Zsh...'
  git clone https://github.com/ohmyzsh/ohmyzsh.git $OMZDIR
fi

# Change default shell
if [ -z "`echo $SHELL | grep zsh`" ]; then
  echo 'Changing default shell to zsh'
  sudo chsh -s /bin/zsh $USER
fi
