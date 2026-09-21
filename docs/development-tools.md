# Development tooling (Block 2)

Install Fedora prerequisites with `./install packages --group dev,editor-tools` (the
command prints the exact DNF transaction; run it as root). Then run, as the user:

```sh
./install link
./install tools
./install runtimes
```

`./install all` includes these steps. Shell integration remains Block 1's Go-asdf
PATH and environment: no `asdf.sh`, `ASDF_DIR`, legacy `global`, or extra runtime
selection. `~/.tool-versions` links to `config/asdf/tool-versions`, the sole runtime
inventory: Node 24.21.0 and Ruby 3.4.10. Existing unrelated runtime installations
are never removed. A fresh HOME provisions only these two. Runtime provisioning
uses explicit `asdf plugin add`, `plugin update REF`, `install NAME VERSION` and
`reshim NAME VERSION`; it never writes a second version declaration.

## Ownership and verified releases

`packages/editor-tools.txt` contains active editor dependencies and parser/test
prerequisites, separately from `dev.txt` (Ruby build dependencies and Bat).
`tests/providers.json` describes the intended executable and upstream for each
of the 22 RPMs. `tests/providers.py` runs its CLI, checks RPM file ownership and
package upstream metadata on Fedora, and records Arch ownership on the host.
Fedora git-core owns `git`; the higher-level git RPM is a metapackage. Fedora
ships Pylint as `pylint-3`; `install link` creates `~/.local/bin/pylint` only after
verifying the target is owned by python3-pylint, and only if no pylint command
already resolves. The Python provider is verified by importing **pynvim**, not by matching an RPM
name. `clang-tools-extra` must provide LLVM clang-format; `fd-find` must provide
sharkdp/fd. JSON linting is deliberately **npm jsonlint**, never Fedora demjson;
the integration test checks `--compact` and the actual line/column diagnostics.

One mechanism installs **StyLua 2.5.2, Selene 0.31.0 and lf r42**: upstream release
binaries, downloaded over HTTPS, verified against the fixed SHA-256 hashes in
`provision/releases.json`, then installed to `~/.local/bin`. Go-asdf 0.20.0 uses
the same mechanism. The digests were obtained from the upstream GitHub release
asset metadata on 2026-09-22 and independently compared with downloaded bytes.
The lock contains exact source URLs. Cached archives are reverified on every run;
only the named executable member is extracted, never archive paths. Unmanaged
binaries and symlinks are refused. Managed binaries are replaced only if their
previous installed checksum still matches. `tests/release-test.py` tests a corrupt
cache and requires failure before any executable is installed.

Trade-off: this avoids Cargo/Go build time and system toolchain dependencies for
these three utilities, at the cost of trusting upstream release builds and
maintaining download hashes. The pinned set is Linux **x86_64 only**, covering
both machines in this migration; other architectures fail explicitly. Ruby still
builds from source using system C tooling. The asdf plugin Git revisions are pinned
in `provision/plugins.json`; their builders verify the runtime archives against
upstream checksums. Runtime-package lists intentionally track available compatible
packages rather than forming a transitive package lock.

Upstream sources: [asdf](https://github.com/asdf-vm/asdf/releases/tag/v0.20.0),
[StyLua](https://github.com/JohnnyMorganz/StyLua/releases/tag/v2.5.2),
[Selene](https://github.com/Kampfkarren/selene/releases/tag/0.31.0),
[lf](https://github.com/gokcehan/lf/releases/tag/r42).

## Runtime-scoped packages

Both default-package hooks remain deliberate. The installer also reconciles them
when the runtime is already installed, then refreshes shims. This means rerunning
`install runtimes` may update the unpinned ecosystem tools.

| Entry | Retained purpose |
|---|---|
| gem `bundler` | Project bundles and the editor's bundle-exec adapters |
| gem `spring` | Existing Rails project preloader convenience |
| gem `solargraph` | Existing optional Ruby analysis workflow; global config retained |
| gem `rubocop` | Ruby LSP and global CLI; projects supply their own bundle |
| gem `neovim` | Existing optional Ruby provider |
| gem `slim_lint` | Active Slim lint adapter |
| npm `yarn` | Existing project package-manager convenience |
| npm `neovim` | Existing optional Node provider |
| npm `prettier` | Active SCSS/JSON/YAML formatting |
| npm `postcss`, `postcss-scss`, `postcss-sass` | Stylelint's syntax dependencies |
| npm `stylelint`, `stylelint-config-standard`, `stylelint-scss` | SCSS/Sass lint rules |
| npm `jsonlint` | Adapter-compatible JSON lint implementation |
| npm `standard` | Active JavaScript lint/format adapter |
| npm `vscode-langservers-extracted` | Active ESLint language server (project ESLint still required) |

Rails is no longer globally installed: projects supply it. Dormant LuaLS, pylsp,
TypeScript/Vim/YAML servers and unused rustfmt are not promoted to mandatory
requirements. Beautysh remains an identified source gap: no verified Fedora RPM,
and no Python-environment provisioning has been authorized for this block.
LazyGit's clean config is retained; enabling a COPR is not part of this change.
Desktop tools remain in their later blocks.

## Shared configuration

Stylelint uses bare module names. Both Neovim lint and Conform call a shared
resolver which runs `npm root -g` for each global-fallback invocation and passes
`--config-basedir`. A project Stylelint file or package.json `stylelint` entry
keeps Stylelint's normal project discovery and local dependency resolution.
There is no Node-version path or installer-maintained node_modules symlink.
The Sass allowance is `trough`, matching SCSS and GTK selector intent.

RuboCop's XDG filename is `rubocop/config.yml`. Folio inheritance and its four
extension requires are removed. **Unresolved decision conflict:** preserving
extension-specific cop selections makes RuboCop reject this config without those
extensions. The integration test intentionally fails until the user selects
removing those sections or restoring explicitly provisioned extensions.

Codespell's checked-in `codespellrc` is a template containing its own ignore and
exclude inputs. `install link` renders `@CONFIG_HOME@` into absolute paths in the
installed rc (including custom XDG homes and spaces). Codespell does not expand
shell variables or resolve these paths relative to its rc. The six-word ignore
list and empty exclusion file are linked verbatim. Both shell and Neovim now
supply only `--config` for this policy. A checksum prevents overwriting an edited
or unmanaged generated rc.

Bat's source assets are copied verbatim; `install link` builds its cache only when
the source/installed Bat version changes or either binary cache is absent. The
existing host cache is never copied. Pylint uses bounded directory-component
regexes, with `[.]` to avoid Pylint's Windows-path conversion rewriting regex
backslashes. npmrc retains only the supported XDG cache setting. Clean StyLua,
Solargraph, Pry and LazyGit files are copied verbatim.

## Checks

Run tests with a temporary HOME and TMPDIR. The host needs ShellCheck and codespell
in a temporary test venv if absent; this is test infrastructure, not the Fedora
installation mechanism. Do not use legacy Mason paths.

```sh
tests/lint.sh
tests/link-test.sh
tests/shell-test.sh
tests/sync-nvim-test.sh
python3 tests/release-test.py
tests/dev-test.sh /path/to/provisioned/test-home
# In the separately changed nvim-next repo:
PATH=/path/to/provisioned/test-home/.local/bin:/usr/bin:/bin tests/run.sh
```

The development suite creates another temporary HOME/config/scratch directory,
reuses only the supplied runtime data and executables, and verifies runtime
selection, every default package, Sass/SCSS resolution, npm jsonlint behavior,
RuboCop's own XDG discovery outside a project, shared codespell inputs, Pylint
exclusions, Bat assets and all RPM providers. Selene's existing advisory lint
debt is distinct from the Neovim parser/test exit status.
