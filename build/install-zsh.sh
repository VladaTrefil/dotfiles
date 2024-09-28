#!/bin/bash

# Change default shell
if ! grep -q zsh "$SHELL"
then
  echo 'Changing default shell to zsh'
  sudo chsh -s /bin/zsh "$USER"
fi
