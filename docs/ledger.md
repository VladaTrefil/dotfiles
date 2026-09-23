# Legacy path ledger

This ledger accounts for every path in the legacy repository's Git index at
`1d979ad37b451b81ad864ed2a410899c58365214`. The inventory was generated from
the read-only checkout, not from earlier findings. Gitlinks count as one path,
matching Git's index. Ignored local tool state and the policy-forbidden personal
environment file are not repository content and were not inspected.

The rows below are disjoint. A `/**` row covers every indexed path below that
prefix; brace rows enumerate only the named paths; “remaining” means the prefix
after the preceding exceptions. Counts total **388 of 388 tracked paths**, with
**0 unaccounted paths**.

| Legacy path or complete set | Count | Destination | Status | One-line reason |
|---|---:|---|---|---|
| `.agents` | 1 | none | **dropped** | Host-specific worker instruction is not machine configuration. |
| `.ascii` | 1 | none | **dropped** | Unreferenced novelty art duplicated the separate ASCII asset. |
| `.gitignore` | 1 | `.gitignore` | **rewritten** | Target-only state, bytecode, and private-shell exclusions replace the legacy ignore policy. |
| `.gitmodules` | 1 | `.gitmodules` | **rewritten** | Only current Dotbot, Neovim, Oh My Zsh, and shell plugin Gitlinks remain, all with portable remotes. |
| `.prettierignore` | 1 | none | **dropped** | There is no repository-wide Prettier scope in the Fedora target. |
| `.prettierrc` | 1 | `modules/nvim/.prettierrc` | **migrated** | Neovim-owned formatter policy moved byte-for-byte into the extracted Neovim repository. |
| `.ruby-version` | 1 | `config/asdf/tool-versions` | **rewritten** | Runtime selection is centralized in the reviewed asdf version manifest. |
| `HANDOFF.md` | 1 | transition reports and current docs | **dropped** | Historical handoff state is superseded by the audited block reports and current documentation. |
| `README.md` | 1 | `README.md` | **rewritten** | Fedora install, test, submodule, and manual workflows replace the Arch instructions. |
| `install` | 1 | `install` | **rewritten** | The Fedora entrypoint separates package, link, tool, and system phases with dry-run safeguards. |
| `install-base.sh` | 1 | none | **dropped** | Unsafe mixed bootstrap and credential handling were replaced by explicit manifests and phases. |
| `{neovim.yml,selene.toml}` | 2 | `modules/nvim/{neovim.yml,selene.toml}` | **migrated** | Both Neovim lint policies moved byte-for-byte into the extracted repository. |
| `assets/ascii-art.txt` | 1 | none | **dropped** | No surviving shell, desktop, or installer path consumes the decorative file. |
| `background/**` | 4 | private `dotfiles-assets` wallpapers | **moved-to-assets** | Curated wallpapers are optional personal assets fetched outside the public configuration repo. |
| `build/dotbot` | 1 | `modules/dotbot` | **migrated** | Dotbot remains a pinned Gitlink at the supported v1.24.0 revision. |
| `build/{dotbot-asdf,dotbot-yay}` | 2 | none | **dropped** | Fedora package manifests and `bin/install-runtimes` replace the Arch-specific Dotbot plugins. |
| `build/install.conf.yaml` | 1 | `install.conf.yaml`, `packages/**`, `provision/**` | **rewritten** | Links, packages, and pinned upstream releases are now explicit and independently testable. |
| `build/pip-requirements.txt` | 1 | `packages/editor-tools.txt`, `provision/releases.json` | **rewritten** | Fedora providers and reviewed pinned artifacts replace ambient pip installation. |
| `build/{install-zsh.sh,post-install.sh,setup-env.sh,standalone/_git.sh}` | 4 | `install`, `bin/system-setup`, shell config | **rewritten** | Idempotent Fedora phases replace Arch bootstrap scripts and ad-hoc Git setup. |
| `config/asdf/**` | 4 | `config/asdf/**` | **rewritten** | asdf settings remain while runtime pins and default packages were audited for Fedora. |
| `config/bat/**` | 8 | `config/bat/**` | **migrated** | Config, two syntaxes, and five themes are byte-for-byte sources for the managed Bat cache. |
| `config/codespell/**` | 3 | `config/codespell/**` | **rewritten** | Word lists remain and the rc is generated with portable repository-relative paths. |
| `config/dunst/dunstrc` | 1 | `config/dunst/dunstrc` | **rewritten** | Notification styling and commands were ported to the standalone Wayland session. |
| `config/eww/assets/langs/**` | 3 | none | **dropped** | The obsolete language picker and its flag images are not part of the selected bar. |
| `config/eww/bar/scripts/{langs,mediaplayer}` | 2 | none | **dropped** | The unused language and media watchers were deliberately removed with their widgets. |
| `config/eww/bar/widgets/{lang.yuck,langs.json,mediaplayer.yuck}` | 3 | none | **dropped** | These widgets had no selected Fedora-session role. |
| remaining `config/eww/**` paths | 25 | `config/eww/**` | **rewritten** | Eww styling/assets were retained while Sway IPC, PipeWire, network, Bluetooth, tray, and monitor behavior were repaired and tested. |
| `config/git/**` | 2 | `config/git/**` | **rewritten** | PATH-based Neovim, valid log formats, main defaults, safer credential policy, and Neovim HTTPS-clone/SSH-push behavior replace legacy assumptions. |
| `config/hosts` | 1 | none | **dropped** | Host-file changes remain a manual machine-owner decision and are never linked by dotfiles. |
| `config/i3/auto_scratchpad.py` | 1 | none | **dropped** | The i3-specific IPC helper has no role in SwayFX. |
| `config/i3/{config,on-startup.sh}` | 2 | `config/sway/**`, `bin/system-setup` | **rewritten** | Sway bindings/session policy and explicit service setup replace i3 startup behavior. |
| `config/i3/picom.conf` | 1 | `config/sway/conf.d/10-appearance.conf` | **rewritten** | SwayFX compositor effects replace X11 picom. |
| `config/konsole/konsolerc` | 1 | `config/kitty/**` | **rewritten** | Kitty is the selected terminal, so Konsole-specific state is not carried. |
| `config/lazygit/config.yml` | 1 | `config/lazygit/config.yml` | **migrated** | The portable LazyGit configuration is retained byte-for-byte. |
| `config/npm/npmrc` | 1 | `config/npm/npmrc` | **rewritten** | The selected npm policy remains without legacy machine assumptions. |
| `config/nvim/**` | 141 | `modules/nvim/**` | **migrated** | The full indexed Neovim tree and its history were extracted, then portability and provider paths were repaired in the dedicated repository. |
| `config/pry/pryrc` | 1 | `config/pry/pryrc` | **migrated** | The Pry configuration is retained byte-for-byte. |
| `config/pulse/daemon.conf` | 1 | none | **dropped** | The PulseAudio idle tweak is obsolete under Fedora PipeWire. |
| `config/qt5ct/colors/Catppuccin-Mocha.conf` | 1 | `config/qt-palette/Catppuccin-Mocha.conf` | **migrated** | The identical Qt5/Qt6 palette is deduplicated to one linked source. |
| `config/qt5ct/qt5ct.conf` | 1 | none | **dropped** | No selected application requires a Qt5 platform-theme configuration. |
| `config/qt6ct/colors/Catppuccin-Mocha.conf` | 1 | `config/qt-palette/Catppuccin-Mocha.conf` | **migrated** | The byte-identical palette is shared with both Qt native color paths. |
| `config/qt6ct/qt6ct.conf` | 1 | `config/qt6ct/qt6ct.conf` | **rewritten** | Qt6 Fusion and the selected shared palette remain in a portable config. |
| `config/ranger/**` | 5 | none | **dropped** | The pinned `lf` workflow replaces Ranger and its devicons Gitlink. |
| `config/rofi/**` | 5 | `config/rofi/**` | **rewritten** | Launcher and power-menu scripts/styles were ported to the Wayland session. |
| `config/rubocop/rubocop.yml` | 1 | `config/rubocop/config.yml` | **rewritten** | The policy was normalized and linked under the path expected by current tooling. |
| `config/shell/**` | 3 | `config/shell/**` | **rewritten** | Profile, aliases, and input settings were audited for XDG paths, Fedora tools, and removed scripts. |
| `config/solargraph/config.yml` | 1 | `config/solargraph/config.yml` | **migrated** | The portable Solargraph configuration is retained byte-for-byte. |
| `config/stylelint/stylelintrc.json` | 1 | `config/stylelint/stylelintrc.json` | **rewritten** | Current formatter/linter integration replaces stale legacy plugin assumptions. |
| `config/stylua/stylua.toml` | 1 | `config/stylua/stylua.toml`, `modules/nvim/stylua.toml` | **migrated** | The byte-identical Lua formatting policy is available to dotfiles and Neovim tests. |
| `config/wgetrc` | 1 | `config/wgetrc` | **rewritten** | Cache and certificate behavior now uses portable user paths. |
| `config/x11/**` | 4 | `config/sway/**`, `config/environment.d/50-desktop.conf` | **rewritten** | Standalone SwayFX and environment.d replace Plasma/i3 session, Xresources, xprofile, and xsession files. |
| `config/zed/{keymap.json,settings.json,tasks.json}` | 3 | same paths | **rewritten** | Zed settings were retained with PATH-based Zsh, normalized task labels, and the tutorial task removed. |
| `config/zed/keymap_backup.json` | 1 | none | **dropped** | The stale backup used older action names and was not live configuration. |
| `config/zsh/**` | 6 | `config/zsh/**` | **rewritten** | Startup files were ported and the three shell dependencies remain explicit pinned Gitlinks; `p10k.zsh` stays byte-for-byte. |
| `local/applications/lf.desktop` | 1 | `local/applications/lf.desktop` | **rewritten** | The desktop entry now launches PATH-resolved `lf` in Kitty instead of a dead Go/asdf path. |
| `local/bin/{clear-git-branches.sh,kill-rails-server.sh}` | 2 | none | **dropped** | One cannot parse and performs remote deletion; the other can target the wrong process with SIGKILL. |
| `local/bin/{folio-test-account.rb,generate-rails-sitemaps.sh,init-sinfin-project.sh}` | 3 | intended private `dotfiles-work` repo | **dropped** | Employer-specific or credential-bearing workflows are excluded from the public target; private review/migration remains open. |
| `local/bin/ydl-clip.sh` | 1 | `local/bin/ydl-clip.sh` | **rewritten** | The workflow now uses Wayland clipboard input, validated arguments, quoted paths, and yt-dlp archive semantics. |
| `local/fonts/FontAwesome-*.ttf` | 3 | private `dotfiles-assets` fonts | **moved-to-assets** | Paid Font Awesome Pro binaries are optional private assets, never public-repo content. |
| `local/fonts/JoyPixels.ttf` | 1 | `google-noto-color-emoji-fonts` package | **dropped** | Fedora's maintained Noto Color Emoji replaces the bundled third-party emoji font. |
| `local/fonts/MesloNerd-regular.ttf` | 1 | pinned MesloLGS Nerd Font release | **rewritten** | A verified upstream archive supplies the selected Regular, Bold, and Italic faces. |
| `local/fonts/iosevka-mono/**` | 42 | none | **dropped** | No audited configuration selects Mono/Term or the many legacy weight/oblique variants. |
| `local/fonts/iosevka/**` | 42 | pinned Iosevka Nerd Font release | **rewritten** | A verified upstream archive replaces bundled binaries with the three actually selected faces. |
| `local/fonts/monolisa/**` | 14 | private `dotfiles-assets` fonts | **moved-to-assets** | Licensed MonoLisa faces remain optional private assets outside the public repo. |
| `local/fonts/noto-sans-jp/**` | 9 | `google-noto-sans-jp-fonts` package | **rewritten** | Fedora's maintained exact family replaces all bundled Noto Sans JP weights. |
| `local/konsole/**` | 4 | `config/kitty/**` | **dropped** | Konsole profiles/color schemes are obsolete after choosing Kitty. |

## Accounted external state

The legacy package block inside `build/install.conf.yaml` is part of that one
indexed path and is covered above. Its 109 source rows were separately audited
in Block 7: selected software maps to Fedora/RPM Fusion/Flatpak manifests or
checksum-pinned releases, while 21 obsolete rows were explicitly dropped.

The former host Proton Mail Bridge autostart entry was not a legacy repository
path, so it is outside the 388-path denominator; its behavior was rewritten as
`local/autostart/protonmail-bridge.desktop`. The unpublished Neovim PCManFM-Qt
mapping follow-up likewise belongs to the separate Neovim repository and does
not change this path count.
