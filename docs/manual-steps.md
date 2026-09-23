# Manual steps

The installer deliberately never performs these actions automatically:

- Edit system configuration, sudoers, IPv6 settings, or `/etc/hosts`.
- Fetch, read, generate, or link secrets; handle GitHub tokens or credentials.
- Create a GitHub repository, configure its remote, or push it.

Package installation is separate. Inspect `./install packages --dry-run` and
run the selected groups as root, confirming the complete printed plan:

```sh
./install packages --dry-run --group apps,flatpak,copr
sudo ./install packages --group apps,flatpak,copr
./install link
./install tools
./install system
sudo ./install system --root --user "$(id -un)"
```

The repository never invokes `sudo` itself. The packages phase idempotently
enables the reviewed SwayFX COPR, RPM Fusion free, and the system Flathub
remote. It installs the RPM and Flatpak manifests only after showing the
actions and receiving the exact confirmation `yes`. Existing link conflicts
still require a manual decision.

The desktop group downloads the pinned Fedora 44 Wayland eww RPM in
`provision/releases.json`; the apps group does the same for Lens. Both are
checked for size and SHA-256 before the local file is handed to DNF. DNF warns
that it skipped OpenPGP checks for these local RPMs; the recorded SHA-256 is
the integrity control. `./install tools` assembles QMK from an exact set of
checksum-pinned wheels without invoking pip or an upstream installer.

An upstream repository may remove a pinned eww, Lens, or QMK artifact. If that
happens, review a replacement artifact and its published checksum, update its
complete release record, and rerun the appropriate phase. Never bypass a size
or checksum mismatch and never substitute `curl | sh`.

## Block 7 follow-up

The following remain machine- or account-specific:

- Create and unlock GNOME Keyring's login keyring interactively on first use.
  The Sway session starts Fedora's packaged Secret Service user unit before XDG
  autostart, but portable dotfiles do not modify PAM or authselect. Login-time
  auto-unlock belongs to the physical machine's login stack.
- Sign in to Proton Mail Bridge and confirm mail-client integration. Its
  `--no-window` autostart and Eww tray registration work in the VM.
- Sign in to Spotify, Anki, Lens, and Zed as needed. Confirm Zed's Flatpak can
  reach each project toolchain; its manifest has broad home access, but real
  project/LSP behavior was not exercised.
- Configure Timeshift only after choosing real snapshot storage. No backup was
  created or treated as verified during this block. Before relying on one,
  independently check its contents, metadata, integrity, and restore usability.
- Test brightness control, Bluetooth pairing, OpenRGB, QMK device access and
  flashing, scanners, and workstation output placement on physical hardware.
  The VM has no Bluetooth controller, backlight, RGB controller, or QMK board.
- PostgreSQL packages are installed, but the cluster was deliberately not
  initialized and `postgresql.service` was not enabled. Before any later
  initialization or migration, establish the intended data directory and
  independently verify any source backup and restore path. Run Fedora's
  `postgresql-setup --initdb` only when the target is demonstrably
  uninitialized; never copy the legacy manual ownership/password procedure.
- Redis and Valkey are intentionally outside dotfiles provisioning. Projects
  that need one must own their version, data, and service lifecycle.
- The three employer/client scripts selected for `dotfiles-work` were not
  copied because no local private checkout was available and its remote could
  not be authenticated. Create or obtain that private repository before
  reviewing and migrating them. Credential-bearing legacy values were not
  read or reproduced.
- The PCManFM-Qt Neovim mapping is committed separately in `nvim-next`. The
  dotfiles submodule remains on the last published Neovim commit so a fresh
  clone stays resolvable. The current host also rejects the ownership/mode of
  `/etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf`, so `bin/sync-nvim` cannot
  fetch yet. After correcting that host configuration and publishing the
  Neovim commit, run `bin/sync-nvim`; do not hand-edit the gitlink.

The VM confirms application installation, tty2 Sway/Eww startup, workspace and
Bluetooth script behavior, Proton Bridge autostart, and a registered tray item.
Multi-output layout, audio hardware, Bluetooth hardware, and the device tasks
above still require the physical workstation.

Public Nerd Fonts and private assets are a separate step:

```sh
bin/fetch-assets
```

The command downloads the Nerd Fonts v3.5.1 Iosevka and Meslo archives, verifies
their pinned SHA-256 digests, and installs only the Regular, Bold, and Italic
faces below `~/.local/share/fonts/dotfiles-releases`. It does not install the
Mono or Propo variants, other weights, oblique faces, or Bold Italic because no
configuration in this repository or the audited legacy desktop configuration
selects them. The user font cache is refreshed after installation.

MonoLisa, Font Awesome 5 Pro, and the curated wallpapers remain optional paid
assets. When a GitHub SSH key can access the private
`VladaTrefil/dotfiles-assets` repository, the same command clones it to
`~/.local/share/dotfiles-assets`, links its fonts below
`~/.local/share/fonts`, and links its wallpapers at `~/.background`. Missing
private-repository access produces an actionable warning but does not prevent
the public fonts from installing.

`bin/fetch-assets --offline` performs no network access. It requires both Nerd
Fonts archives to be present in the verified release cache and uses the private
checkout only when one is already present.

Fedora 44 packages `google-noto-sans-jp-fonts` and
`google-noto-color-emoji-fonts`, which provide the exact `Noto Sans JP` and
`Noto Color Emoji` families and are listed in `packages/fonts.txt`. Fedora does
not package the required Iosevka or MesloLGS Nerd Font families, so those two
are automated by the checksum-pinned release path above. Powerlevel10k's own
interactive font downloader is not invoked.
