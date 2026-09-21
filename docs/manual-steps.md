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
