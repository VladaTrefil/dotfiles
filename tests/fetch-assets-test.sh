#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
for tool in fc-cache fc-match fc-scan git python3 timeout; do
    command -v "$tool" >/dev/null 2>&1 || fail "Required test tool is missing: $tool"
done

fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
home="$fixture/home"
data="$home/.local/share"
assets="$data/dotfiles-assets"
mkdir -p "$assets/fonts/monolisa" "$assets/fonts/fontawesome-pro" "$assets/wallpapers"

fixture_font=$(fc-match -f '%{file}\n' sans-serif | sed -n '1p')
[[ -f $fixture_font ]] || fail 'fontconfig did not resolve a fixture font'
cp -- "$fixture_font" "$assets/fonts/monolisa/Fixture-Regular.ttf"
cp -- "$fixture_font" "$assets/fonts/fontawesome-pro/Fixture-Awesome.ttf"
printf 'fixture wallpaper\n' > "$assets/wallpapers/fixture.jpg"

run_assets() {
    env HOME="$home" XDG_DATA_HOME="$data" XDG_CACHE_HOME="$home/.cache" \
        "$repo_dir/bin/fetch-assets" "$@"
}

run_assets --help | grep -q '^Usage: bin/fetch-assets'
run_assets --offline
[[ -L $data/fonts/dotfiles-assets ]] || fail 'Font link was not created'
[[ $(readlink -f -- "$data/fonts/dotfiles-assets") == "$assets/fonts" ]] ||
    fail 'Font link points to the wrong directory'
[[ -L $home/.background ]] || fail 'Wallpaper link was not created'
[[ $(readlink -f -- "$home/.background") == "$assets/wallpapers" ]] ||
    fail 'Wallpaper link points to the wrong directory'
family=$(fc-scan -f '%{family}\n' "$data/fonts/dotfiles-assets/monolisa/Fixture-Regular.ttf" |
    sed -n '1p')
[[ -n $family ]] || fail 'Linked fixture font is not readable by fontconfig'

python3 - "$data/fonts/dotfiles-assets" "$home/.background" > "$fixture/before" <<'PY'
import os
import sys
for name in sys.argv[1:]:
    stat = os.lstat(name)
    print(name, stat.st_ino, stat.st_mode, stat.st_mtime_ns, os.readlink(name))
PY
run_assets --offline
python3 - "$data/fonts/dotfiles-assets" "$home/.background" > "$fixture/after" <<'PY'
import os
import sys
for name in sys.argv[1:]:
    stat = os.lstat(name)
    print(name, stat.st_ino, stat.st_mode, stat.st_mtime_ns, os.readlink(name))
PY
cmp -s "$fixture/before" "$fixture/after" || fail 'Second run changed managed links'
printf 'PASS: offline linking and font cache refresh are idempotent.\n'

missing_home="$fixture/missing-home"
mkdir -p "$missing_home"
set +e
timeout --kill-after=2s 10s env HOME="$missing_home" \
    XDG_DATA_HOME="$missing_home/.local/share" XDG_CACHE_HOME="$missing_home/.cache" \
    DOTFILES_ASSETS_REPO_URL='ssh://git@127.0.0.1:1/private-assets.git' \
    "$repo_dir/bin/fetch-assets" > "$fixture/missing.log" 2>&1
status=$?
set -e
cat "$fixture/missing.log"
((status != 0 && status != 124 && status != 137)) ||
    fail 'Missing credentials did not fail promptly'
grep -q 'could not access the private assets repository' "$fixture/missing.log" ||
    fail 'Missing credentials lacked the primary explanation'
grep -q 'Configure a GitHub SSH key' "$fixture/missing.log" ||
    fail 'Missing credentials lacked actionable SSH guidance'
printf 'PASS: inaccessible private remote fails promptly with actionable guidance.\n'
