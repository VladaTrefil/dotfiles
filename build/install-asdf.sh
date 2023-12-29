#!/bin/bash

if [ ! -f "$(which asdf)" ]; then
  echo "Installing asdf"
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch v0.10.2

  if [ -f "$ASDF_DIR/asdf.sh" ]; then
    echo "Sourcing asdf.sh"
    source "$ASDF_DIR/asdf.sh"
  fi
fi
