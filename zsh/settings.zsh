PATH="$HOME/.local/bin${PATH:+:${PATH}}"
EDITOR="nvim"
ZSH=~/.oh-my-zsh

# Invoke TMUX on start
if [[ -z "$TMUX" ]]; then
    if tmux has-session 2>/dev/null; then
        exec tmux attach
    else
        exec tmux
    fi
fi

export BAT_THEME="ayu"
