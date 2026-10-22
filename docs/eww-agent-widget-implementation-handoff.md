# Eww agent widget implementation handoff

Snapshot: 2026-10-22, `/home/vlada/Development/dotfiles`.

The next task is a floating Eww window launched by clicking the existing agent
counter in the top bar. It should list the current Codex and Claude agents,
show their names and running/waiting status, offer a button to focus the terminal
running each instance, and provide an expandable approval area with the prompt
details or command and **Yes / Always / No** actions.

The counter and terminal-liveness filtering already work. The floating list,
window targeting, and external approval handling are not implemented. Extend the
existing data collection so the counter and the list describe the same agents.

## Repository state to preserve

- Commit `934b39e` added the original counter, its dependency, and tests, including
  the user's styling changes.
- The subsequent fix for stale sessions after killing Kitty is included with
  this handoff in `config/eww/bar/scripts/agents` and
  `tests/eww_agents_checks.py`. Preserve it when extending either file.
- Commit `ea6e523` completed the separate X11 Eww build and static-text drag
  experiment. The executable is installed, and the user tested and accepted the
  corrected dragging behavior. Reuse this foundation for the floating agent
  window; the setup, launcher, and geometry caveat are documented below.
- Installed versions checked during this work: Codex CLI `0.163.0`, Claude Code
  `2.1.302`, and Python `websockets` `15.0.1`. The collector's WebSocket dependency
  is declared as `python3-websockets` in `packages/apps.txt`.

Recheck `git status` before working; this is an active shared checkout.

## Existing files and integration points

| File                                                  | Responsibility                                                           |
| ----------------------------------------------------- | ------------------------------------------------------------------------ |
| [Agent collector](../config/eww/bar/scripts/agents)   | Executable Python script; queries both providers and emits count JSON.   |
| [Agent widget](../config/eww/bar/widgets/agents.yuck) | Three-second polling variable and robot/count labels.                    |
| [Bar layout](../config/eww/bar/eww.yuck)              | Includes the widget and places `(agents)` immediately after `(network)`. |
| [Widget styles](../config/eww/bar/widgets.scss)       | `.agents` styles, including the user's revised appearance.               |
| [Palette](../config/eww/variables.scss)               | Existing shared colors, fonts, and spacing variables.                    |
| [Window styles](../config/eww/bar/windows.scss)       | Existing popup styling conventions.                                      |
| [Popup helper](../config/eww/bar/scripts/pop)         | Toggles calendar/system/Bluetooth windows and closes other popups.       |
| [Collector tests](../tests/eww_agents_checks.py)      | Nine tests, including real sockets and a force-killed client.            |
| [Eww configuration checks](../tests/eww-checks.py)    | Includes an exact inventory of main-config window names.                 |
| [Repository checks](../tests/lint.sh)                 | Runs the collector tests and the broader desktop/config checks.          |
| [X11 experiment notes](eww-x11.md)                    | Separate Eww build and draggable XWayland window experiment.             |
| [X11 provisioning command](../bin/install-eww-x11)    | Builds the verified source pin and installs `~/.local/bin/eww-x11`.       |
| [Drag-test configuration](../experiments/eww-drag/eww.yuck) | Minimal working floating window to extend or copy into a production config. |
| [Drag-test launcher](../experiments/eww-drag/run)      | Routes commands to the isolated X11 configuration and daemon.            |

The user changed the initial design after testing. The current bar shows a purple
robot, then joined **waiting first / running second** badges: red waiting and
purple running, bold 14px white text, and rounded outer corners. Preserve this
appearance; the earlier request for separate blue/green 10px badges is superseded.
The running label currently has the copied tooltip `Waiting agents`; correct that
small mismatch when wiring the click interaction.

The existing widget has no button/event handler, no `monitor` argument, and no
floating agent window. Wire its click action to the separate X11 window launcher
described below. The existing popup helper toggles the bar daemon's windows;
reusing it for the new popup requires explicit routing to the X11 binary and
configuration directory.

## Current count contract and filtering

Running the collector without arguments prints one JSON object, for example:

```json
{ "running": 2, "waiting": 1 }
```

Eww reads this through `defpoll agent_counts` with a `3s` interval. Keep this
contract compatible, or update the existing widget and its tests together.
Yuck JSON field access needs expressions such as `{agent_counts.running}`.

The count represents top-level sessions with a task, not all historical
conversations or internal subagents. **Waiting includes finished live sessions
ready for another prompt as well as sessions blocked on user input or approval.**
Therefore, a waiting row does not necessarily have a pending approval.

Provider failures are isolated: one unavailable CLI/daemon does not suppress the
other provider. Counts go to stdout; diagnostics go to stderr. The script does
not start agents or a daemon just to populate the bar.

### Codex collection

`codex_threads()` connects to
`${CODEX_HOME:-$HOME/.codex}/app-server-control/app-server-control.sock` using
`websockets.sync.client.unix_connect`. This socket uses **WebSocket framing and
HTTP Upgrade**, not newline-delimited JSON. `codex app-server proxy` only proxies
raw bytes; writing plain JSON into it is insufficient for this socket.

The current read-only sequence is:

1. Send `initialize` with a client name/version, then `initialized`.
2. Page through `thread/loaded/list`, respecting `nextCursor`.
3. Read each thread using `thread/read` with `includeTurns: false`.
4. Apply `codex_state()` and the terminal-liveness check below.

`codex_state()` excludes blank `preview` values and threads with
`parentThreadId`. It maps statuses as follows:

| Runtime state                                             | Widget state |
| --------------------------------------------------------- | ------------ |
| `active` with no waiting flags                            | Running      |
| `active` with `waitingOnApproval` or `waitingOnUserInput` | Waiting      |
| `idle`                                                    | Waiting      |
| `notLoaded`, `systemError`                                | Excluded     |

For names, the raw thread metadata can supply `name`, `preview`, `cwd`, and `id`.
Prefer the explicit name and provide a short preview/ID fallback. Terminal
sessions observed here report `source: "vscode"` but
`originator: "codex-tui"`; do not assume `source` identifies the terminal client.

### Preserve the Kitty-close fix

The daemon can retain disconnected threads in memory for 30 minutes. A cached
thread may still report `idle`, `canAcceptDirectInput: true`, and an MCP
`runtimeStatus` of `connected`. These fields alone do not prove a terminal exists.

For a countable thread with `originator == "codex-tui"`, the collector requests:

```json
{
  "id": 7,
  "method": "mcpServerStatus/list",
  "params": {
    "threadId": "THREAD_ID",
    "serverName": "codex_tui",
    "detail": "toolsAndAuthOnly"
  }
}
```

The `codex_tui` entry exposes a credential-free `httpOrigin`, such as
`http://127.0.0.1:PORT`, for the local service owned by that terminal client.
`codex_client_alive()` attempts a TCP connection with a **200ms timeout**, closing
it immediately. A closed service excludes the thread. Results are cached by
origin within one poll. Only HTTP origins on `127.0.0.1` or `::1` are probed;
unknown metadata/transports retain the previous classification.

This fixes abrupt terminal death without depending on exit hooks. It was verified
against a real cached idle session whose endpoint refused connections, and by a
test that kills a disposable client process while the fake daemon retains its
session and `connected` status. This is a presence filter: it neither deletes the
conversation nor stops daemon work. It also does not establish that a live
terminal currently has a particular conversation in the foreground.

### Claude collection

`claude_sessions()` runs `claude agents --json` with a two-second timeout. It
deliberately omits `--all`, which also lists historical completed background
sessions. Entries can supply `kind`, `sessionId`, `name`, `cwd`, `pid`, `status`,
`state`, and `waitingFor`, depending on session kind and process liveness.

`has_claude_task()` treats background `working`/`done` states as task evidence.
Otherwise, it checks
`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/*/SESSION_ID.jsonl` for a real user
message, ignoring startup metadata and tool-result-only messages. A newly opened
empty session must remain excluded.

After that guard, `claude_state()` maps background `working` to running,
`blocked`/`done` to waiting, and excludes `failed`/`stopped`. Interactive `busy`
means running; `waiting`/`idle` mean waiting. A blocked session with no task is
excluded. Background work can remain active between steps even when its process
reports idle; preserve the task-state precedence.

## Proposed shared data flow

The collector currently returns counts only; there is no public session-list or
approval API in this repository. Extend it around a shared normalized session
model, with counts derived from the same filtered rows that populate the window.
Keep the existing classification helpers and tests as the starting point.

Useful row fields are provider, provider session ID, display name, working
directory, normalized state, waiting reason, optional terminal/window target, and
pending approval records. Distinguish `idle after completion` from
`approval pending` in the detailed UI even though both contribute to waiting.
Use provider plus session ID for identity, rather than a display name or list
position.

Approval handling needs a persistent event/response bridge or hooks. Do not add
another independent polling script that disagrees with the bar, or restart an
approval connection every three seconds. Keep provider connection/correlation
logic outside Yuck; expose JSON state and explicit actions to the widgets.

## Jump to the terminal instance

No reliable session-to-window mapping has been implemented yet. Claude's live
`pid` can help find the terminal ancestor. Codex thread summaries do not supply a
terminal PID; the local endpoint may help identify its owning process, but that
mapping still needs to be implemented and tested.

Resolve the actual terminal window and focus its Sway container. Kitty can host
multiple tabs/windows in one process, so a PID alone may not identify the desired
tab. A `KITTY_WINDOW_ID` also needs the owning Kitty instance to disambiguate it.
The current Kitty config does not configure remote control; do not assume it is
available. Directory/title matching alone is insufficient when several sessions
share a project or have duplicate titles.

If the instance has exited or a background task has no attached window, disable
the jump action or explain that condition. Do not silently launch a replacement
session and present it as focusing the original one.

## Approval prompt integration

The installed Codex schema and vendor documentation expose approval mechanisms;
**no approval forwarding or response code has been built or tested here**. The
existing status polling only reports that an agent is waiting.

### Codex protocol

Relevant server request methods include
`item/commandExecution/requestApproval`, `item/fileChange/requestApproval`,
`item/permissions/requestApproval`, and `item/tool/requestUserInput`. Command
requests can include the command, working directory, reason, available decisions,
and a proposed command rule. Network/file/input requests have different payloads;
render the actual request type.

For a command approval, a response uses the incoming JSON-RPC request ID:

```json
{ "id": 17, "result": { "decision": "accept" } }
```

**Yes** maps to `accept`; **No** to `decline`. `cancel` additionally interrupts the
turn. **Always** must use an offered scope: `acceptForSession`, or
`acceptWithExecpolicyAmendment` with the supplied matching-command rule. Show the
scope and omit unsupported choices. Permission grants use their own response
schema. Track `serverRequest/resolved` to remove answered or withdrawn prompts.

The first integration experiment must establish how a second client receives
pending requests, whether existing requests are replayed, and whether responses
from it are accepted while the original terminal is connected. `thread/read`
does not subscribe to events. Do not assume that resuming a thread is a harmless
subscription operation.

The current `rpc()` helper discards messages whose ID does not match its current
outgoing request, including server requests. A persistent approval bridge must
dispatch and retain those messages instead. Correlate approvals by provider,
session/thread, turn, and request ID; do not confuse an item ID or optional
approval callback ID with the JSON-RPC response ID.

### Claude hooks

A synchronous `PermissionRequest` hook receives tool input and optional
`permission_suggestions`. It can forward the request to the UI, wait for a
decision, and return `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": { "behavior": "allow" }
  }
}
```

**No** uses `behavior: "deny"`. **Always** can return an appropriate
`updatedPermissions` entry, using the suggested rule and an explicit destination
such as `session`, `localSettings`, `projectSettings`, or `userSettings`. These
destinations have different persistence scopes.

The hook must correlate its pending request with the row and route the response
back to that invocation. Configure it through the repository's managed settings
workflow. Hook installation and interactive behavior still need validation on the
installed version. `Notification` hooks alone cannot answer prompts.

Not every prompt uses `PermissionRequest`: sandbox network requests and MCP
elicitation have other paths. Read the documented coverage before promising that
all prompts support the same three actions.

### Popup behavior to implement

- Show a dropdown/expander on the relevant agent row when a real pending approval
  exists, containing the action/command, reason, and applicable scope.
- Preserve multiple queued approvals and handle simultaneous requests from
  different agents without sending a decision to the wrong one.
- A reply in the terminal, interruption, disconnect, or stale request must clear
  or disable the popup's pending action. Prevent double submission.
- Keep the normal terminal approval path usable when the popup closes or the
  bridge is unavailable. A closed popup is not an approval.
- Render commands as text. Use IDs to send decisions; never execute displayed
  command text through an Eww shell action.
- General questions may require options or free text. Do not turn every
  `waitingOnUserInput` state into a Yes/Always/No permission prompt.

## Working draggable window foundation

Use the tested XWayland path as the starting point for the floating agent window.
The bar continues to use the packaged `/usr/bin/eww` on native Wayland. The
separately installed `~/.local/bin/eww-x11` is Eww `0.6.0`, compiled from the same
upstream revision as the packaged build with only the X11 feature enabled.
XWayland is available in the running Sway session.

### Build and provisioning

[The source manifest](../provision/eww-x11.json) pins the full revision, archive
URL, and SHA-256. [The dependency group](../packages/eww-build.txt) declares
Cargo/Rust and the GTK, X11, and DBusMenu development packages. Both the
dependencies and executable have already been installed on this machine.

To reproduce the setup, review the dependency plan and run the packages phase
as root, preserving its confirmation prompt:

```sh
./install packages --group eww-build --dry-run
./install packages --group eww-build
```

Then run the source provisioning command as the desktop user:

```sh
bin/install-eww-x11 --dry-run
bin/install-eww-x11
```

It verifies the source checksum, uses Cargo's lockfile, and installs a separate
executable. It reuses an unchanged managed installation and preserves unmanaged
or modified targets, including changes made while compilation is running.
`--offline` supports rebuilding from cached source and dependencies. See
[the build notes](eww-x11.md) for cache locations and build-job controls.

### Reusable widget and launcher

The working [Yuck configuration](../experiments/eww-drag/eww.yuck) is deliberately
small:

```lisp
(defwindow drag_test
  :windowtype "dialog"
  :wm-ignore false
  (label :text "Eww drag test: hold Alt and drag me"))
```

[Its CSS](../experiments/eww-drag/eww.css) supplies the background, border,
padding, and text size. Sway automatically floats this dialog; no permanent
window rule was needed. The existing `floating_modifier Mod1` provides
**Alt + left-drag**.

Use the existing launcher to open, inspect, or stop the experiment:

```sh
experiments/eww-drag/run
experiments/eww-drag/run active-windows
experiments/eww-drag/run close drag_test
experiments/eww-drag/run kill
```

The launcher unsets `WAYLAND_DISPLAY`, sets `GDK_BACKEND=x11` and
`XDG_SESSION_TYPE=x11`, and calls `~/.local/bin/eww-x11` with an explicit
`--config` directory. That directory identifies the separate Eww daemon.
Use the launcher as a template for the production agent-window configuration.
Send every open, close, update, and other popup command to the same binary and
configuration directory. The bar's existing `eww` variable and popup helper
currently address its Wayland daemon.

Eww variables are local to each daemon. The X11 window cannot automatically
reuse the bar daemon's `agent_counts` variable; feed both views from the shared
collector/bridge described above, and route UI updates to the appropriate daemon.

### Geometry pitfall and verified behavior

**Omit `:geometry` from the draggable dialog.** In the pinned Eww revision,
non-`normal` X11 windows with geometry register a configure-event handler that
reapplies their configured position. The first test combined dialog geometry
with dragging and snapped back to its initial position with very choppy movement.
Removing geometry lets Sway own placement and movement. Use child-widget/CSS
sizing, and Sway rules if explicit initial placement is needed.

After the change, Sway reported the window as `type: "floating_con"`,
`shell: "xwayland"`, class `Eww-x11`, instance `eww-x11`, title
`Eww - drag_test`, and window type `dialog`. A programmatic Sway move held its new
position, and the user confirmed the revised manual dragging behavior was
accepted. Recheck the production window's actual properties before adding Sway
rules; the class is shared by X11 widgets, so scope rules to the intended window.

The experiment contains static text only and validates dragging during the
window's lifetime; it does not save positions across closing/reopening. Agent
rows, terminal targeting, and approval controls remain to be implemented.
Keep the bar on its existing Wayland instance. A new main-config
`defwindow` also requires updating the inventory in `tests/eww-checks.py`; the
isolated experiment is outside that inventory.

## Validation and next steps

The current nine collector tests and `tests/lint.sh` passed after the liveness
fix. Python formatting, type checking, linting, and spelling checks also passed.
For a documentation-only handoff, those are the last implementation verification
results, not a claim that the proposed popup or approvals work.

The pinned X11 build succeeded, the provisioning tests and repository checks
passed, and the user accepted the corrected live drag test. The draggable window
foundation is ready to reuse; approval routing and the actual agent UI remain
unverified.

Start by reading the collector/tests, reusing the proven XWayland window pattern,
and proving Codex approval routing with a benign request. Then connect a shared
session list, stable window targeting, and provider-specific approval bridges to
the new UI. Preserve the existing count output and no-task/liveness exclusions.

Run the relevant checks after implementation:

```sh
python3 tests/eww_agents_checks.py
bash tests/eww-x11-test.sh
tests/lint.sh
```

Extend coverage for list/count agreement, duplicate names and projects, window
focus mapping, terminal death, approval scopes, stale/double responses, terminal
answers racing popup answers, and multiple pending requests. Verify the actual
floating UI and a real approval round trip manually.

Follow [the shared assistant rules](../config/assistants/instructions.md) and the
current Neovim formatter/linter mappings. Provision any new host dependencies
through the documented dotfiles manifests and installer. Keep unrelated cleanup
and the other agent's work out of task commits. `/tmp` schema/probe files from
this conversation are disposable; regenerate version-specific schemas with
`codex app-server generate-json-schema --experimental --out /tmp/codex-agent-schema`
when needed.

## References

- [Codex app-server protocol and approvals](https://learn.chatgpt.com/docs/app-server#approvals)
- [Codex loaded threads and subscriptions](https://learn.chatgpt.com/docs/app-server#unsubscribe-from-a-loaded-thread)
- [Claude session JSON fields](https://code.claude.com/docs/en/agent-view#list-sessions-as-json)
- [Claude PermissionRequest hooks and decisions](https://code.claude.com/docs/en/hooks#permissionrequest)
- [Claude permission update entries](https://code.claude.com/docs/en/hooks#permission-update-entries)
