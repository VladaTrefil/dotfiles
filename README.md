# dotfiles-next

An incremental replacement for the legacy dotfiles, intended for Fedora VM
testing. This is the orchestration scaffold. The only application files are
`config/git/config` and `config/git/ignore`, copied verbatim as a link fixture;
their existing settings have not been audited or corrected.

Dotbot is pinned as a submodule to v1.24.0,
`08ba8ac31b931a098c6ca8608dd452927d77f945`. It requires Python 3.7 or newer.
The entrypoint requires Bash 4+ and Git. Initial submodule setup needs network
access; subsequent runs use the recorded commits.

```sh
./install                         # default: link
./install link                    # create directories and the Git config link
./install packages --dry-run      # print the exact dnf command; install nothing
./install packages --group base,dev --dry-run
./install system                  # descriptive stub; no system changes
./install all                     # packages, link, system, then manual steps
./install all --dry-run           # preview; no packages or links are changed
./install --help                  # also supported on every subcommand
```

Package groups are `packages/<group>.txt`: one package name per line, with blank
lines and `#` comments ignored. Duplicate packages are removed in input order.
Only Git and Python are listed for now. `dev` is an empty placeholder. Actual
installation requires root and typing `yes`; when run as a normal user, the
entrypoint prints the command to run as root and exits without installing.
No command calls sudo.

Linking creates `~/.config`, `~/.local/state`, and `~/.config/git`. It preserves
existing unmanaged targets, reports conflicts, and exits nonzero on a conflict.
It never cleans directories or replaces an existing link. Python bytecode is
disabled during linking, so it leaves no interpreter cache in the repository.
Git may update its own submodule metadata during initialization.

Run the checks from the repository:

```sh
tests/link-test.sh
tests/lint.sh
```

The link test needs Linux, Bubblewrap (`bwrap`), Git, Python 3, and GNU tar. It
copies the scaffold into a temporary HOME, disables network access, exposes only
runtime system directories read-only, and makes that HOME the only writable
filesystem tree. It checks clean linking, idempotence, conflict bytes, and the
write boundary, then removes the fixture with a trap. Initialize the pinned
submodules first with `git submodule update --init --recursive` if necessary.

Lint finds ShellCheck on PATH and clearly skips if unavailable. It checks all
repository-owned shell scripts, including extensionless shell entrypoints;
the pinned third-party submodule is outside this repository's lint scope.
Future syntax checks can be added alongside the shell check in `tests/lint.sh`.
See [manual steps](docs/manual-steps.md) and the [path ledger](docs/ledger.md).
