# set utf-8 encoding
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export TERM=screen-256color

PATH="$HOME/.local/bin${PATH:+:${PATH}}"
EDITOR="nvim"
ZSH_THEME="lambda"
ZSH_DISABLE_COMPFIX=true
ZSH=~/.oh-my-zsh
PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.12-6/lib/pkgconfig

# Fix for imagemagic bundle compiler
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"

# Rails test fix
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Invoke TMUX on start
if [[ -z "$TMUX" ]]; then
    if tmux has-session 2>/dev/null; then
        exec tmux attach
    else
        exec tmux
    fi
fi

export BAT_THEME="ayu"

# colorize manual pages 
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# PHP ENV PATH
export PATH="/usr/local/opt/php@7.2/bin:$PATH"
