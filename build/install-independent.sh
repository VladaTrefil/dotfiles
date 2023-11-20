#!/bin/bash

mkdir ./tmp

BASE_DIR="$(pwd)"

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Brew: {{{

if [ ! -f "$(which brew)" ]; then
  echo 'Installing Homebrew...'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -s "$HOMEBREW_PREFIX/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  if [ -f "$(which brew)" ]; then
    if [ ! -f "$HOMEBREW_PREFIX/bin/nvim" ]; then
      echo 'Installing Nvim...,'
      brew install -q neovim

      # use version in apt
      brew uninstall --ignore-dependencies readline
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
  echo "$HOMEBREW_PREFIX not found"
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Python: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "───  Python:"

if [ -f "$(which python3)" ]; then
  echo "  core installed"

  printf "\nExtensions:\n"

  packages=("pynvim" "yarp" "speedtest-cli" "yt-dlp" "ranger-fm")
  installed_packages=$(pip list)

  for package in "${packages[@]}"; do
    if [[ "$installed_packages" != *$package* ]]; then
      echo "─ adding $package"
      pip install "$package"
    else
      echo "  $package"
    fi
  done

  python3 -m pip install -U yt-dlp
  python3 -m pip install -U mercurial
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Youtube-dl: {{{

if [ ! -f "$(which youtube-dl)" ]; then
  echo 'Installing Youtube-DL...'
  sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
  sudo chmod a+rx /usr/local/bin/youtube-dl
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Dunst: {{{

if [ ! -f "$(which dunst)" ]; then
  git clone https://github.com/dunst-project/dunst.git tmp/dunst
  cd tmp/dunst || ! echo "dunst installer not found"
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

if [ ! -f "$ETCHER_PATH" ]; then
  echo "Installing Etcher..."
  curl -L $ETCHER_URL -o ./tmp/etcher.zip
  unzip -o ./tmp/etcher.zip '*' -d ./tmp  && mv ./tmp/balena* "$ETCHER_PATH"
  chmod a+rx "$ETCHER_PATH"
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
# Rust and cargo: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "───  Rust:"

if [ ! -f "$(which rustc)" ]; then
  echo "─ Installing rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
  echo "  core installed"
fi

# Stylua - Formatting for lua
if [ -f "$(which rustc)" ]; then
  if [ -f "$(which cargo)" ]; then
    printf "\nCargo packages:\n"

    packages=("stylua")

    for package in "${packages[@]}"; do
      if [[ "$(cargo search --quiet --limit 1 "$package")" != *$package* ]]; then
        echo "─ adding $package"
        pip install "$package"
      else
        echo "  $package"
      fi
    done
  fi
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Neovim add-ons: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "──  Neovim:"

PACKER_URL="https://github.com/wbthomason/packer.nvim"
PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

if [ ! -d "$PACKER_DIR" ]; then
  printf "\n─ installing Packer: \n"
  git clone --depth 1 "$PACKER_URL" "$PACKER_DIR"
else
  echo "  Packer"
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Anki: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "──  Anki:"

ANKI_URL="https://github.com/ankitects/anki/releases/download/2.1.65/anki-2.1.65-linux-qt6.tar.zst"
ANKI_INSTALLER_FILE_NAME="anki-2.1.65-linux-qt6"

if [ ! -f "$(which anki)" ]; then
  cd ./tmp || return

  if [ ! -f "./$ANKI_INSTALLER_FILE_NAME.tar.zst" ]; then
    wget -O "$ANKI_INSTALLER_FILE_NAME.tar.zst" $ANKI_URL
  fi

  if [ -f "./$ANKI_INSTALLER_FILE_NAME.tar.zst" ]; then
    printf "\n─ installing Anki:\n"
    tar xaf "$ANKI_INSTALLER_FILE_NAME.tar.zst"
    cd "./$ANKI_INSTALLER_FILE_NAME" || return
    sudo ./install.sh
  else
    echo "file not found"
  fi

  cd "$BASE_DIR" || return
else
  echo "  installed"
fi

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Rofi: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "──  Rofi:"

if [ ! -f "$(which rofi)" ]; then
  cd ./tmp || exit

  # use brew if fails
  if [ ! -f "/usr/local/lib/libcheck.la" ]; then
    git clone git@github.com:libcheck/check.git
    git checkout 673dce1d61781c32b449bef0ee8711dc7e689170
    git submodule update --init

    mkdir ./check/build
    cd ./check/build || exit

    autoreconf --install
    ../configure

    make
    sudo make install
    sudo ldconfig
  fi

  git clone git@github.com:davatorium/rofi.git
  git checkout 48ea818c699cd6d1424f4e98ec9236da4483f951
  git submodule update --init

  if [ -d "./rofi" ]; then
    printf "\n─ installing rofi:\n"

    mkdir ./rofi/build
    cd ./rofi/build || exit

    autoreconf -i
    ../configure

    make
    sudo make install
  else
    echo "file not found"
  fi

  cd "$BASE_DIR" || exit
else
  echo "  installed"
fi


# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# QMK: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "──  QMK:"

if [ ! -f "$BIN_PATH/qmk" ]; then
  echo "Installing QMK"

  #Install
  python3 -m pip install --user qmk

  if [ -f "$BIN_PATH/qmk" ]; then
    qmk setup -y -H "$XDG_DATA_HOME/qmk"
    qmk config user.keyboard=ergodox_ez/glow
  fi
else
  echo "  installed"
fi


# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

sh ./standalone/_git.sh

#https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# rm -rf ./tmp
