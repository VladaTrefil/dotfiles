#!/bin/bash

if [ ! -f "$(which stylua)" ]; then
  echo 'Installing Stylua...'
  cargo install stylua
fi

ZSH="$HOME/.local/share/oh-my-zsh"

if [ ! -d "$ZSH" ]; then
  echo 'Installing Oh-My-Zsh...'
  git clone https://github.com/ohmyzsh/ohmyzsh.git $ZSH
fi
