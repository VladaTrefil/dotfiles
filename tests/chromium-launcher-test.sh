#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

wrapper="$repo_dir/local/bin/chromium-browser"
desktop="$repo_dir/local/applications/chromium-browser.desktop"

[[ -x $wrapper ]] || fail 'Managed Chromium wrapper is missing or not executable'
[[ -f $desktop ]] || fail 'Managed Chromium desktop override is missing'

for tool in bwrap desktop-file-validate; do
  command -v "$tool" >/dev/null || fail "Required test tool is missing: $tool"
done

fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
cp -- "$wrapper" "$fixture/chromium-browser-wrapper"
fake_chromium="$fixture/chromium-browser"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf '\''<%s>\n'\'' "$@"' >"$fake_chromium"
chmod +x "$fake_chromium"

sandbox=(bwrap --die-with-parent --dir /tmp)
for runtime in /usr /bin /lib /lib64; do
  if [[ -d $runtime ]]; then
    sandbox+=(--ro-bind "$runtime" "$runtime")
  fi
done
sandbox+=(--dev /dev --bind "$fixture" "$fixture"
  --ro-bind "$fake_chromium" /usr/lib64/chromium-browser/chromium-browser.sh
  --setenv PATH /usr/bin:/bin --)

trace=$("${sandbox[@]}" bash -x "$fixture/chromium-browser-wrapper" \
  --path-probe 2>&1 >/dev/null)
[[ $trace == *'+ exec /usr/bin/chromium-browser --ozone-platform=x11 --path-probe'* ]] ||
  fail 'Chromium wrapper does not call the stable /usr/bin entry point'

actual=$("${sandbox[@]}" "$fixture/chromium-browser-wrapper" \
  'https://example.invalid/path with spaces' --incognito)
expected=$'<--ozone-platform=x11>\n<https://example.invalid/path with spaces>\n<--incognito>'
[[ $actual == "$expected" ]] || {
  printf 'Expected wrapper arguments:\n%s\nActual wrapper arguments:\n%s\n' \
    "$expected" "$actual" >&2
  fail 'Chromium wrapper did not select XWayland before forwarding arguments'
}

desktop-file-validate "$desktop"
mapfile -t exec_lines < <(awk -F= '$1 == "Exec" { print $2 }' "$desktop")
expected_exec=(
  'chromium-browser %U'
  'chromium-browser %U'
  'chromium-browser --incognito %U'
)
[[ ${exec_lines[*]} == "${expected_exec[*]}" ]] ||
  fail 'Chromium desktop actions do not consistently use the managed wrapper'

printf 'PASS: Chromium launches through XWayland and preserves forwarded arguments.\n'
