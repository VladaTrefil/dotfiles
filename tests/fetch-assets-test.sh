#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
for tool in fc-cache fc-list fc-scan git python3 timeout; do
    command -v "$tool" >/dev/null 2>&1 || fail "Required test tool is missing: $tool"
done

fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
test_repo="$fixture/repo"
mkdir -p "$test_repo/bin" "$test_repo/provision"
cp -- "$repo_dir/bin/fetch-assets" "$repo_dir/bin/install-releases" "$test_repo/bin/"
chmod +x "$test_repo/bin/fetch-assets" "$test_repo/bin/install-releases"

mapfile -t fixture_fonts < <(fc-list -f '%{file}\n' | sort -u | sed -n '1,2p')
[[ ${#fixture_fonts[@]} -eq 2 && -f ${fixture_fonts[0]} && -f ${fixture_fonts[1]} ]] ||
    fail 'fontconfig did not resolve two fixture fonts'
release_cache="$fixture/release-cache"
mkdir -p "$release_cache"
python3 - "$test_repo/provision/releases.json" "$release_cache" \
    "${fixture_fonts[@]}" <<'PY'
import hashlib
import json
from pathlib import Path
import sys
import tarfile

manifest = Path(sys.argv[1])
cache = Path(sys.argv[2])
fixture_fonts = [Path(name) for name in sys.argv[3:]]
definitions = {
    'iosevka-nerd-font': [
        'IosevkaNerdFont-Regular.ttf',
        'IosevkaNerdFont-Bold.ttf',
        'IosevkaNerdFont-Italic.ttf',
    ],
    'meslolgs-nerd-font': [
        'MesloLGSNerdFont-Regular.ttf',
        'MesloLGSNerdFont-Bold.ttf',
        'MesloLGSNerdFont-Italic.ttf',
    ],
}
releases = {}
for fixture_number, (name, members) in enumerate(definitions.items()):
    archive = cache / (name + '.tar.xz')
    with tarfile.open(archive, 'w:xz') as package:
        for member in members:
            package.add(fixture_fonts[fixture_number], arcname=member)
    checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
    url = f'https://example.invalid/{archive.name}'
    releases[name] = {
        'kind': 'font', 'version': 'fixture', 'url': url,
        'sha256': checksum, 'members': members,
    }
    archive.replace(cache / (checksum + archive.name))
manifest.write_text(json.dumps(releases))
PY

seed_release_cache() {
    local target="$1/.cache/dotfiles/releases"
    mkdir -p "$target"
    cp -- "$release_cache"/* "$target/"
}

home="$fixture/home"
data="$home/.local/share"
assets="$data/dotfiles-assets"
mkdir -p "$assets/fonts/monolisa" "$assets/fonts/fontawesome-pro" "$assets/wallpapers"
cp -- "${fixture_fonts[0]}" "$assets/fonts/monolisa/Fixture-Regular.ttf"
cp -- "${fixture_fonts[0]}" "$assets/fonts/fontawesome-pro/Fixture-Awesome.ttf"
printf 'fixture wallpaper\n' > "$assets/wallpapers/fixture.jpg"
seed_release_cache "$home"

run_assets() {
    env HOME="$home" XDG_DATA_HOME="$data" XDG_CACHE_HOME="$home/.cache" \
        "$test_repo/bin/fetch-assets" "$@"
}

run_assets --help | grep -q '^Usage: bin/fetch-assets'
run_assets --offline
public_fonts="$data/fonts/dotfiles-releases"
[[ $(find "$public_fonts" -type f -name '*.ttf' | wc -l) -eq 6 ]] ||
    fail 'The six selected public font faces were not installed'
[[ -L $data/fonts/dotfiles-assets ]] || fail 'Private font link was not created'
[[ $(readlink -f -- "$data/fonts/dotfiles-assets") == "$assets/fonts" ]] ||
    fail 'Private font link points to the wrong directory'
[[ -L $home/.background ]] || fail 'Wallpaper link was not created'
[[ $(readlink -f -- "$home/.background") == "$assets/wallpapers" ]] ||
    fail 'Wallpaper link points to the wrong directory'
family=$(fc-scan -f '%{family}\n' "$data/fonts/dotfiles-assets/monolisa/Fixture-Regular.ttf" |
    sed -n '1p')
[[ -n $family ]] || fail 'Linked fixture font is not readable by fontconfig'
env HOME="$home" XDG_DATA_HOME="$data" XDG_CACHE_HOME="$home/.cache" \
    fc-list -f '%{file}\n' > "$fixture/font-list"
for release in iosevka-nerd-font meslolgs-nerd-font; do
    grep -Fq "$public_fonts/$release/" "$fixture/font-list" ||
        fail "$release is absent from fc-list"
done
while IFS= read -r font; do
    [[ -n $(fc-scan -f '%{family}\n' "$font") ]] || fail "$font is not readable by fontconfig"
done < <(find "$public_fonts" -type f -name '*.ttf' | sort)

python3 - "$public_fonts" "$data/fonts/dotfiles-assets" "$home/.background" \
    > "$fixture/before" <<'PY'
import hashlib
import os
from pathlib import Path
import sys

for name in sys.argv[1:]:
    root = Path(name)
    paths = [root]
    if root.is_dir() and not root.is_symlink():
        paths.extend(sorted(root.rglob('*')))
    for path in paths:
        stat = path.lstat()
        digest = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else '-'
        target = os.readlink(path) if path.is_symlink() else '-'
        print(path, stat.st_ino, stat.st_mode, stat.st_size, stat.st_mtime_ns, digest, target)
PY
run_assets --offline
python3 - "$public_fonts" "$data/fonts/dotfiles-assets" "$home/.background" \
    > "$fixture/after" <<'PY'
import hashlib
import os
from pathlib import Path
import sys

for name in sys.argv[1:]:
    root = Path(name)
    paths = [root]
    if root.is_dir() and not root.is_symlink():
        paths.extend(sorted(root.rglob('*')))
    for path in paths:
        stat = path.lstat()
        digest = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else '-'
        target = os.readlink(path) if path.is_symlink() else '-'
        print(path, stat.st_ino, stat.st_mode, stat.st_size, stat.st_mtime_ns, digest, target)
PY
cmp -s "$fixture/before" "$fixture/after" || fail 'Second run changed managed fonts or links'
printf 'PASS: public fonts, private linking, cache refresh, and a second run are idempotent.\n'

offline_home="$fixture/offline-no-private"
seed_release_cache "$offline_home"
env HOME="$offline_home" XDG_DATA_HOME="$offline_home/.local/share" \
    XDG_CACHE_HOME="$offline_home/.cache" "$test_repo/bin/fetch-assets" --offline \
    > "$fixture/offline-no-private.log" 2>&1 || {
        cat "$fixture/offline-no-private.log"
        fail 'Offline public font install failed without private assets'
    }
grep -q 'optional private asset directory is absent' "$fixture/offline-no-private.log" ||
    fail 'Offline missing-private warning is absent'
[[ $(find "$offline_home/.local/share/fonts/dotfiles-releases" -type f -name '*.ttf' | wc -l) -eq 6 ]] ||
    fail 'Offline public font install is incomplete without private assets'
printf 'PASS: offline mode installs cached public fonts without a private checkout.\n'

missing_home="$fixture/missing-home"
seed_release_cache "$missing_home"
set +e
timeout --kill-after=2s 10s env HOME="$missing_home" \
    XDG_DATA_HOME="$missing_home/.local/share" XDG_CACHE_HOME="$missing_home/.cache" \
    DOTFILES_ASSETS_REPO_URL='ssh://git@127.0.0.1:1/private-assets.git' \
    "$test_repo/bin/fetch-assets" > "$fixture/missing.log" 2>&1
status=$?
set -e
cat "$fixture/missing.log"
((status == 0)) || fail "Missing private credentials prevented public installation (exit $status)"
grep -q 'could not access the private assets repository' "$fixture/missing.log" ||
    fail 'Missing credentials lacked the primary explanation'
grep -q 'Configure a GitHub SSH key' "$fixture/missing.log" ||
    fail 'Missing credentials lacked actionable SSH guidance'
[[ $(find "$missing_home/.local/share/fonts/dotfiles-releases" -type f -name '*.ttf' | wc -l) -eq 6 ]] ||
    fail 'Public fonts are incomplete after the private remote failed'
printf 'PASS: inaccessible private remote is prompt, actionable, and does not block public fonts.\n'
