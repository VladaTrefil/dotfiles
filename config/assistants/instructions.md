# Host program installations

- When completing a task requires a new host-level program or system package, first add it to the appropriate manifest or provisioning path in `~/Development/dotfiles`.
- Install it only through that repository's documented installer or provisioning tool. Do not perform an ad hoc installation with `dnf`, `rpm`, `flatpak`, `curl`, or a language-level global installer.
- Preserve the repository's review, dry-run, privilege, and confirmation boundaries; run the relevant repository tests and verify the installed behavior afterward.
- Project-local dependencies managed by a project's own manifest and lockfile are outside this rule unless the user asks to provision them globally.

# Code linting and formatting

- Always format and lint code you create or change before completing a task. Prefer the project's commands and dependencies.
- Determine linting and formatting independently for each language/file. Use applicable project-local tools and configuration when present, including configuration in ancestor directories, manifests, and `.editorconfig`. Use the Neovim fallback only for an operation without a project-local setup; a local formatter configuration does not disable fallback linting, or vice versa.
- For fallback tools and rules, use the current Neovim configuration under `${XDG_CONFIG_HOME:-$HOME/.config}/nvim/lua/plugins/config/` as the source of truth:
  - `_lint/init.lua`: `linters_by_ft`, including the shared `codespell` check.
  - `_conform/init.lua`: `formatters_by_ft`, formatter order, arguments, and whitespace handling.
  - Read the associated overrides in `_lint/`, `_conform/`, and `stylelint.lua` for the selected tools. Match their global config files, arguments, and exclusions when invoking tools from the command line. Resolve global config paths through `${XDG_CONFIG_HOME:-$HOME/.config}`.
- Respect project ignore rules and keep linting and formatting scoped to task files. If a required tool cannot run, report the blocker instead of silently skipping the check; provision missing host tools through the dotfiles workflow above.
- If linting or formatting code unrelated to the current task is desirable, always commit that cleanup separately from task changes, even when both affect the same file. Never mix unrelated cleanup into a task commit or include pre-existing user changes in a cleanup commit.
