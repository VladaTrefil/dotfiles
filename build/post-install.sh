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

sudo systemctl enable bluetooth

sudo chmod 775 /var/lib/postgres
sudo chown postgres /var/lib/postgres
sudo -u postgres initdb -D '/var/lib/postgres/data'
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo -u postgres createuser -s -P vlada
