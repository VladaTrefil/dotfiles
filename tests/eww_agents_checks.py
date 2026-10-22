#!/usr/bin/env python3
"""Check live agent classification and the Codex socket protocol."""

import json
import runpy
import tempfile
import threading
import unittest
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
        socket_dir = self.home / "app-server-control"
        socket_dir.mkdir()
        threads = {
            "running": codex_thread("running", {"type": "active", "activeFlags": []}),
            "empty": codex_thread("empty", {"type": "idle"}, preview=""),
            "waiting": codex_thread("waiting", {"type": "idle"}),
        }

        def respond(connection):
            for raw in connection:
                request = json.loads(raw)
                if "id" not in request:
                    continue
                method = request["method"]
                if method == "initialize":
                    result = {}
                elif method == "thread/loaded/list":
                    result = (
                        {"data": ["waiting"], "nextCursor": None}
                        if request["params"].get("cursor")
                        else {"data": ["running", "empty"], "nextCursor": "next"}
                    )
                elif method == "thread/read":
                    result = {"thread": threads[request["params"]["threadId"]]}
                else:
                    raise AssertionError(f"Unexpected mutating request: {method}")
                connection.send(json.dumps({"method": "unrelated/notification"}))
                connection.send(json.dumps({"id": request["id"], "result": result}))

        with unix_serve(respond, str(socket_dir / "app-server-control.sock")) as server:
            worker = threading.Thread(target=server.serve_forever, daemon=True)
            worker.start()
            try:
                result = self.agent["codex_threads"](self.home)
                self.assertEqual(
                    [thread["id"] for thread in result], ["running", "empty", "waiting"]
                )
            finally:
                server.shutdown()
                worker.join(timeout=2)

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
