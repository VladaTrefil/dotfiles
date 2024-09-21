#!/bin/bash

mkdir ./tmp

BASE_DIR="$(pwd)"

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Python: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "───  Python:"

if [ -f "$(which python3)" ]; then
  echo "  core installed"

  printf "\nExtensions:\n"

  packages=("pynvim" "yarp" "speedtest-cli" "yt-dlp" "ranger-fm" "mercurial" "i3ipc" "blue" "pylint" "mypy" "isort")
  installed_packages=$(pip list)

  for package in "${packages[@]}"; do
    if [[ "$installed_packages" != *$package* ]]; then
      echo "─ adding $package"
      pip install "$package"
    else
      echo "  $package"
    fi
  done
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


# sh ./standalone/_git.sh
#https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -rf ./tmp
