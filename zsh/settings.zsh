# set utf-8 encoding
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

PATH="$HOME/.local/bin${PATH:+:${PATH}}"

EDITOR="nvim"
ZSH_DISABLE_COMPFIX=true
ZSH=~/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

# Invoke TMUX on start
if [[ -z "$TMUX" ]]; then
  exec tmux
fi

# colorize manual pages 
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
plugins=(
  git 
  vi-mode 
  zsh-autosuggestions 
  fast-syntax-highlighting
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#757575,bg=none,bold,underline"

# CTRL+F accept autosuggestion
bindkey '^F' autosuggest-accept

source $ZSH/oh-my-zsh.sh
