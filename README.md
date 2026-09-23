# dotfiles-next

An incremental replacement for the legacy dotfiles, intended for Fedora VM
testing. This is the orchestration scaffold. `config/git/config` and
`config/git/ignore` began as a link fixture; their legacy settings have not been
audited or corrected. Git adds an SSH push rule for Neovim. Neovim is a standalone
repository linked directly from the `modules/nvim` submodule's working copy.

Dotbot is pinned as a submodule to v1.24.0,
`08ba8ac31b931a098c6ca8608dd452927d77f945`. It requires Python 3.7 or newer.
The entrypoint requires Bash 4+ and Git. Initial submodule setup needs network
access; subsequent runs use the recorded commits.

```sh
./install                         # default: link
./install link                    # create directories and the Git/Neovim links
./install packages --dry-run      # print the exact dnf command; install nothing
./install packages --group base,dev --dry-run
./install system                  # descriptive stub; no system changes
./install all                     # packages, link, system, then manual steps
./install all --dry-run           # preview; no packages or links are changed
./install --help                  # also supported on every subcommand
bin/fetch-assets                  # optional private fonts and wallpapers
bin/check-secrets                 # validate 1Password refs without printing values
```

Package groups are `packages/<group>.txt`: one package name per line, with blank
lines and `#` comments ignored. Duplicate packages are removed in input order.
Only Git and Python are listed for now. `dev` is an empty placeholder. Actual
installation requires root and typing `yes`; when run as a normal user, the
entrypoint prints the command to run as root and exits without installing.
No command calls sudo.

Linking creates `~/.config`, `~/.local/state`, `~/.config/git`, and
`~/.config/nvim`. Neovim creates its own undo and swap directories at runtime.
Linking preserves existing unmanaged targets, reports conflicts, and exits
nonzero on a conflict.
It never cleans directories or replaces an existing link. Python bytecode is
disabled during linking, so it leaves no interpreter cache in the repository.
Git may update its own submodule metadata during initialization.

The Neovim submodule tracks `main` at `https://github.com/VladaTrefil/nvim.git`.
Public submodules clone over HTTPS without credentials. The linked Git config
uses `pushInsteadOf` for this Neovim URL so pushes use
`git@github.com:VladaTrefil/nvim.git` and the SSH key set up during day-zero
bootstrap. The private `dotfiles-next` repository still needs SSH for its own
initial clone. Existing checkouts can adopt the HTTPS URL with
`git submodule sync -- modules/nvim`.
Edit it in place in `modules/nvim`, then commit and push from that directory;
the running Neovim sees those edits through `~/.config/nvim`. For upstream
updates, run `bin/sync-nvim`: it fetches and fast-forwards `main`, then commits
the changed pointer in this repository. It refuses dirty, detached, off-branch,
unpublished, or divergent local work, and refuses an already staged parent
index. An initialized submodule may be detached after cloning or checking out a
different parent commit; switch it to `main` deliberately before syncing.
`bin/sync-nvim --dry-run` previews the actions without fetching or writing.
Only `--push` pushes: Neovim first, then the current parent branch to `origin`.
Without it all changes remain local; an unchanged pointer needs no commit.

Run the checks from the repository:

```sh
tests/link-test.sh
tests/sync-nvim-test.sh
tests/fetch-assets-test.sh
tests/lint.sh
```

The link test needs Linux, Bubblewrap (`bwrap`), Git, Python 3, GNU tar and
`timeout`, CA certificates, and network access to GitHub. It copies the scaffold
into a temporary HOME without submodule files or Git objects. The real installer
clones the configured HTTPS remotes, including nested submodules, on every test
run; the test prints clone output and verifies the pinned commits. The source
checkout does not need initialized submodules. Runtime directories, DNS config,
and CA certificates are exposed read-only; the temporary HOME is the only
writable filesystem tree. No real HOME or SSH credentials are exposed.
It checks clean linking, idempotence, conflict bytes for both links, and the write
boundary, then removes the fixture with a trap. Network/remote failures and the
five-minute limit per installer run report `ERROR [NETWORK/REMOTE]` and exit 2;
assertion failures report `FAIL` and exit 1. Unreachable remotes never skip checks
or pass the test. These real downloads can make the test slower or fail during
a GitHub/network outage.
The sync test uses disposable local repositories, allows only Git's file
transport, and never pushes.

Lint finds ShellCheck on PATH and clearly skips if unavailable. It checks all
repository-owned shell scripts, including extensionless shell entrypoints;
the pinned submodules are outside this repository's lint scope.
Future syntax checks can be added alongside the shell check in `tests/lint.sh`.
See [manual steps](docs/manual-steps.md) and the [path ledger](docs/ledger.md).
