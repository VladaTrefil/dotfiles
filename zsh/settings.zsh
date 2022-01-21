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

export BAT_THEME="gruvbox"

# colorize manual pages 
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git 
  vi-mode 
  zsh-autosuggestions 
  fast-syntax-highlighting
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#757575,bg=none,bold,underline"

bindkey '^ ' autosuggest-accept

source $ZSH/oh-my-zsh.sh
