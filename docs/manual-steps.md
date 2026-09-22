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

Private fonts and wallpapers are also a separate, optional step:

```sh
bin/fetch-assets
```

This requires a GitHub SSH key with access to the private
`VladaTrefil/dotfiles-assets` repository. A machine without that access should
skip the command; the rest of the install remains usable without MonoLisa, Font
Awesome Pro, and the curated wallpapers. The command installs no system files:
it clones to `~/.local/share/dotfiles-assets`, links the fonts below
`~/.local/share/fonts`, links the wallpapers at `~/.background`, and refreshes
the user font cache. `bin/fetch-assets --offline` performs only validation,
linking, and cache refresh for a checkout already copied to that location; it
does not turn missing credentials into a silent success.

Fedora 44 packages `google-noto-sans-jp-fonts` and
`google-noto-color-emoji-fonts` provide the exact `Noto Sans JP` and
`Noto Color Emoji` families and are listed in `packages/fonts.txt`. Fedora 44
does not package the required `Iosevka Nerd Font` or `MesloLGS NF` families.
Leave those unavailable for now, choose a packaged terminal font, or add a
separately reviewed and checksum-pinned upstream Nerd Fonts installation in a
future change. Powerlevel10k also documents its own MesloLGS NF installer; this
repository does not invoke it or improvise an unverified download.
