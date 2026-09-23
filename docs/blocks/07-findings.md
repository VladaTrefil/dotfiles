# Block 7 findings: applications and system integration

Scanned on 2026-09-23 against the read-only legacy repository and the running
Fedora 44 x86_64 guest. No package was installed and no service or VM setting
was changed.

The brief says the legacy `yay:` block contains 106 packages. The current
`build/install.conf.yaml` actually has **109 uncommented rows, 108 distinct**;
`ark` occurs twice. This inventory deliberately accounts for all 109 source
rows rather than forcing the result to the stale count.

Availability was rechecked with DNF on the guest. Fedora queries excluded all
COPRs unless a row names one. RPM Fusion free/nonfree metadata was queried with
temporary `--repofrompath` URLs; those repositories were not enabled. The guest
does not have the `flatpak` command and has no configured Flatpak remotes, so
the Flatpak rows were confirmed in the Flathub API/manifest repository but are
marked guest-unverified. `fedora` and `updates` below are the exact repository
IDs returned by Fedora 44 DNF.

## 1. Legacy package inventory

### Foundations, audio, and desktop plumbing

| package | disposition | Fedora source | note |
|---|---|---|---|
| `readline` | already-covered | `fedora` | `readline-devel` is already in `packages/dev.txt` and pulls the runtime library. |
| `alsa-utils` | drop | `updates` | No surviving config calls ALSA utilities; the selected PipeWire stack and `pactl` path are already covered. |
| `curl` | already-covered | `updates` | Present in `shell.txt` and `editor-tools.txt`. |
| `ca-certificates` | keep | `updates` | Keep explicit CA trust for HTTPS/package tooling on a minimal install. |
| `git` | already-covered | `updates` | Present in existing manifests. |
| `gnupg` | keep | `updates` (`gnupg2`) | Fedora name is `gnupg2`; keep signature/key tooling. |
| `asdf-vm` | already-covered | none found | Go-asdf is already checksum-pinned by `bin/install-releases`; no Fedora package was found. |
| `pipewire` | already-covered | `updates` | Present in `desktop.txt`. |
| `pipewire-pulse` | already-covered | `updates` (`pipewire-pulseaudio`) | Exact Fedora replacement is already present. |
| `pipewire-audio` | already-covered | `updates` | The Arch grouping is already represented by `pipewire`, `pipewire-pulseaudio`, `pipewire-alsa`, and WirePlumber. |
| `bluez` | keep | `updates` | Required for Bluetooth service and the Eww widget; missing from every current `packages/*.txt`. |
| `bluez-utils` | replace | `updates` (`bluez`) | Fedora does not split this package: DNF file ownership confirms `bluez` provides `/usr/bin/bluetoothctl`. |
| `zsh` | already-covered | `updates` | Present in `shell.txt`. |
| `i3` | drop | `fedora` | X11 window manager replaced by SwayFX. |
| `picom` | drop | `fedora` | X11 compositor; no role under Sway/Wayland. |
| `feh` | drop | `updates` | X11 wallpaper/image tool; Sway's wallpaper path is already settled. |
| `dunst` | already-covered | `fedora` | Present in `desktop.txt`. |
| `eww` | already-covered | named COPR `dturner/eww` | Block 6 already selected and checksum-pinned the Fedora 44 Wayland RPM. |
| `rofi` | already-covered | `fedora` | Fedora's 2.x Wayland-capable build is present in `desktop.txt`. |
| `qt5ct` | drop | `fedora` | The target carries Qt 6 configuration only; the legacy Qt 5 config is not linked. |
| `qt6ct` | already-covered | `updates` | Present in `desktop.txt`. |

### Applications and services

| package | disposition | Fedora source | note |
|---|---|---|---|
| `konsole` | drop | `updates` | Kitty is the settled terminal; carrying Konsole would restore KDE application dependencies. |
| `inkscape` | keep | `updates` | Native Fedora package. |
| `brave-bin` | replace | flatpak (`com.brave.Browser`) — guest-unverified | Flathub entry exists; no Fedora package was found. This avoids an additional system RPM repository. |
| `chromium` | keep | `updates` | Native Fedora Chromium. |
| `thunderbird` | keep | `updates` | Native Fedora package. |
| `spectacle` | drop | `updates` | KDE screenshot application is superseded by the already-covered Grim/Slurp workflow. |
| `dolphin` | replace | `updates` (`pcmanfm-qt` + `gvfs`) | Replacement is already decided; dependency details are in section 2. |
| `picard` | keep | `fedora` | MusicBrainz Picard, not an unrelated same-name package. |
| `qbittorrent` | keep | `updates` | Native Fedora qBittorrent. |
| `ark` (first occurrence) | replace | `fedora` (`xarchiver`) | Replacement is already decided. |
| `vlc` | keep | `updates` | Native Fedora VLC; codec coverage still follows Fedora's codec policy. |
| `mpv` | keep | `fedora` | Native Fedora mpv. |
| `skanlite` | drop | `updates` | Decided: no scanner replacement. |
| `gnome-system-monitor` | keep | `fedora` | Native package; keeping the application does not require a GNOME session. |
| `partitionmanager` | replace | `fedora` (`gparted`) | Replacement is already decided; explicitly pair it with `lxqt-policykit` to avoid DNF selecting GNOME Shell as its policy agent. |
| `telegram-desktop` | replace | RPM Fusion free (not enabled) | RPM Fusion free carries the native package. Flathub `org.telegram.desktop` is an alternative if RPM Fusion is rejected. |
| `krita` | keep | `updates` | Native Fedora package. |
| `spotify-launcher` | replace | flatpak (`com.spotify.Client`) — guest-unverified | Fedora has no native package; RPM Fusion nonfree has `lpf-spotify-client`, which is a bootstrap package rather than Spotify itself. Prefer the direct Flatpak if Flatpak is approved. |
| `strawberry` | keep | `updates` | Native Fedora package. |
| `anki` | replace | flatpak (`net.ankiweb.Anki`) — guest-unverified | No Fedora package was found; the Flathub entry exists. |
| `docker` | replace | `updates` (`moby-engine`) | Fedora's Docker-compatible engine package; it owns `docker.service`. Do not substitute `podman-docker` because the requested integration explicitly uses the Docker group/service. |
| `docker-compose` | keep | `updates` | Fedora package is the Docker Compose implementation, not merely a similarly named tool. |
| `docker-buildx` | keep | `updates` | Native Docker Buildx CLI plugin. |
| `docker-desktop` | drop | none found | Not in Fedora or Flathub under the expected ID and redundant with the native engine/CLI workflow. |
| `protonmail-bridge` | replace | flatpak (`ch.protonmail.protonmail-bridge`) — guest-unverified | Flathub package exists and its manifest runs `protonmail-bridge`; it repackages Proton's upstream build. Autostart details are in section 6. |
| `lens-bin` | keep | none found | Lens still appears intentional, but no Fedora, RPM Fusion, usable COPR, or Flathub package was found. Do not fall back silently to an upstream installer; user decision required. |
| `ark` (duplicate occurrence) | replace | `fedora` (`xarchiver`) | Preserved for source-row accounting; do not install `xarchiver` twice. |
| `timeshift` | keep | `updates` | Native Fedora package; actual snapshot setup remains a physical-machine decision. |
| `libreoffice-fresh` | replace | `updates` (`libreoffice`) | Fedora's maintained suite package. |
| `libreoffice-fresh-cs` | replace | `updates` (`libreoffice-langpack-cs`) | Exact Czech language pack. |
| `libreoffice-fresh-en-gb` | replace | `updates` (`libreoffice-langpack-en-GB`) | Exact British English language pack. |
| `virtualbox` | drop | RPM Fusion free (not enabled) | Host hypervisor package has no place inside this VirtualBox guest. |
| `virtualbox-guest-iso` | drop | none found | Host-side ISO package; not needed in the guest. |
| `virtualbox-guest-utils` | already-covered | `updates` (`virtualbox-guest-additions`) | Fedora guest additions were installed and verified during the VM baseline. |
| `syncthing` | keep | `updates` | Package contains both `/usr/lib/systemd/user/syncthing.service` and the system template; use the user unit. |

### Terminal and workstation tools

| package | disposition | Fedora source | note |
|---|---|---|---|
| `ffmpeg` | replace | `updates` (`ffmpeg-free`) | Provides `/usr/bin/ffmpeg`; not codec-equivalent to RPM Fusion's full `ffmpeg`. Full codec coverage is an open decision. |
| `bat` | already-covered | `updates` | Present in `dev.txt`. |
| `bc` | keep | `fedora` | Native GNU `bc`. |
| `mercurial` | keep | `updates` | Native Mercurial. |
| `ripgrep` | already-covered | `updates` | Present in `editor-tools.txt`. |
| `fd` | already-covered | `updates` (`fd-find`) | Exact executable provider already present in `editor-tools.txt`. |
| `unzip` | keep | `fedora` | Used by general shell archive helpers; not yet in a manifest. |
| `xclip` | drop | `fedora` | X11-only clipboard client; `wl-clipboard` is already covered. |
| `ifstat` | drop | `fedora` | The repaired Eww network widget no longer uses it. |
| `jq` | keep | `updates` | Required now: active Eww Bluetooth/workspace scripts invoke `jq`, but no current package manifest includes it. |
| `moreutils` | keep | `fedora` | Retain the explicitly selected CLI collection. |
| `perl-rename` | replace | `fedora` (`prename`) | Fedora's Perl implementation installs `/usr/bin/prename`; `/usr/bin/rename` is the different util-linux implementation, so no implicit alias should be assumed. No surviving config calls either name. |
| `speedtest-cli` | keep | `fedora` | Native package; optional interactive utility rather than an Eww dependency. |
| `playerctl` | drop | `fedora` | Its only desktop role was the media widget dropped in Block 6; no surviving config calls it. |
| `aws-cli` | replace | `updates` (`awscli2`) | Fedora's AWS CLI v2 matches the active Oh My Zsh AWS plugin's supported major version. |
| `brightnessctl` | keep | `fedora` | Keep for the physical workstation; the headless VM cannot validate backlight hardware. |
| `networkmanager` | replace | `updates` (`NetworkManager`) | Fedora package name is case-sensitive; provides `nmcli`. |
| `yt-dlp` | keep | `updates` | Required by the retained personal download script, after its Wayland repairs. |
| `qmk` | keep | none found | Active `qmkm` alias still needs the QMK CLI. Fedora has no package; two named COPRs were found but neither exposed a successful Fedora 44 package. Keep the requirement unresolved rather than installing from PyPI now. |
| `neofetch` | replace | `updates` (`fastfetch`) | Neofetch is absent; Fastfetch is the maintained native replacement. No config needs Neofetch-specific output. |
| `lsof` | keep | `fedora` | Native diagnostic tool. |
| `neovim` | already-covered | `updates` | Present in existing manifests and verified. |
| `lazygit` | already-covered | none found | Already installed from a checksum-pinned upstream release by `bin/install-releases`. |
| `ranger` | drop | `fedora` | Legacy comment already selects `lf` as its replacement; do not port `config/ranger`. |
| `lf` | already-covered | none found | Checksum-pinned release install already exists. |
| `ibus` | already-covered | `updates` | Present in `desktop.txt`. |
| `ibus-mozc` | keep | `fedora` | Keep Japanese input engine; `ibus` alone does not provide Mozc. |
| `openrgb` | keep | `fedora` | Native package; physical RGB hardware remains untestable in the VM. |

### Language and employer-oriented data/image stack

| package | disposition | Fedora source | note |
|---|---|---|---|
| `python` | already-covered | `updates` (`python3`) | Python 3 is already present in `base.txt` and `editor-tools.txt`. |
| `python-pylint` | already-covered | `fedora` (`python3-pylint`) | Already present in `editor-tools.txt`. |
| `python-i3ipc` | drop | `fedora` (`python3-i3ipc`) | Only relevant to the retired i3/X11 session. Sway IPC integration no longer uses it. |
| `python-pynvim` | already-covered | `updates` (`python3-neovim`) | Already present in `editor-tools.txt`; verified provider, not name-only matching. |
| `python-isort` | already-covered | `fedora` (`python3-isort`) | Already present in `editor-tools.txt`. |
| `python-devtools` | drop | none found | No Fedora package and no surviving direct configuration requirement. |
| `python-virtualenv` | drop | `fedora` (`python3-virtualenv`) | Current Python provides `venv`; no active config requires the separate `virtualenv` command. |
| `mypy` | already-covered | `fedora` (`python3-mypy`) | Already present in `editor-tools.txt`. |
| `lua` | drop | `fedora` | Neovim embeds Lua and no surviving application requires a system Lua interpreter. |
| `postgresql` | replace | `updates` (`postgresql` + `postgresql-server`) | Fedora `postgresql` is client programs only. Preserving the legacy server/service requires `postgresql-server` as well. |
| `postgresql-libs` | replace | `fedora` (`libpq`) | Fedora general PostgreSQL client library; do not confuse it with `postgresql-private-libs`. |
| `libpqxx` | keep | `fedora` | Correct C++ PostgreSQL client library. |
| `imagemagick` | already-covered | `updates` (`ImageMagick`) | Already present in `editor-tools.txt`; owns the expected image commands. |
| `perl-image-exiftool` | keep | `updates` (`perl-Image-ExifTool`) | Exact ExifTool implementation. |
| `rubber` | keep | `fedora` | Native LaTeX build automation package. |
| `texlive-xetex` | keep | `updates` | Native XeTeX package. |
| `libsodium` | keep | `updates` | Native library. |
| `pdftk` | replace | `fedora` (`pdftk-java`) | Fedora provides the Java reimplementation. `/usr/bin/pdftk` ownership is verified, but behavioral compatibility was not runtime-tested and no surviving config invocation was found. |
| `ghostscript` | already-covered | `fedora` | Already present in `editor-tools.txt`. |
| `redis` | replace | `updates` (`valkey` + `valkey-compat-redis`) | Fedora's maintained server is Valkey; the compatibility subpackage supplies Redis names/symlinks. Service/data migration is not assumed compatible without approval. |
| `libvips` | replace | `updates` (`vips`) | Fedora library package is `vips`; add `vips-tools` only if the CLI is actually required. |
| `openslide` | keep | `updates` | Native OpenSlide library. |
| `gifsicle` | keep | `fedora` | Exact GIF utility. |
| `libwebp` | keep | `fedora` | Native WebP library/tools package. |
| `freetds` | keep | `updates` | Native TDS implementation. |

### Count

The actual 109 source rows resolve to:

| disposition | count |
|---|---:|
| already-covered | 27 |
| keep | 39 |
| replace | 24 |
| drop | 19 |
| **total** | **109** |

The counts include both `ark` rows. After deduplication there are 108 package
requirements, and `xarchiver` is proposed only once.

## 2. KDE replacements

The exact Fedora package set should be:

- `pcmanfm-qt` (`updates`) and `gvfs` (`updates`)
- `xarchiver` (`fedora`)
- `gparted` (`fedora`)
- `lxqt-policykit` (`updates`) explicitly, to control GParted's virtual policy-agent dependency

Read-only DNF `--assumeno` simulations on the current guest found:

- `pcmanfm-qt` alone would add 24 packages with weak dependencies disabled. It
  pulls LXQt/Qt/KF6 libraries, `qterminal`, and `lxqt-sudo`, but not an LXQt or
  Plasma desktop session.
- Base `gvfs` alone adds eight packages on this guest and no GNOME desktop.
  DNF file lists confirm that the base package contains trash, SFTP, FTP, DAV,
  network, and computer backends. SMB, MTP, NFS, camera, and Apple-device
  backends remain optional split packages.
- `xarchiver` adds no desktop environment; its GTK dependencies are already
  present on the guest.
- `gparted` requires the virtual capability `PolicyKit-authentication-agent`.
  With no explicit provider, DNF selected `gnome-shell` and pulled GDM plus a
  140-package/548 MiB closure even with weak dependencies disabled. This
  defeats the reason for choosing a standalone tool.
- Adding `lxqt-policykit` explicitly makes the complete five-package request a
  40-package/73 MiB transaction with normal weak dependencies, with no GNOME
  Shell, GDM, Plasma, or full LXQt session.

Therefore the replacements remain valid, but `lxqt-policykit` is a required
explicit companion rather than leaving the solver to choose a policy agent.
Skanlite is dropped with no replacement as already decided.

## 3. Desktop entry

`local/applications/lf.desktop` hard-codes an asdf Go 1.18 installation path.
Block 2 now installs `lf` at `~/.local/bin/lf`, so the entry should stop naming
an implementation-specific absolute path. Proposed launch contract:

```ini
TryExec=lf
Exec=kitty --class lf -e lf %f
Terminal=false
```

This uses the settled terminal, relies on the session PATH already carrying
`~/.local/bin`, and passes the selected local directory through `%f`. Keep the
existing icon, name, categories, and `MimeType=inode/directory;`.

## 4. `local/bin` audit

No script was executed. Shell files were checked with `bash -n`; the Ruby file
was checked with `ruby -c`. Credential-bearing literals were redacted during
review.

| script | disposition | reason |
|---|---|---|
| `kill-rails-server.sh` | drop | Brittle `lsof`/grep PID extraction, unquoted variables, and unconditional `SIGKILL` can kill the wrong Ruby process. Project PID files or a project-local task are safer. |
| `generate-rails-sitemaps.sh` | move to private `dotfiles-work` | Rails/application-specific task. It also has a quoted glob in `rm -rf "./$dir/*"` that never expands and relies on Bash `globstar` without enabling it. |
| `ydl-clip.sh` | keep | Personal rather than employer-specific, but repair before porting: replace X11 `xclip` with `wl-paste`, remove fixed `DISPLAY` and hard-coded numeric D-Bus user path, reconcile `downloaded-urls.txt` versus `downloads-urls.txt`, quote/validate inputs, and replace the broad `find -newer ... -delete` cleanup. |
| `folio-test-account.rb` | move to private `dotfiles-work` | Explicitly recognizes several employer/client Rails applications and creates privileged test/admin accounts. A hard-coded test credential is declared at line 4 and reused as both login and password; its value is intentionally not reproduced here. |
| `init-sinfin-project.sh` | move to private `dotfiles-work` | Employer-specific database/bootstrap workflow. Hard-coded database username/password assignments are present at lines 15–16, a destructive `dropdb` occurs at line 52, and it invokes `sudo -u postgres`. Values are intentionally not reproduced. It needs confirmation, backup/target checks, and project-local configuration before any reuse. |
| `clear-git-branches.sh` | drop | `bash -n` reports an unmatched backtick at line 5, so it cannot parse and has never reached its body. It also assumes `master`, filters a personal branch substring, uses non-POSIX `==` under `/bin/sh`, and deletes remote branches. |

## 5. Services and system integration

### Proposed `bin/system-setup` contract

Keep the repository's no-`sudo` policy. Implement explicit user and root phases
instead of silently escalating; both phases must print the exact action before
executing it and print an explicit `already ...` message when no action is
needed.

User phase:

1. Resolve Zsh with `command -v zsh`; compare it with the login shell from
   `getent passwd "$USER"`. Only when different, print and run
   `chsh -s "$(command -v zsh)"`.
2. If Syncthing is selected and installed, use
   `systemctl --user is-enabled/is-active syncthing.service` and then print/run
   `systemctl --user enable --now syncthing.service` only for missing state.
3. Report that Docker group membership takes effect only after a fresh login;
   do not claim the current session changed.

Explicit root phase (for example `bin/system-setup --root --user NAME`, with a
validated existing non-root user):

1. For Bluetooth, use `systemctl is-enabled/is-active bluetooth.service` and
   enable/start only the missing state. Do not run `bluetoothctl power on` on
   every graphical login; leave controller auto-enable to BlueZ and verify
   physical hardware later.
2. For Docker, verify that package installation created the `docker` group;
   use `id -nG NAME` before `usermod -aG docker NAME`, then independently check
   and `systemctl enable --now docker.service` as required.
3. If PostgreSQL is approved, initialize only when the Fedora data directory is
   demonstrably uninitialized, using Fedora's `postgresql-setup --initdb`, then
   enable/start `postgresql.service`. Do not reproduce the legacy manual
   `chmod`/`chown`, and do not automatically create a passworded superuser.
4. If Valkey is approved, independently check and enable/start
   `valkey.service`. Do not pretend that this migrates Redis data/config.

Each mutating branch should have a preceding state check and a dry-run mode.
The root phase must refuse an omitted/invalid target user. Re-running either
phase should produce only `already ...` reports.

### Bluetooth findings

- Fedora package `bluez` owns `/usr/bin/bluetoothctl` and is currently installed
  on the VM. `bluetooth.service` is enabled but inactive in the headless guest.
- No current `packages/*.txt` contains `bluez`, so the working VM state is not
  reproducible yet.
- At `d25925c`, no Sway autostart file actually contains
  `bluetoothctl power on`; that command exists only in legacy
  `config/i3/on-startup.sh:14`. The active Eww Bluetooth script does invoke
  `bluetoothctl`, so the package is required regardless.

The legacy `ibus-daemon -rxRd` action already has a Wayland-native home:
`config/sway/conf.d/60-session.conf` runs `ibus start --type wayland`. Stylua,
Oh My Zsh, and runtime provisioning were also handled by earlier blocks. The
remaining legacy integration with no home is PostgreSQL initialization/service
and Redis service setup, addressed above as opt-in PostgreSQL/Valkey work.

## 6. Autostart and remaining applications

### Proton Mail Bridge

The host entry is currently:

```ini
[Desktop Entry]
Type=Application
Name=Proton Mail Bridge
Exec="protonmail-bridge" "--no-window"
X-GNOME-Autostart-enabled=true
```

Eww's active bar contains `(systray)` and Sway already runs generic XDG
autostart through `dex-autostart`, so headless Bridge startup is now reachable
from its tray icon. If the proposed Flatpak is approved, port this exact generic
entry instead:

```ini
[Desktop Entry]
Type=Application
Name=Proton Mail Bridge
TryExec=flatpak
Exec=flatpak run ch.protonmail.protonmail-bridge --no-window
Terminal=false
```

Do not retain the GNOME-specific key; the generic entry is enough for Dex. If a
native package is chosen later, change only `TryExec`/`Exec` back to the native
binary.

### Zed packaging

- Fedora 44 `fedora`/`updates`: no `zed` package.
- Named COPR `skeletorxvi/zed`: a successful Fedora 44 x86_64 build exists
  (`zed-1.20.2-1.fc44` at scan time). This is a third-party repository and was
  not enabled or installed.
- Flathub `dev.zed.Zed`: stable x86_64 entry exists at v1.20.2. Its manifest
  grants home access and host-command integration, which is useful for the
  existing `bundle`, `solargraph`, and LazyGit workflows. Guest installation is
  unverified because Flatpak is not installed.

Recommendation: use the named COPR for native toolchain/PATH behavior if its
maintainer/spec is approved; otherwise use the packaged Flathub build and test
host tool invocation. Do not use the legacy upstream `curl | sh` installer.

### Zed configuration

All four files were scanned:

- `settings.json`: the only OS path is `/bin/zsh`. It works on Fedora through
  `/bin -> /usr/bin`, but set the program to `zsh` so the config uses PATH and
  remains portable. `bundle` and `solargraph` are PATH-based and not Arch-specific.
- `tasks.json`: no Arch/Linux absolute path. Remove the tutorial `Example task`
  when porting and keep only the LazyGit task.
- `keymap.json`: no filesystem path. One binding requests task name `lazygit`
  while `tasks.json` declares `Lazygit`; normalize the case because task labels
  are identifiers.
- `keymap_backup.json`: no platform path, but it is a stale backup containing
  older action names. Drop it rather than linking it as live configuration.

## 7. Carried Neovim finding

In the separate `~/Development/nvim-next` repository,
`lua/core/mappings.lua:43` still shells out to Dolphin. Do not edit it in this
block. Replace that mapping later with a shell-free detached Neovim job, for
example:

```lua
vim.system({ 'pcmanfm-qt', vim.fn.getcwd() }, { detach = true })
```

This avoids shell quoting and terminal blocking while opening the settled
PCManFM-Qt file manager. Track and commit the change in `nvim-next`, not this
repository.

## Open questions for the user

1. Approve Flatpak/Flathub (including installing `flatpak` and adding the
   Flathub remote) for Brave, Spotify, Anki, Proton Mail Bridge, and possibly
   Telegram/Zed, or prefer reviewed native third-party repositories where
   available? The guest currently has neither Flatpak nor a remote.
2. Enable RPM Fusion free? It is needed for native `telegram-desktop` and is the
   option for full `ffmpeg`; otherwise use Telegram's Flatpak and Fedora's
   codec-limited `ffmpeg-free`. RPM Fusion is not currently enabled.
3. Are Lens and QMK still required? Lens has no source in the surveyed channels;
   QMK has no usable Fedora 44 build despite two named COPRs. If retained, their
   non-Fedora installation method needs a separate, pinned review.
4. Is Redis-to-Valkey (with `valkey-compat-redis`) acceptable for the work
   stack, including its service/data differences, or must genuine Redis remain
   external to Fedora provisioning?
