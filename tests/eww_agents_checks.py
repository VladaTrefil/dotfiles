#!/usr/bin/env python3
"""Check live agent classification and the Codex socket protocol."""

import json
import runpy
import socket
import subprocess
import sys
import tempfile
import threading
import unittest
from contextlib import contextmanager
from pathlib import Path
from unittest.mock import patch

from websockets.sync.server import unix_serve

SCRIPT = Path(__file__).resolve().parents[1] / "config/eww/bar/scripts/agents"


def codex_thread(thread_id, status, preview="Implement the task", **extra):
    """Build the required fields of a Codex thread summary."""
    return {
        "id": thread_id,
        "sessionId": thread_id,
        "preview": preview,
        "status": status,
        "source": "vscode",
        "cliVersion": "0.163.0",
        "createdAt": 1,
        "updatedAt": 2,
        "cwd": "/tmp/project",
        "ephemeral": False,
        "modelProvider": "openai",
        "projectId": None,
        "turns": [],
        **extra,
    }


@contextmanager
def codex_daemon(home, threads, origins=None):
    """Keep cached sessions and MCP metadata alive independently of their TUIs."""
    socket_dir = home / "app-server-control"
    socket_dir.mkdir()
    origins = origins or {}

    def respond(connection):
        for raw in connection:
            request = json.loads(raw)
            if "id" not in request:
                continue
            method = request["method"]
            if method == "initialize":
                result = {}
            elif method == "thread/loaded/list":
                # A second page catches collectors that stop at the first page.
                remaining = bool(request["params"].get("cursor"))
                result = {
                    "data": list(threads)[2:] if remaining else list(threads)[:2],
                    "nextCursor": None if remaining or len(threads) <= 2 else "next",
                }
            elif method == "thread/read":
                result = {"thread": threads[request["params"]["threadId"]]}
            elif method == "mcpServerStatus/list":
                origin = origins.get(request["params"]["threadId"])
                result = {
                    "data": (
                        []
                        if origin is None
                        else [
                            {
                                "name": "codex_tui",
                                "httpOrigin": origin,
                                "runtimeStatus": "connected",
                                "authStatus": "unsupported",
                                "tools": {},
                                "resources": [],
                                "resourceTemplates": [],
                            }
                        ]
                    ),
                    "nextCursor": None,
                }
            else:
                raise AssertionError(f"Unexpected mutating request: {method}")
            connection.send(json.dumps({"method": "unrelated/notification"}))
            connection.send(json.dumps({"id": request["id"], "result": result}))

    with unix_serve(respond, str(socket_dir / "app-server-control.sock")) as server:
        worker = threading.Thread(target=server.serve_forever, daemon=True)
        worker.start()
        try:
            yield
        finally:
            server.shutdown()
            worker.join(timeout=2)


class AgentChecks(unittest.TestCase):
    """Keep untouched sessions and unavailable providers out of the counts."""

    def setUp(self):
        self.assertTrue(SCRIPT.is_file(), "The agent collector is not implemented")
        self.agent = runpy.run_path(str(SCRIPT))
        # unittest closes this context after the test, including on failure.
        # pylint: disable-next=consider-using-with
        self.home = Path(self.enterContext(tempfile.TemporaryDirectory()))

    def test_codex_distinguishes_work_questions_and_completed_turns(self):
        """Pending approvals/questions and completed turns enter the green count."""
        cases = [
            ({"type": "active", "activeFlags": []}, "running"),
            ({"type": "active", "activeFlags": ["waitingOnApproval"]}, "waiting"),
            ({"type": "active", "activeFlags": ["waitingOnUserInput"]}, "waiting"),
            ({"type": "idle"}, "waiting"),
            ({"type": "notLoaded"}, None),
            ({"type": "systemError"}, None),
        ]
        for status, expected in cases:
            with self.subTest(status=status):
                self.assertEqual(
                    self.agent["codex_state"](codex_thread("task", status)), expected
                )

    def test_codex_excludes_untouched_sessions_and_internal_subagents(self):
        """An empty prompt or a child thread must not inflate session counts."""
        for thread in [
            codex_thread("empty", {"type": "idle"}, preview="  "),
            codex_thread(
                "child", {"type": "active", "activeFlags": []}, parentThreadId="parent"
            ),
        ]:
            with self.subTest(thread=thread["id"]):
                self.assertIsNone(self.agent["codex_state"](thread))

    def test_claude_requires_a_real_task_for_interactive_sessions(self):
        """A live session's busy/idle flags alone do not prove it has a task."""
        session = {
            "kind": "interactive",
            "sessionId": "session-1",
            "pid": 123,
            "cwd": "/tmp/project",
            "startedAt": 1,
            "status": "idle",
        }
        transcript = self.home / "projects/project/session-1.jsonl"
        transcript.parent.mkdir(parents=True)
        transcript.write_text(json.dumps({"type": "system"}) + "\n")
        self.assertIsNone(self.agent["claude_state"](session, self.home))
        with transcript.open("a") as stream:
            stream.write(
                json.dumps(
                    {
                        "type": "user",
                        "message": {
                            "role": "user",
                            "content": "Implement the task",
                        },
                    }
                )
                + "\n"
            )
        for status, expected in [
            ("busy", "running"),
            ("waiting", "waiting"),
            ("idle", "waiting"),
        ]:
            session["status"] = status
            with self.subTest(status=status):
                self.assertEqual(
                    self.agent["claude_state"](session, self.home), expected
                )

    def test_claude_ignores_metadata_and_tool_results_as_first_task(self):
        """Startup metadata and tool results must not look like user tasks."""
        transcript = self.home / "projects/project/session-1.jsonl"
        transcript.parent.mkdir(parents=True)
        transcript.write_text(
            "\n".join(
                json.dumps(message)
                for message in [
                    {
                        "type": "user",
                        "isMeta": True,
                        "message": {"role": "user", "content": "Startup context"},
                    },
                    {
                        "type": "user",
                        "message": {
                            "role": "user",
                            "content": [
                                {"type": "tool_result", "content": "Result"},
                            ],
                        },
                    },
                ]
            )
            + "\n"
        )
        self.assertIsNone(
            self.agent["claude_state"](
                {"sessionId": "session-1", "status": "waiting"}, self.home
            )
        )

    def test_claude_background_tasks_use_task_state(self):
        """Self-directed work still runs between steps; stopped work is excluded."""
        for state, expected in [
            ("working", "running"),
            ("done", "waiting"),
            ("failed", None),
            ("stopped", None),
            ("blocked", None),
        ]:
            with self.subTest(state=state):
                self.assertEqual(
                    self.agent["claude_state"](
                        {"kind": "background", "state": state, "status": "idle"},
                        self.home,
                    ),
                    expected,
                )

    def test_codex_reads_existing_daemon_over_websocket_with_pagination(self):
        """Real socket framing, notifications, and pagination preserve all sessions."""
        threads = {
            "running": codex_thread("running", {"type": "active", "activeFlags": []}),
            "empty": codex_thread("empty", {"type": "idle"}, preview=""),
            "waiting": codex_thread("waiting", {"type": "idle"}),
        }

        with codex_daemon(self.home, threads):
            result = self.agent["codex_threads"](self.home)
            self.assertEqual(
                [thread["id"] for thread in result], ["running", "empty", "waiting"]
            )

    def test_killed_terminal_drops_cached_waiting_task_without_exit_hook(self):
        """A force-killed terminal disappears even when its cached status is connected."""
        threads = {
            "task": codex_thread(
                "task",
                {"type": "idle"},
                originator="codex-tui",
            )
        }
        command = (
            "import socket, sys; "
            "server = socket.create_server(('127.0.0.1', 0)); "
            "print(server.getsockname()[1], flush=True); sys.stdin.read()"
        )
        with subprocess.Popen(
            [sys.executable, "-c", command],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
        ) as client:
            self.assertIsNotNone(client.stdout)
            origin = f"http://127.0.0.1:{client.stdout.readline().strip()}"
            with codex_daemon(self.home, threads, {"task": origin}):
                self.assertEqual(len(self.agent["codex_threads"](self.home)), 1)
                client.kill()
                client.wait(timeout=2)
                self.assertEqual(self.agent["codex_threads"](self.home), [])

    def test_dead_terminal_does_not_hide_live_terminal_or_other_clients(self):
        """Filter per session, including pending prompts, rather than per daemon."""
        with socket.create_server(("127.0.0.1", 0)) as closed:
            dead_origin = f"http://127.0.0.1:{closed.getsockname()[1]}"
        threads = {
            "dead": codex_thread(
                "dead",
                {
                    "type": "active",
                    "activeFlags": ["waitingOnUserInput"],
                },
                originator="codex-tui",
            ),
            "live": codex_thread("live", {"type": "idle"}, originator="codex-tui"),
            "other": codex_thread("other", {"type": "idle"}, originator="vscode"),
            "unknown": codex_thread(
                "unknown", {"type": "idle"}, originator="codex-tui"
            ),
        }
        with socket.create_server(("127.0.0.1", 0)) as live:
            origins = {
                "dead": dead_origin,
                "live": f"http://127.0.0.1:{live.getsockname()[1]}",
            }
            with codex_daemon(self.home, threads, origins):
                result = self.agent["codex_threads"](self.home)
                self.assertEqual(
                    [thread["id"] for thread in result], ["live", "other", "unknown"]
                )

    def test_unavailable_codex_does_not_hide_working_claude(self):
        """Failure of one provider leaves the other provider's count intact."""
        with patch.dict(
            self.agent["collect_counts"].__globals__,
            {
                "codex_threads": lambda _home: (_ for _ in ()).throw(
                    OSError("offline")
                ),
                "claude_sessions": lambda: [
                    {"kind": "background", "state": "working", "status": "busy"},
                    {"kind": "background", "state": "done", "status": "idle"},
                ],
            },
        ):
            self.assertEqual(
                self.agent["collect_counts"](), {"running": 1, "waiting": 1}
            )


if __name__ == "__main__":
    unittest.main()
