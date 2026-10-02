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

## Refreshing eww and Lens pins

Two records in `provision/releases.json` need particular attention:

- **eww:** the `dturner/eww` COPR build URL includes a build directory. COPR
  garbage-collects old builds, so a previously valid URL can return HTTP 404.
  The desktop packages phase then reports `eww: pinned RPM unavailable` after
  curl's HTTP error.
- **Lens:** the vendor URL currently ends in
  `Lens-2026.9.181013-latest.x86_64.rpm`. Treat the `-latest` artifact as
  potentially replaceable in place, even though its filename includes a
  version; this is a maintenance risk, not a confirmed vendor immutability
  guarantee. Replacement bytes produce `lens: downloaded size mismatch;
  nothing installed` or `lens: downloaded SHA-256 mismatch; nothing installed`.
  Removal instead produces `lens: pinned RPM unavailable`; the shared error's
  COPR hint applies to eww, not Lens.

These failures are intentional: a missing download or mismatched size/digest
stops the packages phase before that RPM reaches DNF. There is no fallback to
an unpinned release or acceptance of new bytes. An already cached, verified RPM
can still be used after its upstream URL disappears; cached files are checked
again and fail with `cached size mismatch` or `cached SHA-256 mismatch` if
altered. Thus a warm cache can hide URL expiry until a fresh install.

Refresh a pin as one reviewed change:

1. **Find the authoritative artifact and metadata.** For eww, start at the
   [dturner/eww COPR project](https://copr.fedorainfracloud.org/coprs/dturner/eww/)
   and its successful builds. Select the Wayland eww RPM for the target Fedora
   release and `x86_64`, not a source/debug RPM or an unrelated X11 build.
   For the current Fedora 44 target, the repository base is
   `https://download.copr.fedorainfracloud.org/results/dturner/eww/fedora-44-x86_64/`.
   For Lens, follow the vendor's
   [RPM installation documentation](https://docs.lenshq.io/k8slens/getting-started/install-lens/)
   to `https://downloads.k8slens.dev/rpm/lens.repo`; use its HTTPS `baseurl`
   (currently `https://downloads.k8slens.dev/rpm/packages`) and select the
   current stable `lens` package for `x86_64`.
2. **Obtain the published checksum independently of the RPM.** At either
   repository base, fetch `repodata/repomd.xml` over verified HTTPS, follow its
   `data type="primary"` location, and verify that metadata download against
   the checksum in `repomd.xml` before decompressing/reading it. The matching
   package entry in primary XML supplies `location href`, `version` (`ver` and
   `rel`), `size package` in bytes, and `checksum type="sha256"`. Resolve its
   location relative to the repository base. Use authenticated signatures when
   supplied and verify their key through the publisher's documented channel.
   A publisher-signed checksum manifest is also acceptable. If authoritative
   SHA-256 metadata is absent, stop and obtain it from the publisher.
3. **Verify and update all four fields together:** `url`, `version` (RPM
   `ver-rel`, preserving e.g. Lens's `~latest` spelling), `size`, and `sha256`.
   Download the candidate RPM to a temporary directory and compare its size
   and computed SHA-256 with that independently published metadata. Never
   derive the expected checksum from the same unverified download it is
   supposed to verify: running `sha256sum` on an arbitrary RPM and pasting the
   result into the pin proves nothing about its authenticity. Record the
   metadata source and selected build/release in the change's review evidence.
4. Run `tests/release-test.py`, then verify the changed pin without installing
   packages using an empty disposable cache:

   ```sh
   pin_cache=$(mktemp -d)
   XDG_CACHE_HOME="$pin_cache" bin/install-releases --rpm --group desktop  # eww
   XDG_CACHE_HOME="$pin_cache" bin/install-releases --rpm --group apps     # Lens
   rm -rf -- "$pin_cache"
   ```

   Run only the relevant group if refreshing one pin. Inspect
   `./install packages --dry-run --group desktop` (or `apps`) before rerunning
   the corresponding packages phase with its normal confirmation.

In contrast, **asdf, stylua, selene, lf, lazygit, op, and both Nerd Fonts** use
versioned release URLs, without the COPR build-retention or suspected rolling
pointer risk. They do not need refresh merely because a newer release appears.
Versioned URLs are not a promise of permanent hosting: an upstream deletion or
replacement can still fail closed. Review any replacement and its published
checksum; never bypass size/SHA-256 checks or substitute `curl | sh`.

## 1Password and the secrets manifest

`./install tools` installs only the checksum-pinned 1Password CLI. The
1Password desktop application is deliberately not installed; install it
manually if desktop integration or biometric unlock is wanted, then enable its
CLI integration and sign in.

Keep the real manifest at
`${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/secrets.tsv`, outside this checkout.
It is personal rather than secret, but its vault/item layout is machine- and
account-specific and does not belong in shared dotfiles. Start from
`config/secrets.tsv.example`, replace every placeholder `op://` reference, and
run `bin/check-secrets`. The command prints only `OK` or `MISSING` plus the
variable name; it never prints a resolved value or forwards `op` diagnostics.

`GITHUB_USERNAME` and `GITHUB_KEY_NAME` are included so one command checks the
whole credential set even though those two values are not secrets. Review the
remaining need for `GITHUB_PASSWORD`: if a current consumer still exists now
that `install-base.sh` is gone, a least-privilege fine-grained GitHub token is a
better fit than an account password.

## GNOME Keyring login auto-unlock

Chromium and Proton Mail Bridge use `org.freedesktop.secrets`, which this setup
provides through `gnome-keyring-d`. 1Password cannot replace it: neither the
desktop application nor `op` implements the Secret Service interface, and
there is no supported mechanism for feeding a GNOME Keyring passphrase from a
1Password item. Keep the account password in 1Password if desired, then let PAM
pass that same password directly to GNOME Keyring during password login.

The apps package group installs both halves: `gnome-keyring` provides the
Secret Service daemon, while `gnome-keyring-pam` provides
`pam_gnome_keyring.so`. After installing that group, review the active profile
and enable Fedora's native feature manually:

```sh
authselect current
authselect list-features local | grep -F with-pam-gnome-keyring
sudo authselect enable-feature with-pam-gnome-keyring
authselect current
```

Do not put this in the installer. Authselect and PAM are machine-wide,
password-sensitive settings outside portable dotfiles. Auto-unlock also
requires the **login keyring password to equal the account password** and a
login method that supplies that password; passwordless or automatic login
cannot pass a password to the keyring.

If the keyring still prompts separately, install Fedora's `seahorse` package if
the command is absent, then open Passwords and Keys (`seahorse`), select the
Login keyring, choose **Change Password**, and set its new password to the
current account password. If its old password is unknown and its stored secrets
can be discarded, delete the Login keyring in Seahorse, log out, and log back
in with the account password so it is recreated. Deleting a keyring permanently
loses the secrets it contains; do not use that recovery path when those contents
are needed.

## Sway after a tty1 password login

`.zprofile` starts Sway only for an interactive shell with terminal input and
output, `XDG_VTNR=1`, and Zsh's `TTY=/dev/tty1`. `WAYLAND_DISPLAY`, `DISPLAY`,
and `SWAYSOCK` must all be unset (even an empty set value prevents startup),
as must `SSH_CONNECTION`, `SSH_CLIENT`, and `SSH_TTY`. SSH logins, other VTs,
non-interactive commands, and existing graphical sessions keep their shell.

The existing Sway profiles are explicit choices: `physical` uses
`~/.config/sway/bin/start-physical` and `virtualbox` uses
`~/.config/sway/bin/start-virtualbox`. There was no persisted machine selector
or hardware detection in this setup. Select the same profile by adding
`export SWAY_PROFILE=physical` or `export SWAY_PROFILE=virtualbox` to the
machine's existing `${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles-private/login.sh`
(create its parent directory/file if absent; preserve existing settings).
That file is already sourced by `.zprofile` before the guard. No default is
guessed: an unset/unknown profile or missing/non-executable launcher leaves a
prompt. Launcher paths use `~/.config`, matching both existing launchers'
configuration paths.

The launcher runs as a child, so a failed Sway config or normal compositor exit
returns to the same login shell without retrying. The usual console password
login still happens first. No getty, login, PAM, authselect, or sudo setting is
changed; **do not enable automatic/passwordless login**. PAM must receive the
account password for the GNOME Keyring auto-unlock described above.

To bypass autostart before another tty1 login, log in on tty2 (Ctrl+Alt+F2) or
over SSH and create this marker outside the repository-backed Sway directory:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
touch "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/sway-autostart-disabled"
```

The next tty1 login reaches a plain shell even if the profile is selected.
Remove the marker to re-enable startup. Alternatively set
`export DOTFILES_SWAY_AUTOSTART=0` in the machine's private login settings;
remove that setting to re-enable. For an additional login shell started from
an existing prompt, `DOTFILES_SWAY_AUTOSTART=0 zsh -l` bypasses startup too.

## Block 7 follow-up

The following remain machine- or account-specific:

- Complete the GNOME Keyring authselect and password-alignment procedure above
  on each machine. The Sway session starts Fedora's packaged Secret Service user
  unit before XDG autostart, but the installer never modifies PAM or authselect.
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
