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

# Check if RVM is installed
if [ -z "$rvm_version" ]; then
  echo 'Installing RVM'
  gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable
fi

if [ -z "$rvm_version" ]; then
  echo 'Installing Ruby v2.6.6 & v2.6.8'
  rvm install ruby "2.6.6"
  rvm install ruby "2.6.8"
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

# Install lens
if [ ! -f "`which lens`" ]; then
  echo 'Install Lens'
  mkdir tmp_install
  wget -O tmp_install/lens.deb https://lens-binaries.s3-eu-west-1.amazonaws.com/ide/Lens-5.3.4-latest.20220120.1.amd64.deb
  sudo dpkg -i "tmp_install/lens.deb"
  sudo apt install -f
  rm -rf tmp_install
fi