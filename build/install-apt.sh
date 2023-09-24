#!/bin/zsh

if [ ! -f "`which apt`" ]; then
  echo "SKIP - Apt is not installed" >&2
  exit  1
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

APT_PACKAGES=(
  "build-essential"

  # Desktop environment
  "i3-gaps"
  "picom-tryone"
  # "rofi" -- from source v1.7.4
  "feh"
  "dunst"

  # Terminal functions
  "git"
  "bc" # calculation function
  "ripgrep" # Command line search
  "unzip"
  "xclip" # Clipboard
  "ifstat" #Network speedtest
  "jq" # json parser
  "moreutils" # Useful shell functions https://joeyh.name/code/moreutils/
  "rename" # bulk rename files
  "speedtest-cli"
  "mason"

  # Terminal code interpreters
  "python3-dev"
  "python-is-python3"
  "lua5.3:i386"

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
  "libvips-dev"
  "gifsicle"
  "libwebp-dev"
  "webp"

  # ASDF dependencies
  "libdb5.3-dev"

  # Dunst
  "libdbus-1-dev"
  "libx11-dev"
  "libxinerama-dev"
  "libxrandr-dev"
  "libxss-dev"
  "libglib2.0-dev"
  "libpango1.0-dev"
  "libgtk-3-dev"
  "libxdg-basedir-dev"
  "libnotify-dev"

  # Eww
  "libgtk-3-dev"
  "libpango-1.0-0"
  "libgdk-pixbuf2.0-dev"
  "libpangocairo-1.0-0"
  "libglib2.0-dev"

  # Apps
  "konsole"
  "syncthing"
  "inkscape"
  "ffmpeg"
  "brave-browser"
  "thunderbird"

  # NVIM
  "pip" # pip install pynvim

  # Anki cards
  "zstd"

  # Rofi dependencies
  "flex"
  "libglib2.0-dev"
  "libxcb-util0-dev"
  "libxcb-ewmh-dev"
  "libxcb-imdkit-dev"
  "libxcb-xkb-dev"
  "libxkbcommon-x11-dev"
  "libxcb-icccm4-dev"
  "libxcb-cursor-dev"
  "libxcb-randr0-dev"
  "libxcb-xinerama0-dev"
  "libstartup-notification0-dev"
  "texinfo"

  # QMK dependencies
  "gcc"
  "unzip"
  "wget"
  "zip"
  "gcc-avr"
  "binutils-avr"
  "avr-libc"
  "dfu-programmer"
  "dfu-util"
  "gcc-arm-none-eabi"
  "binutils-arm-none-eabi"
  "libnewlib-arm-none-eabi"

  # Brave browser
  "apt-transport-https"
  "curl"

  # Docker
  "ca-certificates"
  "curl"
  "gnupg"
  "gnome-terminal"
  "docker-ce"
  "docker-ce-cli"
  "containerd.io"
  "docker-buildx-plugin"
  "docker-compose-plugin"
)

if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
  echo "Adding Brave browser repository..."
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
fi

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  echo "Adding docker repository..."
  # for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

if [ ! -f "`which i3`" ]; then
  echo "Adding i3-gaps and picom-tryone repository..."
  sudo add-apt-repository ppa:dennis-kruyt/ricebuilder
fi

if [ ! -f "`which inkscape`" ]; then
  sudo add-apt-repository ppa:inkscape.dev/stable
fi

sudo apt update

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
  echo 'Installing Lens'
  wget -O tmp_install/lens.deb https://lens-binaries.s3-eu-west-1.amazonaws.com/ide/Lens-5.3.4-latest.20220120.1.amd64.deb
  sudo dpkg -i "tmp_install/lens.deb"
fi

if [ -z "$(sudo apt list docker-desktop 2>/dev/null | grep -o installed)" ]; then
  echo 'Installing Docker Desktop'
  wget -O ./tmp_install/docker-desktop.deb https://raw.githubusercontent.com/google/mozc/master/docker/ubuntu22.04/Dockerfile
  sudo dpkg -i ./tmp_install/docker-desktop.deb
fi

# Install packages language dependencies (Keyboard layout)
sudo apt install $(check-language-support -l en)

sudo apt install -f

rm -rf tmp_install
