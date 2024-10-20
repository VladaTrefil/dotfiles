#                   __
#                  /\ \
#     ____     ____\ \ \___
#    /\_ ,`\  /',__\\ \  _ `\
#    \/_/  /_/\__, `\\ \ \ \ \
#      /\____\/\____/ \ \_\ \_\
#      \/____/\/___/   \/_/\/_/
#

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Oh My Zsh: {{{

ZSH_THEME="powerlevel10k/powerlevel10k"

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$ZDOTDIR/p10k.zsh" ]] || source "$ZDOTDIR/p10k.zsh"

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Settings: {{{

# set utf-8 encoding
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file

# The meaning of these options can be found in man page of `zshoptions`.
setopt HIST_IGNORE_ALL_DUPS  # do not put duplicated command into history list
setopt HIST_SAVE_NO_DUPS  # do not save duplicated command
setopt HIST_REDUCE_BLANKS  # remove unnecessary blanks
setopt INC_APPEND_HISTORY_TIME  # append command to history file immediately after execution
setopt EXTENDED_HISTORY  # record command start time

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Vi: {{{

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

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
#  Brew {{{

emulate sh -c 'source /etc/profile'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Aliases
source "$XDG_CONFIG_HOME/shell/aliases.sh"

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# ASDF

if [ -f "$ASDF_DIR/asdf.sh" ]; then
  . $ASDF_DIR/asdf.sh
else
  echo "asdf.sh not found"
fi

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# NVM

export NVM_DIR="$XDG_CONFIG_HOME/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Rust

. "$CARGO_HOME/env"

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# PATH

export PATH="$ASDF_DIR/shims:$PATH"

# set PATH so it includes user's private bin if it exists
if [ -d "$BIN_PATH" ]; then
  PATH="$BIN_PATH:$PATH"
  PATH="$BIN_PATH/usr:$PATH"
fi

export PATH="$GOPATH/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$GEM_HOME/bin" # Add gem home
