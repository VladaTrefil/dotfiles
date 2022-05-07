#!/bin/bash

if [ -f "`which apt`" ]; then
  if [ ! -d $ZSH ]; then
    echo 'Installing ZSH...'
    sudo apt install zsh
  fi

  if [ ! -f "`which curl`" ]; then
    echo 'Installing Curl...'
    sudo apt install curl
  fi
fi

OMZDIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZDIR" ]; then
  echo 'Installing Oh-My-Zsh...'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# Change default shell
if [ -z "`echo $SHELL | grep zsh`" ]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh

  source $HOME/.zlogin
  source $HOME/.zshrc
fi
