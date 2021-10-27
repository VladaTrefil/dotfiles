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

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git 
  vi-mode 
  zsh-autosuggestions 
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Vi Mode
bindkey -v
export KEYTIMEOUT=1

# Edit line in Vim
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}

zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}

zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# make vim open target file instead of symlink
function vim() {
  args=()

  for i in $@; do
    if [[ -h $i ]]; then
      args+=`readlink $i`
    else
      args+=$i
    fi
  done

  /usr/local/bin/nvim "${args[@]}"
}
