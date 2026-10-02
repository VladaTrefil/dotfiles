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

# A password-authenticated console login still runs PAM before reaching here.
# Never replace the login shell: a failed/exited compositor returns to a prompt.
if [[ -o interactive && -t 0 && -t 1 &&
      ${XDG_VTNR-} == 1 && ${TTY-} == /dev/tty1 &&
      ! -v WAYLAND_DISPLAY && ! -v DISPLAY && ! -v SWAYSOCK &&
      ! -v SSH_CONNECTION && ! -v SSH_CLIENT && ! -v SSH_TTY &&
      ${DOTFILES_SWAY_AUTOSTART-} != 0 &&
      ! -e "$XDG_CONFIG_HOME/dotfiles/sway-autostart-disabled" ]]; then
  () {
    local launcher
    # Reuse the existing profile/launcher names; no machine detection or default.
    case ${SWAY_PROFILE-} in
      physical|virtualbox) launcher="$HOME/.config/sway/bin/start-$SWAY_PROFILE" ;;
      *) return 0 ;;
    esac
    if [[ -x "$launcher" ]]; then
      "$launcher" || true
    fi
  }
fi
