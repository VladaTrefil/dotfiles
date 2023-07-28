dir="$HOME/.config/rofi/launcher"

export THEME_BACKGROUND="#1E2127FF"
export THEME_BACKGROUND_ALT="#282B31FF"
export THEME_FOREGROUND="#FFFFFFFF"
export THEME_SELECTED="#61AFEFFF"
export THEME_ACTIVE="#98C379FF"
export THEME_URGENT="#E06C75FF"

## Run
rofi \
    -show drun \
    -theme "${dir}"/theme.rasi
