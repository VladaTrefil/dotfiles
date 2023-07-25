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
# ASDF: {{{

echo "────────────────────────────────────────────────────────────────────────────────────────────────────"
echo "───  ASDF:"

if [ ! -f "$(which asdf)" ]; then
  echo "─ installing asdf"
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch v0.10.2

  if [ -f "$ASDF_DIR/asdf.sh" ]; then
    echo "─ sourcing asdf.sh"
    source "$ASDF_DIR/asdf.sh"
  fi
else
  echo "  core installed"
fi

if [ -f "$ASDF_DIR/asdf.sh" ]; then
  printf "\n──  Ruby:\n"

  if [[ "$(asdf plugin list)" != *ruby* ]]; then
    echo "─ adding asdf plugin"

    asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
  else
    echo "  asdf plugin"
  fi

  versions=("2.6.0" "2.6.6" "2.6.8" "2.6.9" "2.7.5" "3.0.0" "3.1.1" "3.1.2")
  installed_versions=$(asdf list ruby)

  for v in "${versions[@]}"; do
    if [[ "$installed_versions" != *$v* ]]; then
      printf "─ adding %s \n", "$v"

      asdf install ruby "$v"

      echo "$GEM_HOME"
      gem install bundler
    else
      echo "  $v"
    fi
  done

  printf "\nGems:\n"

  gems=("rails" "spring" "neovim" "solargraph" "prettier")
  installed_gems="$(gem list --local)"

  for gem in "${gems[@]}"; do
    if [[ "$installed_gems" != *$gem* ]]; then
      printf "\n─ adding %s", "$gem"

      if [ "$gem" == "rails" ]; then
        gem install rails:6.1.4
      else
        gem install "$gem"
      fi
    else
      echo "  $gem"
    fi
  done

  printf "\n──  Java:\n"

  if [[ "$(asdf plugin list)" != *java* ]]; then
    echo "─ adding java plugin"
    asdf plugin-add java https://github.com/halcyon/asdf-java.git
  else
    echo "  java plugin"
  fi

  versions=("openjdk-17.0.2")
  installed_versions=$(asdf list java)

  for v in "${versions[@]}"; do
    if [[ "$installed_versions" != *$v* ]]; then
      printf "─ adding %s \n", "$v"
      asdf install java "$v"
    else
      echo "  $v"
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
    export NVM_DIR="$XDG_CONFIG_HOME/nvm" && source "$NVM_DIR/nvm.sh"

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

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "───  Python:"

if [ -f "$(which python3)" ]; then
  echo "  core installed"

  printf "\nExtensions:\n"

  packages=("pynvim" "yarp" "speedtest-cli" "yt-dlp")
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

#https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# rm -rf ./tmp
