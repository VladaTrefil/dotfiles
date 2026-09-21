#!/usr/bin/env python3
"""A corrupt cached download must fail before creating any executable."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
spec = json.loads((root / 'provision/releases.json').read_text())['asdf']
with tempfile.TemporaryDirectory() as directory:
    home = Path(directory)
    cache = home / '.cache/dotfiles/releases'
    cache.mkdir(parents=True)
    archive = cache / (spec['sha256'] + Path(spec['url']).name)
    archive.write_bytes(b'not the release archive')
    env = dict(os.environ, HOME=str(home), XDG_CACHE_HOME=str(home / '.cache'))
    result = subprocess.run([str(root / 'bin/install-releases')], env=env, text=True, capture_output=True)
    assert result.returncode != 0 and 'SHA-256 mismatch' in result.stderr, result
    assert not list((home / '.local/bin').iterdir())
    print('PASS: corrupt release checksum fails closed before extraction or executable installation')
