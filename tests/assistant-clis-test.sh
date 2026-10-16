#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
home="$fixture/home"
manifest="$fixture/assistant-clis.json"
mkdir -p "$home"

cat > "$manifest" <<'JSON'
{
  "claude": {
    "version": "2.1.301",
    "installer_url": "https://claude.ai/install.sh",
    "installer_sha256": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "installer_size": 17
  },
  "codex": {
    "version": "0.163.0",
    "installer_url": "https://chatgpt.com/codex/install.sh",
    "installer_sha256": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    "installer_size": 18
  }
}
JSON

output=$(env HOME="$home" XDG_CACHE_HOME="$home/.cache" \
    DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    "$repo_dir/bin/install-assistant-clis" --dry-run)

grep -Fq 'Claude CLI 2.1.301' <<< "$output" || fail 'dry-run omitted the Claude pin'
grep -Fq 'Codex CLI 0.163.0' <<< "$output" || fail 'dry-run omitted the Codex pin'
[[ ! -e $home/.cache ]] || fail 'dry-run wrote to the cache'
printf 'PASS: dry-run reports both pins without writing.\n'

dispatch_output=$(env HOME="$home" XDG_CACHE_HOME="$home/.cache" \
    DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    "$repo_dir/install" assistants --dry-run)
grep -Fq 'Claude CLI 2.1.301' <<< "$dispatch_output" ||
    fail 'root installer did not delegate the assistants phase'
grep -Fq 'Codex CLI 0.163.0' <<< "$dispatch_output" ||
    fail 'root installer omitted the Codex assistants plan'
[[ ! -e $home/.cache ]] || fail 'root installer dry-run wrote to the cache'
printf 'PASS: root installer exposes a side-effect-free assistants phase.\n'

production_output=$(env HOME="$home" XDG_CACHE_HOME="$home/.cache" \
    "$repo_dir/install" assistants --dry-run)
grep -Fq 'Claude CLI 2.1.301' <<< "$production_output" ||
    fail 'production manifest omitted the approved Claude pin'
grep -Fq 'Codex CLI 0.163.0' <<< "$production_output" ||
    fail 'production manifest omitted the approved Codex pin'
printf 'PASS: production manifest exposes the approved release pins.\n'

grep -Fxq 'DISABLE_AUTOUPDATER=1' \
    "$repo_dir/config/environment.d/50-desktop.conf" ||
    fail 'Claude auto-updates are not disabled for the pinned installation'
printf 'PASS: Claude self-updates cannot drift from the provisioned pin.\n'

fake_bin="$fixture/fake-bin"
installer_sources="$fixture/installer-sources"
curl_log="$fixture/curl.log"
install_log="$fixture/install.log"
mkdir -p "$fake_bin" "$installer_sources"

cat > "$installer_sources/claude-install.sh" <<'SH'
#!/bin/sh
printf 'claude args=%s\n' "$*" >> "$TEST_INSTALL_LOG"
SH
cat > "$installer_sources/codex-install.sh" <<'SH'
#!/bin/sh
printf 'codex args=%s non_interactive=%s install_dir=%s\n' \
    "$*" "${CODEX_NON_INTERACTIVE-}" "${CODEX_INSTALL_DIR-}" >> "$TEST_INSTALL_LOG"
SH
chmod +x "$installer_sources"/*.sh

python3 - "$manifest" "$installer_sources" <<'PY'
import hashlib
import json
from pathlib import Path
import sys

manifest = Path(sys.argv[1])
sources = Path(sys.argv[2])
releases = {}
for name, version, url in (
    ("claude", "2.1.301", "https://claude.ai/install.sh"),
    ("codex", "0.163.0", "https://chatgpt.com/codex/install.sh"),
):
    source = sources / f"{name}-install.sh"
    contents = source.read_bytes()
    releases[name] = {
        "version": version,
        "installer_url": url,
        "installer_sha256": hashlib.sha256(contents).hexdigest(),
        "installer_size": len(contents),
    }
manifest.write_text(json.dumps(releases), encoding="utf-8")
PY

cat > "$fake_bin/curl" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$TEST_CURL_LOG"
if [[ ${TEST_CURL_FAIL:-no} == yes ]]; then
    exit 22
fi
output=''
previous=''
for argument in "$@"; do
    if [[ $previous == output ]]; then
        output=$argument
        previous=''
    elif [[ $argument == --output ]]; then
        previous=output
    fi
done
[[ -n $output ]] || exit 91
url=${!#}
case "$url" in
    https://claude.ai/install.sh) source=$TEST_CLAUDE_INSTALLER ;;
    https://chatgpt.com/codex/install.sh) source=$TEST_CODEX_INSTALLER ;;
    *) exit 92 ;;
esac
cp -- "$source" "$output"
SH
chmod +x "$fake_bin/curl"

insecure_manifest="$fixture/insecure-manifest.json"
python3 - "$manifest" "$insecure_manifest" <<'PY'
import json
from pathlib import Path
import sys

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
manifest["claude"]["installer_url"] = "http://claude.ai/install.sh"
Path(sys.argv[2]).write_text(json.dumps(manifest), encoding="utf-8")
PY
insecure_home="$fixture/insecure-home"
insecure_output="$fixture/insecure-output"
mkdir -p "$insecure_home"
if printf 'yes\n' | env HOME="$insecure_home" XDG_CACHE_HOME="$insecure_home/.cache" \
    PATH="$fake_bin:/usr/bin:/bin" DOTFILES_ASSISTANT_CLI_MANIFEST="$insecure_manifest" \
    TEST_CURL_LOG="$fixture/insecure-curl.log" TEST_INSTALL_LOG="$fixture/insecure-install.log" \
    TEST_CLAUDE_INSTALLER="$installer_sources/claude-install.sh" \
    TEST_CODEX_INSTALLER="$installer_sources/codex-install.sh" \
    "$repo_dir/bin/install-assistant-clis" > "$insecure_output" 2>&1; then
    fail 'assistant installer accepted an unapproved bootstrap URL'
fi
grep -Fq 'claude: installer_url must be https://claude.ai/install.sh' "$insecure_output" ||
    fail 'unapproved bootstrap URL failure was not actionable'
[[ ! -e $insecure_home/.cache ]] || fail 'invalid manifest wrote to the cache'
[[ ! -e $fixture/insecure-curl.log ]] || fail 'invalid manifest invoked curl'
printf 'PASS: unapproved bootstrap URLs fail before any side effect.\n'

download_home="$fixture/download-failure-home"
download_output="$fixture/download-failure-output"
mkdir -p "$download_home"
if printf 'yes\n' | env HOME="$download_home" XDG_CACHE_HOME="$download_home/.cache" \
    PATH="$fake_bin:/usr/bin:/bin" DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    TEST_CURL_FAIL=yes TEST_CURL_LOG="$fixture/download-failure-curl.log" \
    TEST_INSTALL_LOG="$fixture/download-failure-install.log" \
    TEST_CLAUDE_INSTALLER="$installer_sources/claude-install.sh" \
    TEST_CODEX_INSTALLER="$installer_sources/codex-install.sh" \
    "$repo_dir/bin/install-assistant-clis" > "$download_output" 2>&1; then
    fail 'assistant installer accepted a failed bootstrap download'
fi
grep -Fq 'claude: installer download failed (exit 22); nothing installed' \
    "$download_output" || fail 'download failure was not actionable'
if grep -Fq 'Traceback' "$download_output"; then
    fail 'download failure exposed a Python traceback'
fi
[[ ! -e $fixture/download-failure-install.log ]] ||
    fail 'an installer ran after a failed bootstrap download'
printf 'PASS: download failure is concise and has no installation side effect.\n'

sudo_home="$fixture/sudo-home"
sudo_output="$fixture/sudo-output"
mkdir -p "$sudo_home"
if printf 'yes\n' | env HOME="$sudo_home" XDG_CACHE_HOME="$sudo_home/.cache" \
    SUDO_USER=vlada PATH="$fake_bin:/usr/bin:/bin" \
    DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    TEST_CURL_LOG="$fixture/sudo-curl.log" TEST_INSTALL_LOG="$fixture/sudo-install.log" \
    TEST_CLAUDE_INSTALLER="$installer_sources/claude-install.sh" \
    TEST_CODEX_INSTALLER="$installer_sources/codex-install.sh" \
    "$repo_dir/bin/install-assistant-clis" > "$sudo_output" 2>&1; then
    fail 'assistant installer accepted sudo/root execution'
fi
grep -Fq 'Do not run the assistants installer as root or with sudo.' "$sudo_output" ||
    fail 'sudo/root refusal was not actionable'
[[ ! -e $sudo_home/.cache ]] || fail 'sudo/root refusal wrote to the cache'
printf 'PASS: sudo/root execution is refused before any installer side effect.\n'

refusal_home="$fixture/refusal-home"
refusal_output="$fixture/refusal-output"
mkdir -p "$refusal_home"
if printf 'no\n' | env HOME="$refusal_home" XDG_CACHE_HOME="$refusal_home/.cache" \
    PATH="$fake_bin:/usr/bin:/bin" DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    TEST_CURL_LOG="$fixture/refusal-curl.log" TEST_INSTALL_LOG="$fixture/refusal-install.log" \
    TEST_CLAUDE_INSTALLER="$installer_sources/claude-install.sh" \
    TEST_CODEX_INSTALLER="$installer_sources/codex-install.sh" \
    "$repo_dir/bin/install-assistant-clis" > "$refusal_output" 2>&1; then
    fail 'assistant installer accepted anything other than exact yes'
fi
grep -Fq 'Aborted.' "$refusal_output" || fail 'confirmation refusal was not reported'
[[ ! -e $refusal_home/.cache ]] || fail 'confirmation refusal wrote to the cache'
[[ ! -e $fixture/refusal-curl.log ]] || fail 'confirmation refusal invoked curl'
[[ ! -e $fixture/refusal-install.log ]] || fail 'confirmation refusal invoked an installer'
printf 'PASS: confirmation refusal has no download or installation side effect.\n'

corrupt_codex="$installer_sources/codex-install-corrupt.sh"
cp -- "$installer_sources/codex-install.sh" "$corrupt_codex"
printf 'X' | dd of="$corrupt_codex" bs=1 seek=10 conv=notrunc status=none
corrupt_home="$fixture/corrupt-home"
corrupt_output="$fixture/corrupt-output"
mkdir -p "$corrupt_home"
if printf 'yes\n' | env HOME="$corrupt_home" XDG_CACHE_HOME="$corrupt_home/.cache" \
    PATH="$fake_bin:/usr/bin:/bin" DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    TEST_CURL_LOG="$fixture/corrupt-curl.log" TEST_INSTALL_LOG="$fixture/corrupt-install.log" \
    TEST_CLAUDE_INSTALLER="$installer_sources/claude-install.sh" \
    TEST_CODEX_INSTALLER="$corrupt_codex" \
    "$repo_dir/bin/install-assistant-clis" > "$corrupt_output" 2>&1; then
    fail 'assistant installer accepted a corrupt Codex bootstrap'
fi
grep -Fq 'codex: installer SHA-256 mismatch; nothing installed' "$corrupt_output" ||
    fail 'corrupt bootstrap failure was not actionable'
[[ ! -e $fixture/corrupt-install.log ]] ||
    fail 'an installer ran before both bootstrap checks passed'
printf 'PASS: corruption of either bootstrap stops both installations.\n'

printf 'yes\n' | env HOME="$home" XDG_CACHE_HOME="$home/.cache" \
    PATH="$fake_bin:/usr/bin:/bin" DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    TEST_CURL_LOG="$curl_log" TEST_INSTALL_LOG="$install_log" \
    TEST_CLAUDE_INSTALLER="$installer_sources/claude-install.sh" \
    TEST_CODEX_INSTALLER="$installer_sources/codex-install.sh" \
    "$repo_dir/bin/install-assistant-clis"

grep -Fxq 'claude args=2.1.301' "$install_log" ||
    fail 'Claude installer did not receive the exact version'
grep -Fxq "codex args=--release 0.163.0 non_interactive=1 install_dir=$home/.local/bin" \
    "$install_log" || fail 'Codex installer did not receive the pinned non-interactive contract'
[[ $(wc -l < "$curl_log") -eq 2 ]] || fail 'install did not download exactly two installers'
printf 'PASS: confirmed install executes both verified, version-pinned installers.\n'

printf 'yes\n' | env HOME="$home" XDG_CACHE_HOME="$home/.cache" \
    PATH="$fake_bin:/usr/bin:/bin" DOTFILES_ASSISTANT_CLI_MANIFEST="$manifest" \
    TEST_CURL_LOG="$curl_log" TEST_INSTALL_LOG="$install_log" \
    TEST_CLAUDE_INSTALLER="$installer_sources/claude-install.sh" \
    TEST_CODEX_INSTALLER="$installer_sources/codex-install.sh" \
    "$repo_dir/bin/install-assistant-clis" --offline

[[ $(wc -l < "$curl_log") -eq 2 ]] || fail 'offline cache reuse invoked curl'
[[ $(grep -Fc 'claude args=2.1.301' "$install_log") -eq 2 ]] ||
    fail 'offline cache reuse did not run the verified Claude installer'
[[ $(grep -Fc 'codex args=--release 0.163.0' "$install_log") -eq 2 ]] ||
    fail 'offline cache reuse did not run the verified Codex installer'
printf 'PASS: offline mode reuses only the verified installer cache.\n'
