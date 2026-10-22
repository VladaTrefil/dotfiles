#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
test_home="$fixture/home"
manifest="$fixture/eww-x11.json"
fake_bin="$fixture/bin"
mkdir -p "$test_home" "$fake_bin" "$fixture/source"
touch "$fixture/source/Cargo.toml" "$fixture/source/Cargo.lock"
tar -czf "$fixture/source.tar.gz" -C "$fixture" source
checksum=$(sha256sum "$fixture/source.tar.gz")
checksum=${checksum%% *}
cat >"$manifest" <<JSON
{
  "version": "test-revision",
  "url": "https://example.invalid/eww-test.tar.gz",
  "sha256": "$checksum"
}
JSON

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}
run_installer() {
  env HOME="$test_home" XDG_CACHE_HOME="$test_home/.cache" \
    XDG_STATE_HOME="$test_home/.local/state" PATH="$fake_bin:/usr/bin:/bin" \
    DOTFILES_EWW_X11_MANIFEST="$manifest" TEST_BUILD_LOG="$fixture/build.log" \
    TEST_REPLACE_TARGET="${test_replace_target:-}" \
    "$repo_dir/bin/install-eww-x11" "$@"
}

output=$(run_installer --dry-run)
[[ $output == *test-revision* && $output == *--features\ x11* ]] ||
  fail 'dry-run omitted the source pin or X11 build option'
[[ ! -e $test_home/.cache && ! -e $test_home/.local ]] ||
  fail 'dry-run wrote to the test home'
printf 'PASS: Eww X11 dry-run reports the build without writing.\n'

if printf 'no\n' | run_installer >"$fixture/cancel.log" 2>&1; then
  fail 'installation proceeded without confirmation'
fi
[[ ! -e $test_home/.cache && ! -e $test_home/.local ]] ||
  fail 'cancelled installation wrote to the test home'
printf 'PASS: cancellation has no installation side effects.\n'

# Replace only the external compiler and development-library check. Extraction,
# checksum checks, executable installation and ownership checks remain real.
cat >"$fake_bin/cargo" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
[[ "$*" == 'build --release --locked --no-default-features --features x11 --package eww --offline' ]]
[[ -f Cargo.toml && -f Cargo.lock ]]
printf 'build\n' >>"$TEST_BUILD_LOG"
mkdir -p "$CARGO_TARGET_DIR/release"
printf '#!/bin/sh\nprintf "eww X11 fixture\\n"\n' >"$CARGO_TARGET_DIR/release/eww"
chmod +x "$CARGO_TARGET_DIR/release/eww"
if [[ -n $TEST_REPLACE_TARGET ]]; then
  mkdir -p "$(dirname -- "$TEST_REPLACE_TARGET")"
  printf 'concurrent executable\n' >"$TEST_REPLACE_TARGET"
fi
SH
cat >"$fake_bin/pkg-config" <<'SH'
#!/usr/bin/env bash
[[ "$*" == '--exists gtk+-3.0 gdk-x11-3.0 dbusmenu-gtk3-0.4' ]]
SH
chmod +x "$fake_bin/cargo" "$fake_bin/pkg-config"

cache="$test_home/.cache/dotfiles/eww-x11"
mkdir -p "$cache"
cp "$fixture/source.tar.gz" "$cache/source-$checksum.tar.gz"
printf 'yes\n' | run_installer --offline
[[ $("$test_home/.local/bin/eww-x11" --version) == 'eww X11 fixture' ]] ||
  fail 'the built executable was not installed'
printf 'yes\n' | run_installer --offline
[[ $(wc -l <"$fixture/build.log") -eq 1 ]] ||
  fail 'an unchanged managed build was compiled again'
printf 'PASS: verified offline build installs once and is idempotent.\n'

printf 'unmanaged\n' >"$test_home/.local/bin/eww-x11"
if printf 'yes\n' | run_installer --offline >"$fixture/unmanaged.log" 2>&1; then
  fail 'installation replaced a modified executable'
fi
[[ $(cat "$test_home/.local/bin/eww-x11") == unmanaged ]] ||
  fail 'the modified executable was changed'
grep -q 'Refusing to replace' "$fixture/unmanaged.log" ||
  fail 'modified executable refusal was not actionable'
printf 'PASS: modified executables are preserved.\n'

test_home="$fixture/concurrent-home"
cache="$test_home/.cache/dotfiles/eww-x11"
mkdir -p "$cache"
cp "$fixture/source.tar.gz" "$cache/source-$checksum.tar.gz"
test_replace_target="$test_home/.local/bin/eww-x11"
if printf 'yes\n' | run_installer --offline >"$fixture/concurrent.log" 2>&1; then
  fail 'installation overwrote an executable created during compilation'
fi
[[ $(cat "$test_replace_target") == 'concurrent executable' ]] ||
  fail 'the executable created during compilation was changed'
test_replace_target=''
printf 'PASS: executables created during compilation are preserved.\n'

test_home="$fixture/corrupt-home"
cache="$test_home/.cache/dotfiles/eww-x11"
mkdir -p "$cache"
printf 'corrupt\n' >"$cache/source-$checksum.tar.gz"
if printf 'yes\n' | run_installer --offline >"$fixture/checksum.log" 2>&1; then
  fail 'installation accepted a corrupt source archive'
fi
grep -q 'SHA-256 mismatch' "$fixture/checksum.log" ||
  fail 'corrupt source failure was not actionable'
[[ ! -e $test_home/.local/bin/eww-x11 ]] ||
  fail 'a corrupt source archive produced an installation'
[[ $(wc -l <"$fixture/build.log") -eq 2 ]] ||
  fail 'the compiler ran for a corrupt source archive'
printf 'PASS: corrupt source archives fail before compilation.\n'
