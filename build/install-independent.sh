#!/bin/bash

mkdir ./tmp

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Brew: {{{

if [ ! -f "`which brew`" ]; then
  echo 'Installing Homebrew...'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -s "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  if [ -f "`which brew`" ]; then
    if [ ! -f "$HOMEBREW_PREFIX/bin/nvim" ]; then
      echo 'Installing Nvim...,'
      brew install -q neovim

      PLUG_DIR="$XDG_DATA_HOME/nvim/site/autoload/plug.vim"
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
  else
    echo "brew isn't a command"
  fi
else
  echo "/home/linuxbrew/.linuxbrew/bin/brew not found"
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# RVM: {{{

# Check if RVM is installed
if [ ! -f "`which rvm`" ]; then
  echo 'Installing RVM...'
  gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable

  if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    . "$HOME/.rvm/scripts/rvm"

    export PATH="$PATH:$HOME/.rvm/bin"

    if [ -f "`which rvm`" ]; then
      echo 'Installing Ruby versions...'
      rvm use 3.0.0 --default --install
      # rvm use 2.6.6 --default --install
      # rvm use 2.6.8 --default --install

      echo 'Installing rails...'
      gem install rails:6.1.4

      echo 'Installing bundler...'
      gem install bundler:2.2.32

      echo 'Installing neovim...'
      gem install neovim

      echo 'Installing solargraph...'
      gem install --user-install solargraph
    else
      echo "rvm command does not exist."
    fi
  else
    echo "$HOME/.rvm/scripts/rvm" could not be found.
  fi
fi



# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# NVM: {{{

if [ ! -d "$NVM_DIR" ]; then
  echo 'Installing NVM...'
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash | grep -G "\d*"

  if [[ -d "$XDG_CONFIG_HOME/nvm" ]]; then
    export NVM_DIR="$XDG_CONFIG_HOME/nvm" && \. "$NVM_DIR/nvm.sh"

    echo 'Installing NodeJS versions...'
    nvm install 16 --default
    nvm install 14

    echo 'Installing npm packages...'
    # npm install --location=global yarn neovim prettier
  else
    echo "nvm directory does not exist."
  fi
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Python: {{{

if [ -f `which python3` ]; then
  echo 'Installing Python extensions...'
  pip install pynvim
  pip install yarp
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Youtube-dl: {{{

if [ ! -f "`which youtube-dl`" ]; then
  echo 'Installing Youtube-DL...'
  sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
  sudo chmod a+rx /usr/local/bin/youtube-dl
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Dunst: {{{

if [ ! -f "`which dunst`" ]; then
  git clone https://github.com/dunst-project/dunst.git tmp/dunst
  cd tmp/dunst
  make
  sudo make install
  cd ../..
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Etcher: {{{

ETCHER_PATH="$HOME/Images/balenaEtcher.AppImage"
ETCHER_URL="https://github.com/balena-io/etcher/releases/download/v1.7.9/balena-etcher-electron-1.7.9-linux-x64.zip"
if [ ! -f $ETCHER_PATH ]; then
  echo "Installing Etcher..."
  curl -L $ETCHER_URL -o ./tmp/etcher.zip
  unzip -o ./tmp/etcher.zip '*' -d ./tmp  && mv ./tmp/balena* $ETCHER_PATH
  chmod a+rx $ETCHER_PATH
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Syncthing: {{{

SYNCTHING_KEY_DIR=/usr/share/keyrings/syncthing-archive-keyring.gpg

if [ ! -f "$SYNCTHING_KEY_DIR" ]; then
  echo 'Adding Synthing GPG...'
  sudo curl -s -o $SYNCTHING_KEY_DIR https://syncthing.net/release-key.gpg
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# EWW: {{{

# if [ ! -f "which rustc" ]; then
#   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# fi
#
# if [ -f "which cargo" ] && [ ! -f "which eww" ]; then
#   git clone https://github.com/elkowar/eww tmp/eww
#   cd tmp/eww
#   cargo build --release
# fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

rm -rf ./tmp
