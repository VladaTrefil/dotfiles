#!/bin/bash

if [ -f "$(which apt)" ]; then
  if [ ! -f "$(which zsh)" ]; then
    echo 'Installing ZSH...'
    sudo apt install zsh
  fi

  if [ ! -f "$(which curl)" ]; then
    echo 'Installing Curl...'
    sudo apt install curl
  fi
fi

export ZSH="$HOME/.config/oh-my-zsh"
if [ ! -d "$ZSH" ]; then
  echo 'Installing Oh-My-Zsh...'
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
fi

# Change default shell
if ! grep -q zsh "$SHELL"
then
  echo 'Changing default shell to zsh'
  sudo chsh -s /bin/zsh "$USER"
fi
