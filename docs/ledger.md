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
| `config/eww/` | `config/eww/` | **migrated and repaired in B6e** | The Waybar port was reversed. The original SCSS and active widgets are restored; Sway IPC, PipeWire audio, actual network throughput, Bluetooth dispatch, monitor selection, and Wayland exclusivity were repaired. The unused media player and obsolete language picker were dropped. The Fedora 44 Wayland RPM is SHA-256 pinned. `tests/eww-checks.py`, guest widget values, and a `grim` screenshot verify the VM session. Physical output names and hardware remain open. |
| `config/qt6ct/` | `config/qt6ct/qt6ct.conf`, `config/qt-palette/Catppuccin-Mocha.conf` | **migrated; palette deduplicated** | Fusion and the legacy palette retained. `QT_QPA_PLATFORMTHEME=qt6ct` was already set in Block 5 and remains singular. One palette source is linked to the Qt6 native path and the Qt5 native path. |
| `config/qt5ct/` | palette link only at `~/.config/qt5ct/colors/` | **config dropped; palette shared** | No named Qt5 application requiring qt5ct is yet established in the target inventory, so no qt5ct config or package is selected. The second palette link keeps the byte-identical source available if Block 7 confirms one. |
| `config/konsole/` | `config/kitty/` | **dropped / rewritten** | Block 5 chose Kitty as the terminal and ported terminal styling there. Konsole is an application decision outside this desktop layer. |
| `config/pulse/daemon.conf` | none | **dropped** | Legacy PulseAudio idle tweak is not carried into the target PipeWire stack. `pulseaudio-utils` remains for existing volume bindings and the eww audio widget; the guest reports PulseAudio on PipeWire 1.6.9. |
| `config/rofi/`, `config/dunst/` | same paths | **rewritten** | Block 5 ported launcher, power menu and notification styling to the Wayland session. Dunst remains the notification daemon. |
| legacy GTK and terminal settings | `config/gtk-3.0/`, `config/gtk-4.0/`, `config/kitty/` | **rewritten** | Block 5 selected GTK theme, icons, fonts, cursor and Kitty. Live appearance is pending guest validation. |
| host `~/.config/autostart/Proton Mail Bridge.desktop` | XDG autostart via `dex-autostart` in `config/sway/conf.d/60-session.conf` | **session integration added; application pending Block 7** | The host entry starts Bridge `--no-window`. The standalone session runs XDG autostart and eww owns the tray; an IBus tray item was verified on the VM. Bridge is not yet installed or verified on the VM. |
| `config/ranger/`, `config/zed/` | none yet | **outstanding for Block 7** | Application configs exist in legacy but are absent from the new link map; decide with the application/package inventory. |

## Applications and system integration (Block 7)

This section supersedes the two Block 6 rows that left Proton Bridge and Zed
outstanding.

| Legacy path / state | Destination | Status | Reason / verification |
|---|---|---|---|
| `build/install.conf.yaml` package block (109 rows, 108 distinct) | `packages/apps.txt`, `packages/flatpak.txt`, existing manifests, and pinned releases | **accounted** | The full findings table is implemented. Twenty-seven rows were already covered: `readline`, `curl`, `git`, `asdf-vm`, the PipeWire trio, `zsh`, `dunst`, `eww`, `rofi`, `qt6ct`, guest additions, `bat`, `ripgrep`, `fd`, `neovim`, `lazygit`, `lf`, `ibus`, Python/Pylint/Pynvim/isort/mypy, ImageMagick, and Ghostscript. The remaining kept/replaced applications are native Fedora/RPM Fusion packages, the four reviewed Flatpaks, or the pinned Lens/QMK paths. Both `ark` source rows map to one `xarchiver` entry. The guest reports zero missing entries across the 70-package native manifest and all four Flatpak IDs. |
| same package block: obsolete/unwanted rows | none | **dropped (21 source rows)** | `alsa-utils`, i3, picom, feh, qt5ct, Konsole, Spectacle, Skanlite, Docker Desktop, host VirtualBox/guest ISO packages, xclip, ifstat, playerctl, ranger, python-i3ipc, python-devtools, python-virtualenv, system Lua, Brave, and Redis are absent. Brave is explicitly dropped because Chromium remains native and is already `$BROWSER`. Redis/Valkey is per-project state, not workstation provisioning. |
| same package block: `telegram-desktop`, `ffmpeg` | native RPM Fusion free packages | **replaced / migrated** | The approved repo is enabled idempotently. Telegram uses its native RPM and full `ffmpeg` replaces `ffmpeg-free`; the guest proves `telegram-desktop`/`ffmpeg` present and `ffmpeg-free` absent. |
| same package block: `gparted` replacement | `gparted` + `lxqt-policykit` | **replaced with constrained policy agent** | Naming the Qt policy agent prevented DNF from selecting its GNOME alternative. Guest `rpm -q` proves both requested packages installed while `gnome-shell` and `gdm` are absent. |
| same package block: `lens-bin` | Lens RPM record in `provision/releases.json` | **migrated, separately pinned** | Official Lens RPM repository metadata supplied the exact artifact SHA-256. The package phase verifies size/hash before DNF; guest package is `lens-2026.9.181013~latest-1.x86_64`. No installer script is used. |
| same package block: `qmk` | QMK wheel-set record in `provision/releases.json` | **migrated, separately pinned** | QMK and its PyPI-only runtime wheels are individually SHA-256 pinned and extracted by `bin/install-releases`; Fedora dependencies remain native RPMs. No pip or shell installer runs. Guest `qmk --version` reports `1.2.0`, and the second tools run is idempotent. |
| `local/applications/lf.desktop` | `local/applications/lf.desktop` | **rewritten** | Removed the dead asdf/Go 1.18 binary path. The linked entry now launches `kitty --class lf -e lf %f` through PATH with `TryExec=lf`. Link tests cover it. |
| `local/bin/ydl-clip.sh` | `local/bin/ydl-clip.sh` | **rewritten** | Retained personal workflow using `wl-paste`, strict input validation, quoted paths, one consistent yt-dlp archive, and yt-dlp's archive semantics instead of broad timestamp deletion. Fixed DISPLAY, UID, and X11 dependencies are gone; ShellCheck passes. |
| `local/bin/kill-rails-server.sh` | none | **dropped** | Unquoted PID extraction and unconditional SIGKILL could target the wrong process. The stale public alias was removed. |
| `local/bin/clear-git-branches.sh` | none | **dropped** | The unmatched backtick fails parsing before execution; the script also performs unsafe remote branch deletion. |
| `local/bin/generate-rails-sitemaps.sh` | intended private `dotfiles-work` repository | **move pending / not copied** | Employer/project-specific and needs repair. No local private checkout was available and remote authentication failed, so inventing a destination or exposing it publicly was rejected. |
| `local/bin/folio-test-account.rb` | intended private `dotfiles-work` repository | **move pending / not copied** | Employer/client-specific privileged account creation. Credential values were not read, copied, or reproduced. |
| `local/bin/init-sinfin-project.sh` | intended private `dotfiles-work` repository | **move pending / not copied** | Employer-specific destructive database bootstrap. Credential values were not read or copied; reuse requires target and independently verified backup/restore checks. |
| `config/shell/aliases.sh` references to the local scripts | `config/shell/aliases.sh` | **rewritten** | Removed the dropped Rails killer alias and changed the retained downloader path to the managed `~/.local/bin/ydl-clip.sh`. |
| host `~/.config/autostart/Proton Mail Bridge.desktop` | `local/autostart/protonmail-bridge.desktop` | **rewritten and migrated** | Generic Dex-compatible Flatpak entry starts `ch.protonmail.protonmail-bridge --no-window`; GNOME-only metadata was removed. In the tty2 session Bridge ran and Eww's watcher reported two tray items. |
| `config/zed/settings.json` | `config/zed/settings.json` | **migrated with portability repair** | Terminal program is PATH-based `zsh`; the rest of the selected settings were retained. Linked to `~/.config/zed`. |
| `config/zed/tasks.json` | `config/zed/tasks.json` | **migrated and pruned** | Retained the LazyGit task and dropped the tutorial example. |
| `config/zed/keymap.json` | `config/zed/keymap.json` | **migrated and normalized** | LazyGit task labels now match exact case. |
| `config/zed/keymap_backup.json` | none | **dropped** | Stale backup with older action names is not live configuration. |
| `config/ranger/` | none | **dropped** | `lf` is the settled checksum-pinned terminal file manager; no Ranger package or config is carried. |
| legacy `config/i3/on-startup.sh` system actions | `bin/system-setup`, Sway session config | **rewritten** | IBus already starts through the Wayland session. The new explicit user/root phases manage Zsh, Syncthing, Bluetooth, Docker group membership, and Docker service with state checks, dry-run, and idempotent output. Fedora requires password authentication for unprivileged `chsh`, so shell mutation moved to the explicit root phase. PostgreSQL initialization remains manual; Redis/Valkey is dropped. |
| `nvim-next/lua/core/mappings.lua` Dolphin mapping | separate `nvim-next` commit `027b0d2` | **rewritten; gitlink pending publication** | `<Leader>E` now uses detached `vim.system` with `pcmanfm-qt` and the current directory. Neovim tests pass. `modules/nvim` remains on published `2214baf`: pushing was forbidden, and an attempted `bin/sync-nvim` could not fetch because the host rejected `/etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf` ownership/permissions. Do not hand-edit the gitlink; fix that host issue, publish the Neovim commit, then rerun the supported sync command. |

The manifest regression test has deliberate provider mappings for linked script
commands that previously failed silently. Its negative run failed for both
`bluetoothctl`/`bluez` and `jq`; after adding `bluez` and `jq`, guest lint and
the live workspace/Bluetooth probes pass.
