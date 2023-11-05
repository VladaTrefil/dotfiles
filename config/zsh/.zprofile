#!/bin/bash

if [ -f "$HOME/.config/shell/profile" ]; then
  emulate sh -c "source $HOME/.config/shell/profile"
fi

if [ -f "$DOTFILES_PATH/.secret-env" ]; then
  emulate sh -c "source $DOTFILES_PATH/.secret-env"
fi
