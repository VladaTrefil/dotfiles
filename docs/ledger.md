# Legacy path ledger

Track each legacy path here as its migration block is completed. This is a stub,
not a completed inventory. Use **migrated**, **rewritten**, or **dropped**, with a
reason and verification evidence.

| Legacy path | Destination | Status | Reason / verification |
|---|---|---|---|
| `config/git/config` | `config/git/config` | **migrated (verbatim + 1 documented addition)** | Copied byte-for-byte in A4 as the link-mechanism fixture; still awaits its Block 1 audit. **A6b appended one 3-line block** (`[url "git@github.com:VladaTrefil/nvim.git"] pushInsteadOf = https://github.com/VladaTrefil/nvim.git`) so the Neovim submodule clones over HTTPS without credentials while pushes still use the SSH key. Everything above that block is untouched legacy content. `diff` against the legacy file shows exactly this addition and nothing else. |
| `config/git/ignore` | `config/git/ignore` | **migrated (verbatim)** | Byte-for-byte; awaits Block 1 audit. |
