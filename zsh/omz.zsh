# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
plugins=(
  git 
  vi-mode 
  zsh-autosuggestions 
  fast-syntax-highlighting
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#757575,bg=none,bold,underline"

source $ZSH/oh-my-zsh.sh

# CTRL+F accept autosuggestion
bindkey '^F' autosuggest-accept
