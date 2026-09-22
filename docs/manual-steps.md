# Manual steps

This stub will grow as migration blocks land. The installer deliberately never
performs these actions automatically:

- Edit system configuration, sudoers, IPv6 settings, or `/etc/hosts`.
- Change the login shell or enable/start services. `system` is currently a stub;
  any later privileged workflow must be explicit and reviewed.
- Fetch, read, generate, or link secrets; handle GitHub tokens or credentials.
- Create a GitHub repository, configure its remote, or push it.

Package installation is separate: inspect `./install packages --dry-run` and run
the printed command as root, or explicitly confirm `packages` in a root session.
This repository does not invoke sudo, run downloaded installers, or remove
unmanaged files. Existing link conflicts require a manual decision.

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
