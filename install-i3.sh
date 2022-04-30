#!/bin/bash

BASE_PATH=${pwd}

if [ ! -f "`which i3`" ]; then
  git clone https://github.com/Airblader/i3.git ./i3-gaps
  cd ./i3-gaps
  mkdir -p ./build && cd ./build
  meson --prefix /usr/local
  ninja
  sudo ninja install
  cd $BASE_PATH
fi
