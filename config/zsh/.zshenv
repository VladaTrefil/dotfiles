# Zsh reads this home link even in a fresh non-login shell.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
