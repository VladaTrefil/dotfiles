export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.12-6/lib/pkgconfig

# Rails test fix
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PHP ENV PATH
export PATH="/usr/local/opt/php@7.2/bin:$PATH"

# Fix for imagemagic bundle compiler
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
