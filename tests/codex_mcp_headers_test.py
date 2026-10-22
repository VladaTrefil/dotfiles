#!/usr/bin/env python3
"""Exercise the MCP credential helper using synthetic 1Password responses."""

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

HELPER = Path(__file__).resolve().parents[1] / "bin/codex-mcp-headers"
FAKE_OP = """#!/usr/bin/python3
import json
import os
from pathlib import Path
import sys

if sys.argv[1:3] != ["read", "--no-newline"] or len(sys.argv) != 4:
    sys.exit(98)
with Path(os.environ["TEST_OP_LOG"]).open("a") as log:
    log.write(sys.argv[3] + "\\n")
if os.environ.get("TEST_OP_FAILURE") in ("1", sys.argv[3]):
    print("synthetic-error-secret", file=sys.stdout)
    print("synthetic-error-secret", file=sys.stderr)
    sys.exit(1)
data = json.loads(Path(os.environ["TEST_OP_DATA"]).read_text())
try:
    print(data[sys.argv[3]], end="")
except KeyError:
    sys.exit(1)
"""


class HeaderHelperTests(unittest.TestCase):
    """Check protocol output, reference validation, and credential isolation."""

    def setUp(self) -> None:
        # addCleanup also runs if a later setup operation fails.
        # pylint: disable-next=consider-using-with
        temporary = tempfile.TemporaryDirectory(prefix="codex-mcp-headers-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        home = self.root / "home with spaces"
        config_home = home / "custom config"
        self.manifest = config_home / "dotfiles/codex-mcp.env"
        self.manifest.parent.mkdir(parents=True)
        self.manifest.write_text(
            "# Reference-only fixture\n"
            'STITCH_API_KEY="op://Test Vault/Stitch/credential"\n'
            "OTHER_KEY='op://Test Vault/Other/credential'\n"
            "UNRELATED_KEY=op://Test/Unused/credential\n"
        )
        fake_bin = self.root / "bin"
        fake_bin.mkdir()
        op = fake_bin / "op"
        op.write_text(FAKE_OP)
        op.chmod(0o700)
        self.log = self.root / "op.log"
        self.data_file = self.root / "responses.json"
        self.data = {
            "op://Test Vault/Stitch/credential": 'synthetic-stitch-"\\key',
            "op://Test Vault/Other/credential": "synthetic-other-key",
        }
        self.data_file.write_text(json.dumps(self.data))
        self.env = {
            "HOME": str(home),
            "XDG_CONFIG_HOME": str(config_home),
            "PATH": f"{fake_bin}:/usr/bin:/bin",
            "TEST_OP_LOG": str(self.log),
            "TEST_OP_DATA": str(self.data_file),
            "STITCH_API_KEY": "stale-inherited-value",
        }

    def run_helper(self, *args: str) -> subprocess.CompletedProcess[str]:
        """Invoke the real helper in an isolated environment."""
        return subprocess.run(
            ["/usr/bin/python3", str(HELPER), *args],
            env=self.env,
            cwd=self.root,
            capture_output=True,
            text=True,
            check=False,
        )

    def assert_failure(self, result: subprocess.CompletedProcess[str]) -> None:
        """Require a failure without protocol output or dependency diagnostics."""
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertNotIn("synthetic-error-secret", result.stderr)

    def test_multiple_headers_use_only_requested_references_and_ignore_stale_env(self):
        """Unused references and stale inherited keys cannot affect headers."""
        result = self.run_helper("X-Goog-Api-Key=STITCH_API_KEY", "X-Other=OTHER_KEY")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            json.loads(result.stdout),
            {
                "X-Goog-Api-Key": 'synthetic-stitch-"\\key',
                "X-Other": "synthetic-other-key",
            },
        )
        self.assertEqual(result.stderr, "")
        self.assertEqual(
            self.log.read_text().splitlines(),
            [
                "op://Test Vault/Stitch/credential",
                "op://Test Vault/Other/credential",
            ],
        )

    def test_bearer_token_and_reused_variable_resolve_once(self):
        """A token can populate two headers without fetching it twice."""
        result = self.run_helper("--bearer", "OTHER_KEY", "X-Token=OTHER_KEY")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            json.loads(result.stdout),
            {
                "Authorization": "Bearer synthetic-other-key",
                "X-Token": "synthetic-other-key",
            },
        )
        self.assertEqual(len(self.log.read_text().splitlines()), 1)

    def test_home_fallback_and_explicit_file(self):
        """Honor XDG defaults and explicitly selected reference files."""
        del self.env["XDG_CONFIG_HOME"]
        result = self.run_helper("X-Key=OTHER_KEY")
        self.assert_failure(result)
        fallback = Path(self.env["HOME"]) / ".config/dotfiles/codex-mcp.env"
        fallback.parent.mkdir(parents=True)
        fallback.write_text(self.manifest.read_text())
        self.assertEqual(self.run_helper("X-Key=OTHER_KEY").returncode, 0)
        self.assertEqual(
            self.run_helper(
                "--env-file", str(self.manifest), "X-Key=OTHER_KEY"
            ).returncode,
            0,
        )

    def test_missing_file_or_op_never_produces_headers(self):
        """Unavailable prerequisites fail before protocol output."""
        self.assert_failure(
            self.run_helper("--env-file", str(self.root / "absent"), "X-Key=OTHER_KEY")
        )
        self.env["PATH"] = str(self.root)
        self.assert_failure(self.run_helper("X-Key=OTHER_KEY"))
        self.assertFalse(self.log.exists())

    def test_explicit_op_avoids_a_shadowed_or_missing_path_entry(self):
        """Select the desktop-integrated CLI independently of shell PATH."""
        self.env["PATH"] = str(self.root)
        result = self.run_helper("--op", str(self.root / "bin/op"), "X-Key=OTHER_KEY")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), {"X-Key": "synthetic-other-key"})
        missing = self.run_helper(
            "--op", str(self.root / "absent-op"), "X-Key=OTHER_KEY"
        )
        self.assert_failure(missing)
        self.assertIn("packages --group onepassword", missing.stderr)

    def test_relative_op_executes_the_selected_file_without_path_lookup(self):
        """The executable checked by --op is also the executable that runs."""
        selected = self.root / "op"
        selected.write_text(FAKE_OP)
        selected.chmod(0o700)
        self.env["PATH"] = str(self.root / "absent")
        result = self.run_helper("--op", "./op", "X-Key=OTHER_KEY")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), {"X-Key": "synthetic-other-key"})

    def test_invalid_reference_file_is_rejected_before_retrieval(self):
        """Never evaluate shell text or accept ambiguous reference entries."""
        for contents in (
            "STITCH_API_KEY=plaintext-secret\n",
            'STITCH_API_KEY="$(touch injected)"\n',
            "STITCH_API_KEY=op://Test/Item/key\nSTITCH_API_KEY=op://Test/Other/key\n",
            "not-a-variable=op://Test/Item/key\n",
            "STITCH_API_KEY=op://only-vault\n",
            'STITCH_API_KEY="op://Test/Item/key\n',
        ):
            with self.subTest(contents=contents):
                self.manifest.write_text(contents)
                result = self.run_helper("X-Key=STITCH_API_KEY")
                self.assert_failure(result)
                self.assertNotIn("plaintext-secret", result.stderr)
                self.assertFalse(self.log.exists())
                self.assertFalse((self.root / "injected").exists())

    def test_invalid_or_missing_mappings_never_retrieve_credentials(self):
        """Validate every requested header and variable before contacting op."""
        for args in (
            (),
            ("X-Key=ABSENT_KEY",),
            ("MissingEquals",),
            ("Invalid Header=OTHER_KEY",),
            ("X-Key=bad-name",),
            ("X-Key=OTHER_KEY", "x-key=STITCH_API_KEY"),
            ("--bearer", "OTHER_KEY", "Authorization=STITCH_API_KEY"),
            ("--bearer", "OTHER_KEY", "--bearer", "STITCH_API_KEY"),
        ):
            with self.subTest(args=args):
                self.assert_failure(self.run_helper(*args))
                self.assertFalse(self.log.exists())

    def test_op_failure_suppresses_both_output_streams(self):
        """Dependency failure output cannot leak into the protocol or errors."""
        for failure in (
            "op://Test Vault/Stitch/credential",
            "op://Test Vault/Other/credential",
        ):
            with self.subTest(failure=failure):
                self.env["TEST_OP_FAILURE"] = failure
                result = self.run_helper("X-Stitch=STITCH_API_KEY", "X-Other=OTHER_KEY")
                self.assert_failure(result)
                for value in self.data.values():
                    self.assertNotIn(value, result.stderr)

    def test_invalid_credential_never_emits_partial_headers(self):
        """Reject empty keys and header injection before emitting any header."""
        for credential in ("", "header\ninjection", "header\rinjection", "nul\0byte"):
            with self.subTest(credential=credential):
                self.data["op://Test Vault/Other/credential"] = credential
                self.data_file.write_text(json.dumps(self.data))
                self.assert_failure(
                    self.run_helper("X-Stitch=STITCH_API_KEY", "X-Other=OTHER_KEY")
                )

    def test_help_needs_neither_reference_file_nor_op(self):
        """Help remains usable before credential setup."""
        self.manifest.unlink()
        self.env["PATH"] = str(self.root)
        result = self.run_helper("--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main()
