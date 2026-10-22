# Codex MCP secrets implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task by task.

**Goal:** A normal `codex` launch retrieves required MCP credentials from 1Password without exporting resolved keys into the terminal environment.

**Architecture:** Configure Codex's native HTTP header helper to run `bin/codex-mcp-headers`. The helper reads literal variable-to-reference mappings from a machine-local file, retrieves only the requested fields with `op read`, and emits a JSON header object directly to Codex. Preserve the vendor executable, shared daemon, and Eww integration.

**Tech stack:** Python 3.9+ standard library, official Linux 1Password CLI 2.41.1 and Codex CLI 0.163.0, repository checks.

**Spec:** The design brief below records the requested behavior and the daemon compatibility finding.

## Design brief

Typing `codex` should automatically authenticate configured MCP connections. The current API-key requirement is `STITCH_API_KEY` for Stitch's `X-Goog-Api-Key` header. The `node_repl` environment contains runtime settings rather than API-key requirements.

Keep literal `NAME=op://...` references at `${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/codex-mcp.env`, with directory mode `0700` and file mode `0600`. Single- or double-quoted values, blank lines, and full-line comments are supported; expansion, multiline values, duplicate names, and plaintext keys are rejected. The actual Stitch reference must be supplied by the user using Copy Secret Reference. Never invent it.

The original shell-function proposal used `op run -- codex`. An isolated real-CLI probe showed that a fresh daemon received the current client key, while a later client with a changed key still used the daemon's original environment. The original plan explicitly required falling back to a native header helper if that check failed. That fallback is now the implementation: no shell function or binary replacement is needed.

Each HTTP MCP config names the helper using an absolute path and passes `HEADER=ENV_NAME` arguments or `--bearer ENV_NAME`. On Linux, pass `--op /usr/bin/op` to select the desktop-integrated package binary rather than a shadowing user-local executable. Only variables requested by that server are resolved. Every requested header is validated and resolved before any JSON is emitted. Failed retrieval produces a nonzero status and generic diagnostics; 1Password's stdout and stderr never become failure output.

## Global constraints

- Implementation is authorized; preserve unrelated working-tree changes and do not commit unless requested.
- Keep the vendor executable, shared daemon, Eww integration, and shell startup unchanged.
- Keep only secret references in the local configuration file; never evaluate its contents as shell code or cache resolved keys.
- Keep API values out of tracked files, command arguments, diagnostics, and exported environments. The helper's protocol stdout necessarily contains the requested header values and must be consumed only by Codex.
- Preserve repository installer, link-conflict, privilege, and confirmation boundaries. Install the official Linux CLI only through the focused `onepassword` package group, preserving root and exact-`yes` confirmation. No managed-link change is required.
- Global agent instructions require registering every new required MCP key in the reference file and configuring the matching server retrieval in the same task. Stdio servers need retrieval in their launcher rather than the HTTP helper.
- A daemon's cached connection can outlive the terminal and 1Password authorization. Do not promise that locking 1Password clears an already-retrieved key.

## Review focus

- Fresh, existing, and resumed daemon sessions must receive the current key without restarting the user's daemon.
- Missing references, canceled authorization, or unavailable `op` must produce no partial JSON headers.
- Plaintext values, shell expressions, duplicate names, duplicate headers, and HTTP control characters must fail safely.
- Resolve only requested references, ignore stale inherited key values, and suppress dependency failure output.
- Normal shell startup and CLI help/version must not retrieve keys; no shell wrapper is installed.

## Files

- Create `bin/codex-mcp-headers`: validated reference reader and JSON header protocol.
- Create `config/codex-mcp.env.example`: synthetic reference template and supported syntax.
- Create `tests/codex_mcp_headers_test.py`: isolated behavior tests with a synthetic 1Password executable.
- Modify `tests/lint.sh`: run the helper behavior and focused package checks.
- Modify `install` and `packages/apps.txt`; add `packages/onepassword.txt` and `tests/onepassword-packages-test.sh`: provision only the official desktop and CLI packages when the focused group is selected.
- Modify `docs/manual-steps.md`: local setup, authentication, configuration, daemon behavior, and future MCP additions.
- Modify `config/assistants/instructions.md`: enforce credential registration globally in Codex and Claude.
- Machine-local activation: create the private reference file and replace Stitch's `env_http_headers` entry with `http_headers_helper` after the real reference is supplied.

## Task 1: Verify daemon compatibility

- [x] Probe a temporary Codex home using a localhost MCP endpoint and dummy credentials, without touching live keys or the user's daemon.
- [x] Establish the shell-wrapper failure: a fresh daemon used the current header; an existing daemon used the stale header after a later client supplied a changed variable.
- [x] Verify the native helper fallback: fresh, existing, and resumed sessions all used the current dummy credential.
- [x] Scan the probe's Codex state for dummy values; none were found. Evidence resides in the task ledger and temporary probe artifacts.

## Task 2: Implement the header helper

- [x] Write behavior tests first and observe failure with the helper absent.
- [x] Implement requested-header selection, shared-variable retrieval, bearer headers, XDG/home/file selection, and failure handling.
- [x] Verify invalid input cannot execute shell code, trigger unrelated retrieval, or emit partial headers. Verify dependency failure streams are suppressed and help needs no authentication.
- [x] Run the behavior tests successfully and register them with the repository checks; the suite now has eleven cases including explicit and relative CLI selection.

## Task 3: Document and activate

- [x] Add the shared global MCP credential rule and update it to use the daemon-compatible helper.
- [x] Add the synthetic reference template and document file permissions, server configuration, authentication, key lifetimes, and adding future MCPs.
- [x] Format and lint changed code and documentation using project configuration or the current Neovim fallback. Preserve unrelated formatting.
- [x] Run helper tests, existing secret checks, shell startup checks, repository lint, and whitespace checks. The pre-existing codespell warning for `initialises` at `tests/lint.sh:59` is outside the changed statement and remains untouched.
- [x] Obtain an independent code review. Reject repeated bearer arguments before retrieval, and cover dependency failure after a successful first retrieval.
- [x] Obtain the user's Stitch secret reference and register it in the machine-local file with directory mode `0700` and file mode `0600`.
- [x] Diagnose Linux desktop rejection of the user-local CLI, add the official package and a focused installer group, verify its dry-run plan, and have the user complete the root/confirmation step. `/usr/bin/op` 2.41.1 is installed with setgid permissions.
- [x] Complete desktop authorization and register the verified vault/item IDs after the supplied reference named the wrong vault. Configure Stitch's helper with `/usr/bin/op` and a 120-second startup window while preserving unrelated settings and the existing config mode.
- [x] Verify live authentication without displaying credentials: a new ephemeral session on the existing daemon discovered 16 Stitch tools. Unsubscribe the verification session without running a model turn or restarting the daemon.

## Sources

- [1Password secret references](https://www.1password.dev/cli/secret-reference-syntax): references identify fields for `op read`.
- [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli): native header-helper protocol and connection caching.
- [Codex CLI reference](https://learn.chatgpt.com/docs/cli/reference): shared daemon behavior and `--no-daemon`.
