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
# ASDF: {{{

echo "────────────────────────────────────────────────────────────────────────────────────────────────────"
echo "───  ASDF:"

if [ ! -f "`which asdf`" ]; then
  echo "─ installing asdf"
  git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch v0.10.2

  if [ -f "$ASDF_DIR/asdf.sh" ]; then
    echo "─ sourcing asdf.sh"
    . $ASDF_DIR/asdf.sh
  fi
else
  echo "  core installed"
fi

if [ -f "$ASDF_DIR/asdf.sh" ]; then
  echo "──  Ruby:"

  if [ -z "$(asdf plugin list | grep -o ruby)" ]; then
    echo
    echo "─ adding ruby plugin"
    asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
  else
    echo "  ruby plugin"
  fi

  # versions=("2.6.0" "2.6.6" "2.6.8" "2.6.9" "2.7.5" "3.0.0" "3.1.1" "3.1.2")
  versions=("2.6.8")
  installed_versions=$(asdf list ruby)

  for v in ${versions[@]}; do
    if [ -z "$(echo $installed_versions | grep -o $v)" ]; then
      printf "─ adding $v \n"
      asdf install ruby $v
      echo $GEM_HOME
      gem install bundler
    else
      echo "  $v"
    fi
  done

  printf "\n─ Gems:\n"

  gems=("rails" "neovim" "solargraph" "prettier")
  installed_gems="$(gem list --local)"

  for gem in ${gems[@]}; do
    if [ -z "$(echo $installed_gems | grep -o $gem)" ]; then
      printf "\n─ adding $gem"
      if [ $gem == "rails" ]; then
        gem install rails:6.1.4
      else
        gem install $gem
      fi
    else
      echo "  $gem"
    fi
  done
else
  echo "asdf script not found"
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
  pip install speedtest-cli
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


rm -rf ./tmp
