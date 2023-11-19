#!/bin/bash

GIT_URL="https://github.com/git/git/archive/refs/tags/v2.42.0.tar.gz"

if [ ! -f "$(which git)" ]; then
  if [ ! -d ./tmp ]; then
    mkdir ./tmp
  fi

  cd ./tmp || exit

  echo 'Installing Git...'

  wget -O git-source.tar.gz "$GIT_URL"
  tar -zxf git-source.tar.gz

  cd ./git-2.42.0 || exit

  make configure
  ./configure --prefix=/usr

  make all doc info
  sudo make install install-doc install-html install-info

  cd ../../ || exit

  echo "  Git installed"
else
  echo "-  Git already installed"
fi
