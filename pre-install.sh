#!/bin/bash

# if [ -f "`which apt`" ]; then
#   sudo apt install zsh curl
# fi

# Check if Homebrew is installed
if [ ! -f "`which brew`" ]; then
  echo 'Installing homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check if oh-my-zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo 'Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

PERMISSION="$(echo "$USER all=(all) nopasswd: all" | tr '[:lower:]' '[:upper:]')"
if [ -z "$(sudo cat /etc/sudoers | grep -o "`echo $PERMISSION`")" ]; then
  echo "add $USER to sudoers"
  echo $PERMISSION | sudo tee -a /etc/sudoers
fi

# Change default shell
if [ -z "`echo $SHELL | grep zsh`" ]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh
fi

# Check if NVIM is installed
if [ -f "`which brew`" ]; then
  if [ ! -f "$HOMEBREW_PREFIX/bin/nvim" ]; then
    echo 'Installing Nvim...,'
    brew install -q neovim
  fi

  if [ ! -f "$HOMEBREW_PREFIX/bin/lazygit" ]; then
    echo 'Installing lazygit...,'
    brew install -q lazygit
  fi

  if [ ! -f "$HOMEBREW_PREFIX/bin/bat" ]; then
    echo 'Installing bat...,'
    brew install -q bat
  fi
fi

PLUG_DIR='"${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim'
if [ -f "$PLUG_DIR" ]; then
  echo 'Installing Vim-plug...'
  sh -c 'curl -fLo $PLUG_DIR --create-dirs \
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

# Check if RVM is installed
if [ ! -f "`which rvm`" ]; then
  echo 'Installing RVM...'
  gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable
  source $HOME/.rvm/scripts/rvm

  if [ -f "`which rvm`" ]; then
    echo 'Installing Ruby versions...'
    rvm install ruby "2.6.6 2.6.8 3.0.0"
  fi
fi


if [ ! -d "$NVM_DIR" ]; then
  echo 'Installing NVM...'
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
  export NVM_DIR="$HOME/.nvm" && \. "$NVM_DIR/nvm.sh"
  echo 'Installing NodeJS versions...'
  nvm install 14
  sudo npm install -g yarn
fi

if [ ! -f "`which youtube-dl`" ]; then
  sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
  sudo chmod a+rx /usr/local/bin/youtube-dl
fi

ETCHER_URL="https://github.com/balena-io/etcher/releases/download/v1.7.9/balena-etcher-electron-1.7.9-linux-x64.zip"
ETCHER_PATH="/home/vlada/Images/balenaEtcher.appImage"

if [ ! -f $ETCHER_PATH ]; then
  curl -L $ETCHER_URL -o ./etcher.zip
  unzip ./etcher.zip '*' -d $ETCHER_PATH
  rm ./etcher.zip
fi
