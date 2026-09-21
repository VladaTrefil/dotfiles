# Load portable settings for fresh non-login shells as well as login shells.
() {
  emulate -L sh
  . "$1"
} "$XDG_CONFIG_HOME/shell/profile"

# Go asdf is an executable on PATH. Never source a legacy asdf.sh.
# Keep shims first and make repeated startup idempotent.
typeset -U path PATH
path=("$ASDF_DATA_DIR/shims" "$BIN_PATH" "$BIN_PATH/usr" $path)
export PATH

# Updates are deliberate submodule changes; startup must not mutate the checkout.
zstyle ':omz:update' mode disabled
# The pinned theme compiles beside its sources. install link prepares this
# runtime copy in cache; the submodule and generated prompt config stay pristine.
POWERLEVEL9K_INSTALLATION_DIR="$XDG_CACHE_HOME/zsh/powerlevel10k-$(git -C "$ZSH_CUSTOM/themes/powerlevel10k" rev-parse HEAD)"

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

# Standard plugins live in $ZSH/plugins; custom ones are pinned under $ZSH_CUSTOM.
plugins=(
  git
  vi-mode
  zsh-autosuggestions
  fast-syntax-highlighting
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#757575,bg=none,bold,underline"

source "$ZSH/oh-my-zsh.sh"

# CTRL+F accept autosuggestion
bindkey '^F' autosuggest-accept

# Prompt settings are versioned in $ZDOTDIR/p10k.zsh.
[[ ! -f "$ZDOTDIR/p10k.zsh" ]] || source "$ZDOTDIR/p10k.zsh"

# }}}
# ────────────────────────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Settings: {{{

# Preserve the session locale; C.UTF-8 is available on Fedora and Arch.
export LANG="${LANG:-C.UTF-8}"

export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file

zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ "$line" != set\ [+-]o\ * ]]
  }

# The meaning of these options can be found in man page of `zshoptions`.
setopt HIST_IGNORE_ALL_DUPS  # do not put duplicated command into history list
setopt HIST_SAVE_NO_DUPS  # do not save duplicated command
setopt HIST_REDUCE_BLANKS  # remove unnecessary blanks
unsetopt INC_APPEND_HISTORY_TIME INC_APPEND_HISTORY
setopt SHARE_HISTORY  # Share commands live between shells, as Oh My Zsh does.
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
[[ ! -t 1 ]] || printf '\e[5 q' # Use beam shape cursor on a terminal.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# }}}

# Aliases
source "$XDG_CONFIG_HOME/shell/aliases.sh"
