#!/bin/bash

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Python: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "───  Python:"

if [ -f "$(which python3)" ]; then
  echo "  core installed"

  printf "\nExtensions:\n"

  packages=("pynvim" "yarp" "mercurial" "i3ipc" "blue" "pylint" "mypy" "isort")
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
# Rust and cargo: {{{

printf "\n────────────────────────────────────────────────────────────────────────────────────────────────────\n"
echo "───  Rust:"

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
