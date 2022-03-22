export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.12-6/lib/pkgconfig

# ======= RubyOnRails =============================

# Rails test fix
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# ======= NVM =============================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ======= PHP =============================

# PHP ENV PATH
export PATH="/usr/local/opt/php@7.2/bin:$PATH"

# ======= ImageMagick =============================

# Fix for imagemagic bundle compiler
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
