#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
manifest="$test_root/manifest.tsv"
fake_bin="$test_root/fake-bin"
output="$test_root/output"
mkdir -p "$fake_bin" "$test_root/absent-bin"
printf 'OPENAI_API_KEY\top://Vault/Item/field\n' > "$manifest"

cat > "$fake_bin/op" <<'FAKE_OP'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
    whoami)
        [[ ${FAKE_OP_MODE:-} != unauthenticated ]]
        ;;
    read)
        case "${FAKE_OP_MODE:-}" in
            missing) exit 1 ;;
            present)
                printf 'synthetic-value-that-must-not-escape\n'
                printf 'synthetic-value-that-must-not-escape\n' >&2
                ;;
            *) exit 97 ;;
        esac
        ;;
    *) exit 98 ;;
esac
FAKE_OP
chmod 0700 "$fake_bin/op"

if PATH="$test_root/absent-bin" /usr/bin/bash "$repo_dir/bin/check-secrets" "$manifest" \
    >"$output" 2>&1; then
    printf 'FAIL: missing-op check unexpectedly succeeded.\n' >&2
    exit 1
fi
grep -Fq "ERROR: 1Password CLI 'op' is not installed." "$output"
printf 'PASS: absent op has an actionable nonzero failure.\n'

if FAKE_OP_MODE=unauthenticated PATH="$fake_bin:/usr/bin:/bin" \
    "$repo_dir/bin/check-secrets" "$manifest" >"$output" 2>&1; then
    printf 'FAIL: unauthenticated check unexpectedly succeeded.\n' >&2
    exit 1
fi
grep -Fq 'AUTHENTICATION REQUIRED:' "$output"
if grep -Fq 'MISSING ' "$output"; then
    printf 'FAIL: authentication failure was mislabeled as a missing variable.\n' >&2
    exit 1
fi
printf 'PASS: unauthenticated op is distinct from an unresolved reference.\n'

if FAKE_OP_MODE=missing PATH="$fake_bin:/usr/bin:/bin" \
    "$repo_dir/bin/check-secrets" "$manifest" >"$output" 2>&1; then
    printf 'FAIL: unresolved-reference check unexpectedly succeeded.\n' >&2
    exit 1
fi
grep -Fxq 'MISSING OPENAI_API_KEY' "$output"
printf 'PASS: an unresolved reference is reported per variable and exits nonzero.\n'

FAKE_OP_MODE=present PATH="$fake_bin:/usr/bin:/bin" \
    "$repo_dir/bin/check-secrets" "$manifest" >"$output" 2>&1
if grep -Fq 'synthetic-value-that-must-not-escape' "$output"; then
    printf 'FAIL: check-secrets exposed the value returned by op.\n' >&2
    exit 1
fi
grep -Fxq 'OK OPENAI_API_KEY' "$output"
printf 'PASS: op stdout and stderr values cannot reach check-secrets output.\n'
