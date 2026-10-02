#!/usr/bin/env python3
"""Exercise the real login profile on PTYs with harmless launcher replacements."""
import errno
import os
from pathlib import Path
import pty
import select
import subprocess
import tempfile
import time


ROOT = Path(__file__).resolve().parents[1]


def probe(name, *, expected=None, environment=None, tty='/dev/tty1',
          interactive=True, terminal=True, stdout_terminal=True,
          disabled=False, launcher_status=0, missing=False, executable=True):
    with tempfile.TemporaryDirectory(prefix='sway autostart ') as directory:
        home = Path(directory)
        config = home / '.config'
        (config / 'shell').mkdir(parents=True)
        (config / 'shell/profile').write_bytes((ROOT / 'config/shell/profile').read_bytes())
        launchers = config / 'sway/bin'
        launchers.mkdir(parents=True)
        for profile in ('physical', 'virtualbox'):
            if missing:
                continue
            launcher = launchers / f'start-{profile}'
            launcher.write_text(
                '#!/bin/sh\n'
                f'printf "%s\\n" {profile} >> "$HOME/launches"\n'
                f'exit {launcher_status}\n'
            )
            launcher.chmod(0o755 if executable else 0o644)
        if disabled:
            (config / 'dotfiles').mkdir()
            (config / 'dotfiles/sway-autostart-disabled').touch()
        env = {
            'HOME': str(home), 'XDG_CONFIG_HOME': str(config),
            'PATH': '/usr/bin:/bin', 'TERM': 'dumb', 'LC_ALL': 'C',
            'XDG_VTNR': '1', 'SWAY_PROFILE': 'physical',
        }
        for key, value in (environment or {}).items():
            if value is None:
                env.pop(key, None)
            else:
                env[key] = value
        # A PTY supplies real isatty checks. Only Zsh's TTY string is simulated;
        # no real VT is opened, switched, or occupied. -df skips all startup files
        # before we explicitly source the repository's complete .zprofile.
        command = [
            'zsh', '-dfilc' if interactive else '-dflc',
            'TTY=$1; source "$2"; print -r -- SHELL_READY',
            'sway-autostart-test', tty, str(ROOT / 'config/zsh/.zprofile'),
        ]
        master, slave = pty.openpty()
        child = subprocess.Popen(
            command, env=env, cwd=home,
            stdin=slave if terminal else subprocess.DEVNULL,
            stdout=slave if stdout_terminal else subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        os.close(slave)
        output = bytearray()
        deadline = time.monotonic() + 10
        while child.poll() is None or select.select([master], [], [], 0)[0]:
            if time.monotonic() > deadline:
                child.kill()
                child.communicate()
                raise AssertionError(f'{name}: shell timed out')
            if select.select([master], [], [], 0.1)[0]:
                try:
                    chunk = os.read(master, 65536)
                except OSError as error:
                    if error.errno == errno.EIO:
                        break
                    raise
                if not chunk:
                    break
                output.extend(chunk)
        os.close(master)
        stdout, errors = child.communicate(timeout=5)
        output.extend(stdout or b'')
        marker = home / 'launches'
        launches = marker.read_text().splitlines() if marker.exists() else []
        assert launches == ([] if expected is None else [expected]), (
            f'{name}: expected {expected or "no launch"}, got {launches}'
        )
        assert child.returncode == 0 and not errors and b'SHELL_READY' in output, (
            f'{name}: shell not preserved: exit={child.returncode}, '
            f'stderr={errors!r}, output={output!r}'
        )
        print(f'PASS: {name}; launches={launches}; shell returned; stderr=0 bytes')


def main():
    # SSH deliberately carries VT=1 and a simulated tty1: these regressions
    # must depend on SSH exclusion itself, not an incidental PTY/VT mismatch.
    for key in ('SSH_CONNECTION', 'SSH_CLIENT', 'SSH_TTY'):
        for value in ('remote-session', ''):
            probe(f'SSH {key}={value!r}', environment={key: value})
    for vt in ('2', '3', '6', '', '01', None):
        probe(f'non-tty1 VT {vt!r}', tty=f'/dev/tty{vt}', environment={'XDG_VTNR': vt})
    probe('PTY with stale VT=1', tty='/dev/pts/1')
    probe('tty1 with VT unset', environment={'XDG_VTNR': None})
    probe('non-interactive login', interactive=False)
    probe('stdin is not a terminal', terminal=False)
    probe('stdout is not a terminal', stdout_terminal=False)
    for key in ('WAYLAND_DISPLAY', 'DISPLAY', 'SWAYSOCK'):
        for value in ('existing-session', ''):
            probe(f'already set {key}={value!r}', environment={key: value})
    for profile in (None, '', 'unknown', '../physical', 'physical virtualbox'):
        probe(f'undetermined profile {profile!r}', environment={'SWAY_PROFILE': profile})
    probe('environment bypass', environment={'DOTFILES_SWAY_AUTOSTART': '0'})
    probe('persistent bypass', disabled=True)
    probe('missing launcher', missing=True)
    probe('non-executable launcher', executable=False)
    probe('physical tty1', expected='physical')
    probe('VirtualBox tty1', expected='virtualbox', environment={'SWAY_PROFILE': 'virtualbox'})
    probe('failed launcher returns to shell', expected='physical', launcher_status=42)


if __name__ == '__main__':
    main()
