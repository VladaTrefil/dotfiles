# Legacy path ledger

Track each legacy path here as its migration block is completed. This is a stub,
not a completed inventory. Use **migrated**, **rewritten**, or **dropped**, with a
reason and verification evidence.

| Legacy path | Destination | Status | Reason / verification |
|---|---|---|---|
| `config/git/config` | `config/git/config` | **migrated (verbatim + 1 documented addition)** | Copied byte-for-byte in A4 as the link-mechanism fixture; still awaits its Block 1 audit. **A6b appended one 3-line block** (`[url "git@github.com:VladaTrefil/nvim.git"] pushInsteadOf = https://github.com/VladaTrefil/nvim.git`) so the Neovim submodule clones over HTTPS without credentials while pushes still use the SSH key. Everything above that block is untouched legacy content. `diff` against the legacy file shows exactly this addition and nothing else. |
| `config/git/ignore` | `config/git/ignore` | **migrated (verbatim)** | Byte-for-byte; awaits Block 1 audit. |

## Desktop layer inventory (Blocks 5–6)

The original two Git rows remain subject to their own audit. This inventory covers the remaining
legacy desktop paths so Block 7 can distinguish installed applications from session config.

| Legacy path / state | Destination | Status | Reason / verification |
|---|---|---|---|
| `config/i3/` | `config/sway/` | **rewritten** | Block 5 moved bindings, profiles, input, workspace and session policy to SwayFX. i3 IPC is not used in the new session. Both Sway entry points have parser and static checks. |
| `config/x11/` | `config/sway/`, `config/environment.d/50-desktop.conf` | **rewritten / dropped** | Plasma/i3 X11 session and Xresources setup are superseded by standalone SwayFX; locale, cursor and Qt6 theme are in the environment file. Guest rendering remains to be verified. |
| `config/picom/` (legacy compositor, no config directory in this checkout) | SwayFX effects in `config/sway/conf.d/10-appearance.conf` | **dropped** | SwayFX is the compositor; picom is X11-only. No picom package in `packages/desktop.txt`. |
| `config/eww/` | `config/waybar/` | **rewritten; old tree dropped** | Built-in Waybar modules replace active status widgets. No eww scripts, PNGs or language flags were salvaged: each is either covered by a built-in or belongs to a removed widget. The old workspace poll called `i3-msg` (wrong IPC for Sway); audio `icon` returned `Unknown subcommand`; Bluetooth `connected` failed to dispatch; mediaplayer was commented out entirely. The language picker had an inverted visible condition and its Mozc/layout choices are obsolete under Compose. No eww reference remains in live config or packages; `tests/waybar-checks.py` enforces this. |
| `config/qt6ct/` | `config/qt6ct/qt6ct.conf`, `config/qt-palette/Catppuccin-Mocha.conf` | **migrated; palette deduplicated** | Fusion and the legacy palette retained. `QT_QPA_PLATFORMTHEME=qt6ct` was already set in Block 5 and remains singular. One palette source is linked to the Qt6 native path and the Qt5 native path. |
| `config/qt5ct/` | palette link only at `~/.config/qt5ct/colors/` | **config dropped; palette shared** | No named Qt5 application requiring qt5ct is yet established in the target inventory, so no qt5ct config or package is selected. The second palette link keeps the byte-identical source available if Block 7 confirms one. |
| `config/konsole/` | `config/kitty/` | **dropped / rewritten** | Block 5 chose Kitty as the terminal and ported terminal styling there. Konsole is an application decision outside this desktop layer. |
| `config/pulse/daemon.conf` | none | **dropped** | Legacy PulseAudio idle tweak is not carried into the target PipeWire stack. `pulseaudio-utils` remains for existing volume bindings; Waybar's PulseAudio module selection awaits guest confirmation of the PipeWire Pulse server and libpulse build. |
| `config/rofi/`, `config/dunst/` | same paths | **rewritten** | Block 5 ported launcher, power menu and notification styling to the Wayland session. Dunst remains the notification daemon. |
| legacy GTK and terminal settings | `config/gtk-3.0/`, `config/gtk-4.0/`, `config/kitty/` | **rewritten** | Block 5 selected GTK theme, icons, fonts, cursor and Kitty. Live appearance is pending guest validation. |
| host `~/.config/autostart/Proton Mail Bridge.desktop` | XDG autostart via `dex-autostart` in `config/sway/conf.d/60-session.conf` | **session integration added; application pending Block 7** | The host entry starts Bridge `--no-window`. The standalone session now runs XDG autostart and Waybar owns the tray; Bridge is not yet installed or verified on the VM. |
| `config/ranger/`, `config/zed/` | none yet | **outstanding for Block 7** | Application configs exist in legacy but are absent from the new link map; decide with the application/package inventory. |
