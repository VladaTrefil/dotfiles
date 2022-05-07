#!/bin/bash

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
