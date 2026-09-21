# Fedora 44 package survey — B0

Verified on the running Fedora 44 x86_64 Minimal guest on **2026-09-21**, kernel
`7.2.5-200.fc44.x86_64`. This is input to Blocks 2 and 7, not an install list.
The survey covers all 108 distinct uncommented `yay` entries in the read-only legacy
`build/install.conf.yaml` at `1d979ad`, every one of the 47 tool rows in
[`modules/nvim/docs/external-tools.md`](../modules/nvim/docs/external-tools.md) at
`cd96da09d10a76c4af6d0bbbbf3113eaba294351`, the legacy runtime installers, and B0 desktop tools.
The duplicate legacy `ark` entry is represented once. Commented examples are not requirements.

## Evidence and interpretation

All table package names, versions and repository availability come from **DNF on the VM**,
with COPRs disabled for the Fedora survey. EVR includes an epoch when nonzero.
Queries selected the latest x86_64/noarch package per name across `fedora`, `updates` and
`fedora-cisco-openh264`. The only enabled third-party repository is `swayfx/swayfx`.

```sh
# Guest; append the candidate package names from a table row.
dnf --disable-repo='copr:*' repoquery --available --latest-limit=1 \
  --arch=x86_64,noarch --queryformat='%{name}|%{evr}|%{arch}|%{repoid}\n' PACKAGE...
# Resolve binaries where Fedora package names differ.
dnf --disable-repo='copr:*' repoquery --available --latest-limit=1 \
  --arch=x86_64,noarch --whatprovides=/usr/bin/COMMAND \
  --queryformat='%{name}|%{evr}|%{arch}|%{repoid}\n'
```

Raw commands and output are in the transition report
`../dotfiles-transition/reports/B0-vm-baseline.md` and its `B0-evidence/` attachments.
“Missing” means the listed package candidates (and, where stated, `/usr/bin` providers)
returned no match in the queried Fedora repositories, not proof that no third-party package exists.
Upstream/npm/gem/PyPI/Flatpak/source alternatives are **UNVERIFIED on the VM**, including their
versions, installability and compatibility. No alternative repository except SwayFX was enabled.
Availability is not a runtime test, and libraries/development headers may need additional packages
when later blocks actually build software.

## Installed for B0

Only these explicit packages and their required dependencies were installed. Weak dependencies
were disabled. Python was already present. Neovim was installed solely for `nvim --version`;
no editor plugin or parser install was run. `swaybg` arrived as a SwayFX dependency.

| Tool / legacy name | Fedora 44 result: package — EVR (repository) | Notes / missing options |
|---|---|---|
| `git` | `git` — `2.55.0-1.fc44` (updates) | Installed; confirmed with rpm -q. |
| `tar` | `tar` — `2:1.35-9.fc44` (updates) | Installed; confirmed with rpm -q. |
| `rsync` | `rsync` — `3.5.0-2.fc44` (updates) | Installed; confirmed with rpm -q. |
| `python3` | `python3` — `3.14.7-1.fc44` (updates) | Installed; confirmed with rpm -q. |
| `bubblewrap` | `bubblewrap` — `0.12.0-1.fc44` (updates) | Installed; confirmed with rpm -q. |
| `dnf-plugins-core` | `dnf-plugins-core` — `4.10.1-9.fc44` (fedora) | Installed; confirmed with rpm -q. |
| `kitty` | `kitty` — `0.47.1-1.fc44` (updates) | Installed; confirmed with rpm -q. |
| `wl-clipboard` | `wl-clipboard` — `2.2.1^git20251124.e808203-2.fc44` (fedora) | Installed; confirmed with rpm -q. |
| `xorg-x11-server-Xwayland` | `xorg-x11-server-Xwayland` — `24.1.13-1.fc44` (updates) | Installed; confirmed with rpm -q. |
| `virtualbox-guest-additions` | `virtualbox-guest-additions` — `7.2.16-1.fc44` (updates) | Installed; confirmed with rpm -q. |
| `neovim` | `neovim` — `0.12.5-1.fc44` (updates) | Installed; confirmed with rpm -q. |

SwayFX is installed as `swayfx-0.5.2-1.fc43.x86_64` from
[`swayfx/swayfx`](https://copr.fedorainfracloud.org/coprs/swayfx/swayfx/), repository ID
`copr:copr.fedorainfracloud.org:swayfx:swayfx` and
[Fedora 44 x86_64 repository](https://download.copr.fedorainfracloud.org/results/swayfx/swayfx/fedora-44-x86_64/).
The Fedora 44 repository carries an **fc43-built SwayFX RPM**, not a newly built fc44 SwayFX RPM.
Before enabling it, the guest fetched project/primary metadata and DNF successfully resolved
an `--assumeno` transaction against that repository. Installation then succeeded, using
`scenefx-0.4.1-0.4.1-1.fc44` and Fedora `wlroots0.19-0.19.3-1.fc44`.
The binary reports `swayfx version 0.5.2 (based on sway 1.10.1)`; no plain `sway` RPM is installed.
Graphical rendering still needs the user's TTY test.

Guest additions are `7.2.16-1.fc44`, host VirtualBox reports `7.2.18r175117`: same 7.2 series,
not an exact patch match. `vboxservice` is enabled/active and the target remains `multi-user.target`.
See [VM handoff](fedora-vm-baseline.md) for clipboard setup and the graphical checks.

## Neovim external tools

Required editor/bootstrap tools and optional features retain the distinctions in the upstream
inventory. The last nine rows describe dormant configuration or old lists, not mandatory installs.

| Tool / legacy name | Fedora 44 result: package — EVR (repository) | Notes / missing options |
|---|---|---|
| `nvim` | `neovim` — `0.12.5-1.fc44` (updates) | Installed; version command only. Plugin bootstrap deliberately deferred to Block 3. |
| `git` | `git` — `2.55.0-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `curl` | `curl` — `8.18.0-10.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `tar`, `gzip` | `tar` — `2:1.35-9.fc44` (updates)<br>`gzip` — `1.14-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `tree-sitter` | `tree-sitter-cli` — `0.26.11-1.fc44` (updates) | Available version exceeds the locked plugin requirement 0.26.1; CLI not installed in B0. |
| `cc` (or a supported C compiler, e.g. `gcc`/`clang`) | `gcc` — `16.2.1-2.fc44` (updates)<br>`clang` — `22.1.8-4.fc44` (updates) | Both compiler packages available; neither installed for this step. |
| `bash`, `sh` | `bash` — `5.3.9-3.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `env`, `dirname`, `mktemp`, `mkdir`, `chmod`, `ln`, `rm` | `coreutils` — `9.10-5.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `rg` | `ripgrep` — `15.2.0-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `fd` or `find` (with `rg` as another picker fallback) | `fd-find` — `10.4.2-4.fc44` (updates)<br>`findutils` — `1:4.10.0-7.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `sed` | `sed` — `4.9-7.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `python3` | `python3` — `3.14.7-1.fc44` (updates)<br>`python3-neovim` — `0.6.0-4.fc44` (updates) | python3-neovim is the provider package; only the Python runtime was installed in B0. |
| `node` | `nodejs24` — `1:24.18.0-1.fc44` (updates)<br>`nodejs24-bin` — `1:24.18.0-1.fc44` (updates) | Versioned Fedora packaging; nodejs24-bin provides /usr/bin/node. Node 20 and 22 variants also available. |
| `npm` | `nodejs24-npm` — `1:11.16.0-1.24.18.0.1.fc44` (updates)<br>`nodejs24-npm-bin` — `1:24.18.0-1.fc44` (updates) | nodejs24-npm-bin provides /usr/bin/npm; npm implementation version is 11.16.0. |
| `ruby` | `ruby` — `4.0.6-38.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `bundle` | `rubygem-bundler` — `4.0.16-38.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `rails`, project `bin/rails` | `rubygem-rails` — `1:8.0.3-2.fc44` (fedora) | Fedora Rails exists; project Gemfile/binstub versions still control project commands. |
| `dolphin` | `dolphin` — `26.08.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `man` | `man-db` — `2.13.1-3.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `xdg-open` or `gio` | `xdg-utils` — `1.2.1-5.fc44` (fedora)<br>`glib2` — `2.88.3-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `wl-copy`, `wl-paste` **or** `xclip`/`xsel` | `wl-clipboard` — `2.2.1^git20251124.e808203-2.fc44` (fedora)<br>`xclip` — `0.13-26.git11cba61.fc44` (fedora)<br>`xsel` — `1.2.1-10.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `vscode-eslint-language-server` | **Missing in queried Fedora metadata**; names: `vscode-langservers-extracted` | Missing native candidate/provider; npm vscode-langservers-extracted candidate, unverified. Project ESLint library/config also required. |
| `rubocop` | **Missing in queried Fedora metadata**; names: `rubygem-rubocop` | Missing native candidate/provider; project gem rubocop via Bundler, unverified. |
| `shellcheck` | `ShellCheck` — `0.11.0-4.fc44` (fedora) | Package capitalization is ShellCheck. Not installed; guest lint explicitly skipped. |
| `standard` | **Missing in queried Fedora metadata**; names: `standard`, `nodejs-standard` | Missing native candidate/provider; npm standard candidate, unverified. |
| `selene` | **Missing in queried Fedora metadata**; names: `selene` | Missing native candidate/provider; upstream Rust binary/source candidate, unverified. |
| `stylelint` | **Missing in queried Fedora metadata**; names: `stylelint`, `nodejs-stylelint` | Missing native candidate/provider; npm stylelint plus project rules/config candidate, unverified. |
| `mypy` | `python3-mypy` — `1.18.2-4.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `pylint` | `python3-pylint` — `4.0.5-1.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `slim-lint` | **Missing in queried Fedora metadata**; names: `rubygem-slim_lint` | Missing native candidate/provider; gem slim_lint candidate, unverified. |
| `jsonlint` | `python3-demjson` — `2.2.4-43.fc44` (fedora) | Provider exists, but is Python demjson, not the documented npm jsonlint. CLI/Neovim compatibility UNVERIFIED; npm jsonlint remains a candidate. |
| `codespell` | `codespell` — `2.4.2-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `stylua` | **Missing in queried Fedora metadata**; names: `stylua` | Missing native candidate/provider; upstream StyLua binary/source candidate, unverified. |
| `isort` | `python3-isort` — `7.0.0-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `black` | `black` — `26.5.1-1.fc44` (updates) | Package is black, not python3-black; /usr/bin/black provider verified. |
| `prettier` | **Missing in queried Fedora metadata**; names: `prettier`, `nodejs-prettier` | Missing native candidate/provider; npm prettier candidate, unverified. |
| `shfmt` | `shfmt` — `3.7.0-5.fc41` (fedora) | B2d: `/usr/bin/shfmt` owned by this RPM; upstream `mvdan/sh` and Conform formatting with `-i 2` verified on Fedora 44. |
| `clang-format` | `clang-tools-extra` — `22.1.8-4.fc44` (updates) | /usr/bin/clang-format provider verified as clang-tools-extra. |
| `lua-language-server` | **Missing in queried Fedora metadata**; names: `lua-language-server` | Inactive. Missing native candidate/provider; upstream LuaLS binary/source candidate, unverified. |
| `vscode-css-language-server` (old `css-lsp`) | **Missing in queried Fedora metadata**; names: `vscode-langservers-extracted` | Inactive. Missing native candidate/provider; npm vscode-langservers-extracted candidate, unverified. |
| `vscode-json-language-server` | **Missing in queried Fedora metadata**; names: `vscode-langservers-extracted` | Inactive. Missing native candidate/provider; npm vscode-langservers-extracted candidate, unverified. |
| `typescript-language-server` | **Missing in queried Fedora metadata**; names: `typescript-language-server` | Inactive. Server missing; npm typescript-language-server candidate, unverified. Fedora typescript 5.7.3-6.fc44 exists but is not this server. |
| `pylsp` | `python3-lsp-server` — `1.13.1-6.fc44` (fedora) | Inactive; native package found. |
| `solargraph` | **Missing in queried Fedora metadata**; names: `rubygem-solargraph` | Inactive. Missing native candidate/provider; gem solargraph candidate, unverified. |
| `rustfmt` | `rustfmt` — `1.98.1-1.fc44` (updates) | Old list only; not required by current Neovim configuration. |
| `vim-language-server` | **Missing in queried Fedora metadata**; names: `vim-language-server` | Old list only. Missing native candidate/provider; npm vim-language-server candidate, unverified. |
| `yaml-language-server` | **Missing in queried Fedora metadata**; names: `yaml-language-server` | Old list only. Missing native candidate/provider; npm yaml-language-server candidate, unverified. |

## Legacy package inventory

| Tool / legacy name | Fedora 44 result: package — EVR (repository) | Notes / missing options |
|---|---|---|
| `readline` | `readline` — `8.3-4.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `alsa-utils` | `alsa-utils` — `1.2.16-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `curl` | `curl` — `8.18.0-10.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `ca-certificates` | `ca-certificates` — `2026.2.90_v9.0.317-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `git` | `git` — `2.55.0-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `gnupg` | `gnupg2` — `2.4.9-16.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `asdf-vm` | **Missing in queried Fedora metadata**; names: `asdf` | Missing; upstream version manager candidate (unverified). Legacy runtime pins need a separate decision. |
| `pipewire` | `pipewire` — `1.6.9-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `pipewire-pulse` | `pipewire-pulseaudio` — `1.6.9-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `pipewire-audio` | `pipewire` — `1.6.9-1.fc44` (updates)<br>`pipewire-alsa` — `1.6.9-1.fc44` (updates)<br>`pipewire-pulseaudio` — `1.6.9-1.fc44` (updates) | Arch grouping mapped to Fedora audio packages; final audio/service selection belongs to a later block. |
| `bluez` | `bluez` — `5.87+1.git8750129efca8-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `bluez-utils` | `bluez` — `5.87+1.git8750129efca8-1.fc44` (updates) | Fedora bluez package; session/service behavior untested. |
| `zsh` | `zsh` — `5.9-21.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `i3` | `i3` — `4.25.1-1.fc44` (fedora) | Legacy X11 window manager; retained in survey, not selected for the Wayland target. |
| `picom` | `picom` — `13-1.fc44` (fedora) | Legacy X11 compositor; retained in survey. |
| `feh` | `feh` — `3.12.4-1.fc44` (updates) | Legacy X11 wallpaper/image tool; swaybg is the Wayland wallpaper candidate. |
| `dunst` | `dunst` — `1.13.2-1.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `eww` | **Missing in queried Fedora metadata**; names: `eww` | Missing from Fedora repositories. COPRs were found; see the Eww finding below. Block 6 owns the decision. |
| `rofi` | `rofi` — `2.0.0-2.fc44` (fedora) | 2.x Wayland release; no rofi-wayland split required by this survey. |
| `qt5ct` | `qt5ct` — `1.9-8.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `qt6ct` | `qt6ct` — `0.11-17.20250907git23a985f.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `konsole` | `konsole` — `26.08.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `inkscape` | `inkscape` — `1.4.4-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `brave-bin` | **Missing in queried Fedora metadata**; names: `brave-browser` | Missing; upstream Brave RPM repository or desktop packaging candidate (unverified). |
| `chromium` | `chromium` — `153.0.8010.36-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `thunderbird` | `thunderbird` — `155.0-4.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `spectacle` | `spectacle` — `1:6.7.5-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `dolphin` | `dolphin` — `26.08.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `picard` | `picard` — `2.13.3-6.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `qbittorrent` | `qbittorrent` — `1:5.2.3-4.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `ark` | `ark` — `26.08.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `vlc` | `vlc` — `1:3.0.23-10.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `mpv` | `mpv` — `0.41.0-5.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `skanlite` | `skanlite` — `26.08.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `gnome-system-monitor` | `gnome-system-monitor` — `50.0-1.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `partitionmanager` | `kde-partitionmanager` — `26.08.1-1.fc44` (updates) | Fedora name differs; gparted is also available. |
| `telegram-desktop` | **Missing in queried Fedora metadata**; names: `telegram-desktop` | Missing; upstream desktop/Flatpak packaging candidate (unverified). |
| `krita` | `krita` — `6.0.2.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `spotify-launcher` | **Missing in queried Fedora metadata**; names: `spotify-launcher`, `spotify-client` | Missing under queried names; upstream Spotify/Flatpak packaging candidate (unverified). |
| `strawberry` | `strawberry` — `1.2.28-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `anki` | **Missing in queried Fedora metadata**; names: `anki` | Missing; upstream desktop distribution or Flatpak candidate (unverified). |
| `docker` | `moby-engine` — `29.7.2-1.fc44` (updates) | moby-engine is available; Docker CE is not in enabled Fedora repositories. Engine choice belongs to later provisioning. |
| `docker-compose` | `docker-compose` — `5.5.1-1.fc44` (updates) | Fedora package found; CLI compatibility with existing workflows untested. |
| `docker-buildx` | `docker-buildx` — `0.37.1-1.fc44` (updates) | Fedora package found; not installed or exercised. |
| `docker-desktop` | **Missing in queried Fedora metadata**; names: `docker-desktop` | Missing; upstream Docker RPM distribution candidate (unverified); not interchangeable with the engine. |
| `protonmail-bridge` | **Missing in queried Fedora metadata**; names: `protonmail-bridge` | Missing; upstream RPM candidate (unverified). |
| `lens-bin` | **Missing in queried Fedora metadata**; names: `lens` | Missing; upstream Lens distribution candidate (unverified). |
| `timeshift` | `timeshift` — `25.12.4-2.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `libreoffice-fresh` | `libreoffice` — `1:26.2.6.3-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `libreoffice-fresh-cs` | `libreoffice-langpack-cs` — `1:26.2.6.3-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `libreoffice-fresh-en-gb` | `libreoffice-langpack-en-GB` — `1:26.2.6.3-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `virtualbox` | **Missing in queried Fedora metadata**; names: `VirtualBox`, `virtualbox` | Missing from Fedora repositories; third-party host packaging unverified. B0 only needs guest additions. |
| `virtualbox-guest-iso` | **Missing in queried Fedora metadata**; names: `virtualbox-guest-iso`, `VirtualBox-guest-additions` | Missing under queried names; not needed here. Use Fedora virtualbox-guest-additions, not an Oracle ISO. |
| `virtualbox-guest-utils` | `virtualbox-guest-additions` — `7.2.16-1.fc44` (updates) | Fedora guest integration package; installed in B0. |
| `syncthing` | `syncthing` — `2.1.3-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `ffmpeg` | `ffmpeg-free` — `8.1.2-4.fc44` (updates) | Fedora supplies ffmpeg-free; codec coverage is not equivalent to every third-party ffmpeg build. Other repositories unverified. |
| `bat` | `bat` — `0.26.1-4.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `bc` | `bc` — `1.08.2-4.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `mercurial` | `mercurial` — `7.2.4-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `ripgrep` | `ripgrep` — `15.2.0-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `fd` | `fd-find` — `10.4.2-4.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `unzip` | `unzip` — `6.0-69.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `xclip` | `xclip` — `0.13-26.git11cba61.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `ifstat` | `ifstat` — `1.1-50.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `jq` | `jq` — `1.8.1-3.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `moreutils` | `moreutils` — `0.68-6.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `perl-rename` | `prename` — `1.14-9.fc44` (fedora) | Fedora name is prename. |
| `speedtest-cli` | `speedtest-cli` — `2.1.3-17.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `playerctl` | `playerctl` — `2.4.1-12.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `aws-cli` | `awscli2` — `2.36.0-1.fc44` (updates) | Fedora supplies awscli2. |
| `brightnessctl` | `brightnessctl` — `0.5.1-16.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `networkmanager` | `NetworkManager` — `1:1.56.1-2.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `yt-dlp` | `yt-dlp` — `2026.08.19-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `qmk` | **Missing in queried Fedora metadata**; names: `qmk` | Missing; upstream Python CLI in an isolated environment or upstream source candidate (unverified). |
| `neofetch` | **Missing in queried Fedora metadata**; names: `neofetch` | Missing; fastfetch 2.68.1-1.fc44 is available as a replacement candidate, not installed. |
| `lsof` | `lsof` — `4.98.0-9.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `neovim` | `neovim` — `0.12.5-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `lazygit` | **Missing in queried Fedora metadata**; names: `lazygit` | Missing; upstream binary/source or a separately verified COPR candidate (unverified). |
| `ranger` | `ranger` — `1.9.4-9.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `lf` | **Missing in queried Fedora metadata**; names: `lf` | Missing; upstream binary/source candidate (unverified). |
| `ibus` | `ibus` — `1.5.34-4.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `ibus-mozc` | `ibus-mozc` — `2.29.5111.102-18.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `openrgb` | `openrgb` — `1.0~rc2-3.20260126git74cbdcc.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `python` | `python3` — `3.14.7-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `python-pylint` | `python3-pylint` — `4.0.5-1.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `python-i3ipc` | `python3-i3ipc` — `2.2.1-20.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `python-pynvim` | `python3-neovim` — `0.6.0-4.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `python-isort` | `python3-isort` — `7.0.0-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `python-devtools` | **Missing in queried Fedora metadata**; names: `python3-devtools` | Missing under queried Python package names; PyPI devtools in an isolated environment candidate (unverified). |
| `python-virtualenv` | `python3-virtualenv` — `20.35.4-4.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `mypy` | `python3-mypy` — `1.18.2-4.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `lua` | `lua` — `5.4.8-5.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `postgresql` | `postgresql` — `18.6-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `postgresql-libs` | `libpq` — `18.0-4.fc44` (fedora) | Fedora client library package is libpq; postgresql-private-libs is separate and is not a general client dependency. |
| `libpqxx` | `libpqxx` — `1:7.10.5-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `imagemagick` | `ImageMagick` — `1:7.1.2.31-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `perl-image-exiftool` | `perl-Image-ExifTool` — `13.50-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `rubber` | `rubber` — `1.6.1-14.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `texlive-xetex` | `texlive-xetex` — `12:svn77830-111.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `libsodium` | `libsodium` — `1.0.22-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `pdftk` | `pdftk-java` — `3.3.3-11.fc44` (fedora) | Fedora supplies the Java implementation; behavior untested. |
| `ghostscript` | `ghostscript` — `10.06.0-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `redis` | `valkey` — `9.0.6-1.fc44` (updates) | Redis name absent; valkey available. Migration/compatibility is a later decision. |
| `libvips` | `vips` — `8.18.3-2.fc44` (updates) | Fedora package name is vips. |
| `openslide` | `openslide` — `4.0.0-14.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `gifsicle` | `gifsicle` — `1.96-3.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `libwebp` | `libwebp` — `1.6.0-3.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `freetds` | `freetds` — `1.5.18-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |

## Additional Wayland desktop candidates

| Tool / legacy name | Fedora 44 result: package — EVR (repository) | Notes / missing options |
|---|---|---|
| `kitty` | `kitty` — `0.47.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `rofi` | `rofi` — `2.0.0-2.fc44` (fedora) | Verified 2.0.0 Wayland release; not installed in B0. |
| `dunst` | `dunst` — `1.13.2-1.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `wl-clipboard` | `wl-clipboard` — `2.2.1^git20251124.e808203-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `grim` | `grim` — `1.5.0-3.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `slurp` | `slurp` — `1.5.0-6.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `swaybg` | `swaybg` — `1.2.2-1.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `swayidle` | `swayidle` — `1.9.0-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `swaylock` | `swaylock` — `1.8.6-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `xorg-x11-server-Xwayland` | `xorg-x11-server-Xwayland` — `24.1.13-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `virtualbox-guest-additions` | `virtualbox-guest-additions` — `7.2.16-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `pcmanfm-qt` | `pcmanfm-qt` — `2.4.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `xarchiver` | `xarchiver` — `0.5.4.26-2.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `gparted` | `gparted` — `1.7.0-3.fc44` (fedora) | Repository availability verified; feature integration not assessed. |
| `gvfs` | `gvfs` — `1.60.3-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `zsh` | `zsh` — `5.9-21.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `waybar` | `waybar` — `0.15.0-2.fc44` (updates) | Repository availability verified; feature integration not assessed. |

## Legacy runtime installers and shell-installed editor

The legacy file also requests asdf Node 20.9.0, Ruby 2.6.0/2.6.6/2.6.8/2.6.9/2.7.5/3.0.0/3.1.1/3.1.2/3.2.2,
Java openjdk-17.0.2 and Rust 1.62.0, and runs the upstream Zed installer.
Those exact versions and the asdf plugins were **not installed or validated**. Current Fedora
packages below are availability findings, not approval to replace pinned project runtimes.

| Tool / legacy name | Fedora 44 result: package — EVR (repository) | Notes / missing options |
|---|---|---|
| `nodejs20` | `nodejs20` — `1:20.20.2-3.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `nodejs22` | `nodejs22` — `1:22.23.1-2.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `nodejs24` | `nodejs24` — `1:24.18.0-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `ruby` | `ruby` — `4.0.6-38.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `java-25-openjdk-devel` | `java-25-openjdk-devel` — `1:25.0.4.1.1-1.1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `rust` | `rust` — `1.98.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `cargo` | `cargo` — `1.98.1-1.fc44` (updates) | Repository availability verified; feature integration not assessed. |
| `zed` | **Missing in queried Fedora metadata**; names: `zed` | Missing under this name; legacy upstream installer is an unverified candidate. |

`java-17-openjdk-devel` was queried and absent. Fedora's listed OpenJDK 25 package is not a
substitute for the legacy Java 17 pin without a later compatibility decision.

## Eww: correction to the brief; decision stays in Block 6

**Eww is not packaged in the queried Fedora 44 repositories.** However, the brief's
“no COPR found” premise did not survive re-verification. The COPR search API returned multiple
projects, and guest-fetched primary metadata for
[`nett00n/hyprland`](https://copr.fedorainfracloud.org/coprs/nett00n/hyprland/) contains
`eww-0.6.0-16.fc44.x86_64` in its
[Fedora 44 repository](https://download.copr.fedorainfracloud.org/results/nett00n/hyprland/fedora-44-x86_64/).
That is metadata evidence only: this COPR was **not enabled**, and its dependency closure,
trust/suitability and runtime behavior are **UNVERIFIED**. Other search hits were not assessed.

Block 6 must choose whether to investigate a third-party package, use the
[upstream source build](https://github.com/elkowar/eww/blob/master/docs/src/eww.md),
or replace Eww (for example, evaluate the available Waybar package against the desired widgets).
B0 makes no Eww installation or replacement decision. A source build or replacement remains
necessary if Block 6 rejects the unverified third-party candidates.

## Block 2 / Block 7 findings

- Correct names matter: `black`, `python3-neovim`, `fd-find`, `prename`, `awscli2`,
  `kde-partitionmanager`, `pdftk-java`, `libpq`, `vips`, and versioned Node packages.
- Fedora Neovim 0.12.5 and tree-sitter-cli 0.26.11 meet the documented version floors.
  Parser compilation and the full plugin installation remain Block 3 work.
- Fedora's `jsonlint` provider is Python demjson; matching a command name does not establish
  compatibility with the configured npm tool. Ruby/npm tool provisioning still needs decisions.
- ShellCheck is available but was intentionally not installed. B0 guest lint reported a skip.
- None of the surveyed desktop applications, optional tools or runtimes should be added to
  the installer solely because they appear in this inventory.
