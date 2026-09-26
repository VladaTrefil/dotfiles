# Quote paths directly; do not reparse HOME or XDG paths as shell code.
() {
  emulate -L sh
  . "$1"
} "$XDG_CONFIG_HOME/shell/profile"

typeset -U path PATH
path=("$ASDF_DATA_DIR/shims" "$BIN_PATH" $path)
export PATH

# Optional private login settings, outside every repository-backed config link.
# Block 8 provisions this file. Never load it from .zshenv or .zshrc.
if [[ -f "$XDG_CONFIG_HOME/dotfiles-private/login.sh" ]]; then
  () {
    emulate -L sh
    . "$1"
  } "$XDG_CONFIG_HOME/dotfiles-private/login.sh"
fi
