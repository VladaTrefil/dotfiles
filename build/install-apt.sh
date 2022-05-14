#!/bin/zsh

if [ ! -f "`which apt`" ]; then
  echo "SKIP - Apt is not installed" >&2
  exit  1
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

APT_PACKAGES=(
  "python3-dev"
  "build-essential"
  "ripgrep" # Command line search

  # Desktop enviroment
  "polybar"
  "rofi"
  "feh"
  "picom"
  "bc" # terminal calculation function

  # Sinfin libs
  "postgresql"
  "postgresql-contrib"
  "libpq-dev"
  "imagemagick"
  "libmagick++-dev"
  "libmagickwand-dev"
  "libmagickcore-dev"
  "libimage-exiftool-perl"
  "rubber"
  "texlive-xetex"
  "libsodium-dev"
  "pdftk"
  "ghostscript"
  "redis-server"
  "libvips42"
  "gifsicle"
  "libwebp-dev"
  "webp"

  # Apps
  "konsole"
  "syncthing"
  "inkscape"
  "ffmpeg"
  "brave-browser"

  # NVIM
  "pip" # pip install pynvim
  "xclip" # terminal clipboard
)

if [ ! -f "`which brave-browser`" ]; then
  sudo apt install apt-transport-https curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
fi

for p in $APT_PACKAGES; do
  if [ $(dpkg-query -W -f='${Status}' $p 2>/dev/null | grep -c "ok installed") = "0" ]; then
    echo "\n============================================================================="
    echo -e "Installing ${GREEN}$p${NC}..."
    sudo apt-get install $p -y --no-upgrade | grep -oP "^.*upgraded.*$"
    echo -e "${GREEN}Installed $p${NC}"
    echo "=============================================================================\n"
  else
    echo -e "${GREEN}$p${NC} already exists"
  fi
done

# Unofficial repos

mkdir tmp_install

# Install lens
if [ ! -f "`which lens`" ]; then
  echo 'Install Lens'
  wget -O tmp_install/lens.deb https://lens-binaries.s3-eu-west-1.amazonaws.com/ide/Lens-5.3.4-latest.20220120.1.amd64.deb
  sudo dpkg -i "tmp_install/lens.deb"
fi

sudo apt install -f
rm -rf tmp_install
