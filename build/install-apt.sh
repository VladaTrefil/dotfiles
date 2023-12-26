#!/bin/zsh

if [ ! -f "`which apt`" ]; then
  echo "SKIP - Apt is not installed" >&2
  exit  1
fi

APT_PACKAGES=(
  "aptitude" # Better apt
  "libreadline-dev" # Better apt
  "build-essential"
  "alsa-utils" # Basic sound control

  # Desktop environment
  "xinit"
  "i3"
  "picom"
  # "rofi" -- from source v1.7.4
  "feh"
  "dunst"

  # Desktop tools (GUI)
  "konsole" # Terminal
  "syncthing" # LAN File sync
  "inkscape" # Vector graphics editor
  "ffmpeg" # Video editor
  "brave-browser" # Web browser
  "thunderbird" # Email client
  "kde-spectacle" # Screenshot tool
  "dolphin" # File manager
  "picard" # Music tagger
  "qbittorrent" # Torrent client
  "ark" # Archive tool
  "libreoffice" # Office suite
  "libreoffice-l10n-cs" # Office suite
  "libreoffice-l10n-en-gb" # Office suite
  "vlc" # Video player
  "mpv" # Minimal video player
  "skanlite" # Scanner tool
  "gnome-system-monitor" # System monitor
  "partitionmanager" # Disk partition manager
  "telegram-desktop" # Telegram chat client
  "krita" # Image editor
  "spotify-client" # Music player
  "lens" # Kubernetes IDE
  "strawberry" # Music player

  # Ibus
  "ibus"
  "im-config"
  "ibus-data"
  "ibus-mozc"
  "mozc-utils-gui"

  # Terminal functions
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
  "playerctl" # Control media player from terminal
  "awscli" # AWS client
  "brightnessctl" # Brightness control
  "network-manager" # Network manager

  # Terminal code interpreters
  "python3-dev"
  "python3-venv"
  "python-is-python3"
  "lua5.3:i386"

  # Language tools
  "language-pack-cs"
  "language-pack-en-base"
  "language-pack-en"
  "language-pack-ja-base"
  "language-pack-ja"

  # Ibus
  "virtualbox"
  # "virtualbox-ext-pack"
  "virtualbox-guest-additions-iso"
  "virtualbox-guest-utils"
  "virtualbox-guest-x11"

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

  # Git dependencies
  "install-info"
  "dh-autoreconf"
  "libcurl4-gnutls-dev"
  "libexpat1-dev"
  "gettext"
  "libz-dev"
  "libssl-dev"
  "asciidoc"
  "xmlto"
  "docbook2x"

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

  # Drivers
  "ubuntu-drivers-common"
  "printer-driver-brlaser"
  "printer-driver-c2esp"
  "printer-driver-foo2zjs"
  "printer-driver-m2300w"
  "printer-driver-min12xxw"
  "printer-driver-pnm2ppa"
  "printer-driver-ptouch"
  "printer-driver-pxljr"
  "printer-driver-sag-gdi"
  "printer-driver-splix"
)

apt_sources_dir="/etc/apt/sources.list.d"

if [ ! -f "$apt_sources_dir/brave-browser-release.list" ]; then
  echo "Adding Brave browser repository..."
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee "$apt_sources_dir/brave-browser-release.list"
fi

if [ ! -f "$apt_sources_dir/docker.list" ]; then
  echo "Adding docker repository..."
  # for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  version="$(. /etc/os-release && echo "$VERSION_CODENAME")"
  params="[arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg]"
  echo "deb $params https://download.docker.com/linux/ubuntu $version stable" | sudo tee "$apt_sources_dir/docker.list" > /dev/null
fi

if [ ! -f "$apt_sources_dir/lens.list" ]; then
  curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null
  params="[arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg]"
  echo "deb $params https://downloads.k8slens.dev/apt/debian stable main" | sudo tee "$apt_sources_dir/lens.list" > /dev/null
fi

if [ ! -f "$apt_sources_dir/spotify.list" ]; then
  curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
  echo "deb http://repository.spotify.com stable non-free" | sudo tee "$apt_sources_dir/spotify.list"
fi

if [ ! -f "`which strawberry`" ]; then
  echo "Adding strawberry repository..."
  sudo add-apt-repository ppa:jonaski/strawberry
fi

if [ ! -f "`which i3`" ]; then
  echo "Adding i3-gaps and picom-tryone repository..."
  sudo add-apt-repository ppa:dennis-kruyt/ricebuilder
fi

if [ ! -f "`which inkscape`" ]; then
  sudo add-apt-repository ppa:inkscape.dev/stable
fi

sudo apt update

GREEN='\033[0;32m'
NC='\033[0m' # No Color

for p in $APT_PACKAGES; do
  if [ $(dpkg-query -W -f='${Status}' $p 2>/dev/null | grep -c "ok installed") = "0" ]; then
    echo "\n============================================================================="
    echo -e "Installing ${GREEN}$p${NC}..."
    sudo apt-get install $p -y --no-upgrade --install-recommends | grep -oP "^.*upgraded.*$"
    echo -e "${GREEN}Installed $p${NC}"
    echo "=============================================================================\n"
  else
    echo -e "${GREEN}$p${NC} already exists"
  fi
done

# Install packages language dependencies (Keyboard layout)
sudo apt install $(check-language-support -l en)

sudo apt --fix-broken install

# Install DPKG:
installers=$(find . -name "*.deb")
if [ -n "$installers" ]; then
  while IFS= read -r installer; do
    echo -e "Installing ${GREEN}$installer${NC}..."
    sudo dpkg -i "$installer"
  done <<< "$installers"
fi
