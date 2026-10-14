#!/usr/bin/env python3
"""Reject bindings that overwrite another binding in the same Sway mode."""
from pathlib import Path
from glob import glob
import re
import sys


SWAY = Path(__file__).resolve().parents[1] / "config/sway"
BINDING = re.compile(r"^\s*bindsym\s+(?:(?:--\S+)\s+)*([^\s]+)\s+(.+?)\s*$")
MODE = re.compile(r'^\s*mode\s+(.+?)\s*\{\s*$')
INCLUDE = re.compile(r"^\s*include\s+(\S+)\s*$")
SET = re.compile(r"^\s*set\s+(\$\S+)\s+(\S+)\s*$")
MODIFIER_ALIASES = {
    "control": "ctrl", "ctrl": "ctrl", "alt": "mod1", "mod1": "mod1",
    "super": "mod4", "mod4": "mod4",
}


def check(entry: Path) -> list[str]:
    seen: dict[tuple[str, str], tuple[Path, int, str]] = {}
    errors: list[str] = []
    mode = "default"
    variables: dict[str, str] = {}

    def canonical(chord: str) -> str:
        *modifiers, symbol = chord.split("+")
        modifiers = [variables.get(modifier, modifier) for modifier in modifiers]
        modifiers = [MODIFIER_ALIASES.get(modifier.lower(), modifier.lower()) for modifier in modifiers]
        return "+".join([*sorted(modifiers), symbol])

    def read(path: Path) -> None:
        nonlocal mode
        for line_number, line in enumerate(path.read_text().splitlines(), 1):
            line = line.split("#", 1)[0].strip()
            if not line:
                continue
            include = INCLUDE.match(line)
            if include:
                include_path = Path(include.group(1))
                pattern = include_path if include_path.is_absolute() else path.parent / include_path
                matches = [Path(match) for match in sorted(glob(str(pattern)))]
                if not matches:
                    raise FileNotFoundError(pattern)
                for match in matches:
                    read(match)
                continue
            setting = SET.match(line)
            if setting:
                variables[setting.group(1)] = setting.group(2)
                continue
            match = MODE.match(line)
            if match:
                mode = match.group(1)
                continue
            if line == "}":
                mode = "default"
                continue
            binding = BINDING.match(line)
            if not binding:
                continue
            chord, command = binding.groups()
            key = (mode, canonical(chord))
            if key in seen:
                old_path, old_line, old_command = seen[key]
                old_display = old_path.relative_to(SWAY) if old_path.is_relative_to(SWAY) else old_path
                path_display = path.relative_to(SWAY) if path.is_relative_to(SWAY) else path
                errors.append(
                    f"{entry.name}: duplicate bindsym {chord} in mode {mode}: "
                    f"{old_display}:{old_line} -> {old_command}; "
                    f"{path_display}:{line_number} -> {command}"
                )
            else:
                seen[key] = path, line_number, command

    read(entry)
    return errors


errors = [error for entry in (SWAY / "config", SWAY / "config.virtualbox") for error in check(entry)]
if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print("PASS: no duplicate Sway bindsym chords within a mode (both entry points).")
