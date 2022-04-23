emulate sh -c 'source /etc/profile'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ======= RubyOnRails =============================

# Rails test fix
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# ======= NVM =============================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm

# ======= I3wm =============================

# Set i3-sensible-terminal
export TERMINAL="konsole"

# ======= PHP =============================

# PHP ENV PATH
export PATH="/usr/local/opt/php@7.2/bin:$PATH"

# ======= ImageMagick =============================

# Fix for imagemagic bundle compiler
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"

export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.12-6/lib/pkgconfig


if [ -f "$HOME/.xsession" ]; then
  source "$HOME/.xsession"
fi

# if running bash
if [ -n "$ZSH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
	    source "$HOME/.zshrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*