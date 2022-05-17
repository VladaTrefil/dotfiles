#!/bin/bash

# =====================================================================================================================================================
# Brew: {{{

if [ ! -f "`which brew`" ]; then
  echo 'Installing Homebrew...'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -f "`which brew`" ]; then
  if [ ! -f "$HOMEBREW_PREFIX/bin/nvim" ]; then
    echo 'Installing Nvim...,'
    brew install -q neovim

    PLUG_DIR='"${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim'
    if [ -f "$PLUG_DIR" ]; then
      echo 'Installing Vim-plug...'
      sh -c 'curl -fLo $PLUG_DIR --create-dirs \
             https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    fi
  fi

  if [ ! -f "$HOMEBREW_PREFIX/bin/lazygit" ]; then
    echo 'Installing lazygit...,'
    brew install -q lazygit
  fi

  if [ ! -f "$HOMEBREW_PREFIX/bin/bat" ]; then
    echo 'Installing bat...,'
    brew install -q bat
    bat cache --build
  fi
fi

# }}}
# =====================================================================================================================================================

# =====================================================================================================================================================
# Rvm: {{{

# Check if RVM is installed
if [ ! -f "`which rvm`" ]; then
  echo 'Installing RVM...'
  gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable
  source $HOME/.rvm/scripts/rvm

  if [ -f "`which rvm`" ]; then
    echo 'Installing Ruby versions...'
    rvm install ruby "2.6.6 2.6.8 3.0.0"

    echo 'Installing rails...'
    gem install rails -v "6.1.4", 

    echo 'Installing bundler...'
    gem install bundler -v "2.2.32"
  fi
fi

# }}}
# =====================================================================================================================================================

# =====================================================================================================================================================
# NVM: {{{

if [ ! -d "$NVM_DIR" ]; then
  echo 'Installing NVM...'
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
  export NVM_DIR="$HOME/.nvm" && \. "$NVM_DIR/nvm.sh"

  echo 'Installing NodeJS versions...'
  nvm install 14

  echo 'Installing yarn...'
  sudo npm install -g yarn

  echo 'Installing Node neovim...'
  yarn global add neovim
fi

# }}}
# =====================================================================================================================================================

# =====================================================================================================================================================
# Etcher: {{{

ETCHER_PATH="$HOME/Images/balenaEtcher.AppImage"
ETCHER_URL="https://github.com/balena-io/etcher/releases/download/v1.7.9/balena-etcher-electron-1.7.9-linux-x64.zip"
if [ ! -f $ETCHER_PATH ]; then
  echo "Installing Etcher..."
  mkdir ./tmp
  curl -L $ETCHER_URL -o ./tmp/etcher.zip
  unzip -o ./tmp/etcher.zip '*' -d ./tmp  && mv ./tmp/balena* $ETCHER_PATH
  chmod a+rx $ETCHER_PATH
  rm -rf ./tmp
fi

# }}}
# =====================================================================================================================================================

# =====================================================================================================================================================
# Python: {{{

if [ -f `which python3` ]; then
  echo 'Installing Python extensions...'
  pip install pynvim
  pip install yarp
fi

# }}}
# =====================================================================================================================================================

# =====================================================================================================================================================
# Youtube-dl: {{{

if [ ! -f "`which youtube-dl`" ]; then
  echo 'Installing Youtube-DL...'
  sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
  sudo chmod a+rx /usr/local/bin/youtube-dl
fi

# }}}
# =====================================================================================================================================================

# =====================================================================================================================================================
# Syncthing: {{{

SYNCTHING_KEY_DIR=/usr/share/keyrings/syncthing-archive-keyring.gpg

if [ ! -f "$SYNCTHING_KEY_DIR" ]; then
  echo 'Adding Synthing GPG...'
  sudo curl -s -o $SYNCTHING_KEY_DIR https://syncthing.net/release-key.gpg
fi

# }}}
# =====================================================================================================================================================