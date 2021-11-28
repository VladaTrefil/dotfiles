PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.12-6/lib/pkgconfig

# PHP ENV PATH
export PATH="/usr/local/opt/php@7.2/bin:$PATH"

# Fix for imagemagic bundle compiler
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"

# Rails test fix
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
