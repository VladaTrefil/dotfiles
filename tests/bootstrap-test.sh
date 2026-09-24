#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
bootstrap="$repo_dir/bootstrap"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

[[ -x $bootstrap ]] || fail 'bootstrap is missing or not executable'

fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT

write_executable() {
    local path=$1
    shift
    printf '%s\n' "$@" > "$path"
    chmod +x "$path"
}

make_fakes() {
    local fake_bin=$1
    mkdir -p "$fake_bin"

    # These variables expand when each generated fake runs, not while it is written.
    # shellcheck disable=SC2016
    write_executable "$fake_bin/ip" \
        '#!/bin/sh' \
        'if [ "${1-}" = route ] && [ "${2-}" = show ] && [ "${3-}" = default ]; then' \
        '    if [ -e "$TEST_STATE/route-up" ]; then' \
        "        printf '%s\\n' 'default via 192.0.2.1 dev eth0'" \
        '    fi' \
        '    exit 0' \
        'fi' \
        'exit 2'

    # shellcheck disable=SC2016
    write_executable "$fake_bin/ssh" \
        '#!/bin/sh' \
        'printf "%s\n" "$*" >> "$TEST_STATE/ssh.log"' \
        'if [ "${TEST_SSH_AUTHENTICATED:-yes}" = yes ]; then' \
        "    printf '%s\\n' 'Hi VladaTrefil! You have successfully authenticated, but GitHub does not provide shell access.' >&2" \
        '    exit 1' \
        'fi' \
        "printf '%s\\n' 'git@github.com: Permission denied (publickey).' >&2" \
        'exit 255'

    # shellcheck disable=SC2016
    write_executable "$fake_bin/curl" \
        '#!/bin/sh' \
        'printf "%s\n" "$*" >> "$TEST_STATE/curl.log"' \
        'if [ "${TEST_GITHUB_META_FETCH:-ok}" = fail ]; then' \
        "    printf '%s\\n' 'curl: (22) requested URL returned error' >&2" \
        '    exit 22' \
        'fi' \
        'if [ "${TEST_GITHUB_META_FETCH:-ok}" = malformed ]; then' \
        "    printf '%s\\n' '{\"ssh_keys\":\"not an array\"}'" \
        '    exit 0' \
        'fi' \
        "printf '%s\\n' '{\"ssh_keys\":[\"ssh-ed25519 QUFBQUZJWFRVUkU=\",\"ssh-rsa QkJCQkZJWFRVUkU=\"]}'"

    # shellcheck disable=SC2016
    write_executable "$fake_bin/git" \
        '#!/bin/sh' \
        'printf "%s\n" "$*" >> "$TEST_LOG"' \
        'case "${1-}" in' \
        '    clone)' \
        '        for target do :; done' \
        '        mkdir -p "$target"' \
        '        : > "$target/.fixture-git"' \
        '        ;;' \
        '    -C)' \
        '        target=$2' \
        '        [ -e "$target/.fixture-git" ] || exit 128' \
        '        ;;' \
        'esac'
}

make_home() {
    local home=$1
    mkdir -p "$home/.ssh" "$home/Development/dotfiles"
    printf '%s\n' 'fixture private key' > "$home/.ssh/id_ed25519"
    printf '%s\n' 'ssh-ed25519 AAAAFIXTURE bootstrap@test' > "$home/.ssh/id_ed25519.pub"
    : > "$home/Development/dotfiles/.fixture-git"
}

mark_route_up() {
    local state=$1
    mkdir -p "$state"
    : > "$state/route-up"
}

run_bootstrap() {
    local home=$1 fake_bin=$2 state=$3 log=$4 output=$5 input=''
    if (($# >= 6)); then
        input=$6
        shift 6
    else
        shift 5
    fi
    set +e
    env HOME="$home" PATH="$fake_bin${TEST_SYSTEM_PATH:+:$TEST_SYSTEM_PATH}" \
        TEST_STATE="$state" TEST_LOG="$log" \
        DOTFILES_REPO_DIR="$home/Development/dotfiles" "$@" \
        /bin/bash "$bootstrap" > "$output" 2>&1 <<< "$input"
    run_status=$?
    set -e
}

run_bootstrap_with_closed_stdin() {
    local home=$1 fake_bin=$2 state=$3 log=$4 output=$5
    shift 5
    set +e
    env HOME="$home" PATH="$fake_bin${TEST_SYSTEM_PATH:+:$TEST_SYSTEM_PATH}" \
        TEST_STATE="$state" TEST_LOG="$log" \
        DOTFILES_REPO_DIR="$home/Development/dotfiles" "$@" \
        /bin/bash "$bootstrap" > "$output" 2>&1 </dev/null
    run_status=$?
    set -e
}

snapshot_tree() {
    local root=$1 destination=$2
    {
        find "$root" -printf '%P|%y|%m|%s|%T@\n' | LC_ALL=C sort
        find "$root" -type f -exec sha256sum {} + | LC_ALL=C sort
    } > "$destination"
}

TEST_SYSTEM_PATH=/usr/bin:/bin

test_existing_checkout_is_idempotent() {
    local case_dir="$fixture/idempotent" home fake_bin state log first second before after
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    first="$case_dir/first.out"
    second="$case_dir/second.out"
    before="$case_dir/before"
    after="$case_dir/after"
    mkdir -p "$case_dir"
    make_fakes "$fake_bin"
    make_home "$home"
    mark_route_up "$state"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$first"
    ((run_status == 0)) || { cat "$first"; fail "first idempotence run exited $run_status"; }
    snapshot_tree "$home" "$before"
    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$second"
    ((run_status == 0)) || { cat "$second"; fail "second idempotence run exited $run_status"; }
    snapshot_tree "$home" "$after"

    cmp -s "$before" "$after" || fail 'second run changed the isolated HOME'
    [[ $(grep -c '^clone ' "$log" || true) -eq 0 ]] || fail 'existing checkout was cloned again'
    [[ $(grep -c 'submodule update --init --recursive$' "$log" || true) -eq 2 ]] ||
        fail 'submodules were not checked once per run'
    grep -q 'Network: default route detected' "$second" || fail 'existing route was not detected'
    grep -q 'SSH key: existing Ed25519 key detected' "$second" || fail 'existing key was not detected'
    grep -q 'Clone: existing checkout detected; skipping clone' "$second" ||
        fail 'existing clone was not reported as skipped'
    printf 'PASS: satisfied network/key state no-ops and an existing clone is skipped.\n'
}

test_new_clone_happens_only_once() {
    local case_dir="$fixture/clone-once" home fake_bin state log first second before after
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    first="$case_dir/first.out"
    second="$case_dir/second.out"
    before="$case_dir/before"
    after="$case_dir/after"
    mkdir -p "$home/.ssh"
    printf '%s\n' 'fixture private key' > "$home/.ssh/id_ed25519"
    printf '%s\n' 'ssh-ed25519 AAAAFIXTURE bootstrap@test' > "$home/.ssh/id_ed25519.pub"
    make_fakes "$fake_bin"
    mark_route_up "$state"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$first"
    ((run_status == 0)) || { cat "$first"; fail "initial clone run exited $run_status"; }
    snapshot_tree "$home" "$before"
    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$second"
    ((run_status == 0)) || { cat "$second"; fail "post-clone run exited $run_status"; }
    snapshot_tree "$home" "$after"

    cmp -s "$before" "$after" || fail 'post-clone run changed the isolated HOME'
    [[ $(grep -c '^clone ' "$log" || true) -eq 1 ]] || fail 'clone did not happen exactly once'
    grep -q 'git@github.com:VladaTrefil/dotfiles.git' "$log" || fail 'published repository URL was not used'
    printf 'PASS: a missing checkout is cloned once and the next run changes nothing.\n'
}

test_missing_public_key_refuses_to_continue() {
    local case_dir="$fixture/missing-public" home fake_bin state log output
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    output="$case_dir/output"
    mkdir -p "$home/.ssh"
    printf '%s\n' 'fixture private key' > "$home/.ssh/id_ed25519"
    make_fakes "$fake_bin"
    mark_route_up "$state"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$output"
    ((run_status != 0)) || fail 'missing public key was accepted'
    grep -q 'public key is missing' "$output" || fail 'missing public key error was not actionable'
    [[ ! -e $state/ssh.log ]] || fail 'SSH authentication ran after the public-key prerequisite failed'
    [[ ! -e $log ]] || fail 'Git ran after the public-key prerequisite failed'
    printf 'PASS: an incomplete SSH keypair stops before authentication or clone.\n'
}

test_missing_git_prints_root_command_and_stops() {
    local case_dir="$fixture/missing-git" home fake_bin state log output command_name
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    output="$case_dir/output"
    mkdir -p "$home/.ssh"
    printf '%s\n' 'fixture private key' > "$home/.ssh/id_ed25519"
    printf '%s\n' 'ssh-ed25519 AAAAFIXTURE bootstrap@test' > "$home/.ssh/id_ed25519.pub"
    make_fakes "$fake_bin"
    rm -- "$fake_bin/git"
    for command_name in chmod grep mkdir mktemp python3 rm tail; do
        ln -s -- "$(command -v "$command_name")" "$fake_bin/$command_name"
    done
    mark_route_up "$state"

    TEST_SYSTEM_PATH='' run_bootstrap "$home" "$fake_bin" "$state" "$log" "$output"
    ((run_status != 0)) || fail 'missing Git was accepted'
    grep -q 'dnf install -y git' "$output" || fail 'missing Git command was not printed'
    [[ ! -d $home/Development/dotfiles ]] || fail 'clone target was created without Git'
    printf 'PASS: a missing root-installed prerequisite prints a command and stops.\n'
}

test_failed_github_authentication_stops_before_git() {
    local case_dir="$fixture/auth-failure" home fake_bin state log output
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    output="$case_dir/output"
    mkdir -p "$case_dir"
    make_home "$home"
    make_fakes "$fake_bin"
    mark_route_up "$state"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$output" '' TEST_SSH_AUTHENTICATED=no
    ((run_status != 0)) || fail 'failed GitHub authentication was accepted'
    grep -q 'GitHub SSH authentication failed' "$output" || fail 'authentication failure was not explained'
    [[ ! -e $log ]] || fail 'Git ran after SSH authentication failed'
    printf 'PASS: failed GitHub authentication stops before repository access.\n'
}

test_new_key_is_printed_and_gated() {
    local case_dir="$fixture/new-key" blocked_home confirmed_home fake_bin state log blocked_output confirmed_output
    blocked_home="$case_dir/blocked-home"
    confirmed_home="$case_dir/confirmed-home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    blocked_output="$case_dir/blocked.out"
    confirmed_output="$case_dir/confirmed.out"
    mkdir -p "$case_dir"
    make_fakes "$fake_bin"
    # These variables expand in the generated ssh-keygen fake.
    # shellcheck disable=SC2016
    write_executable "$fake_bin/ssh-keygen" \
        '#!/bin/sh' \
        'while [ "$#" -gt 0 ]; do' \
        '    if [ "$1" = -f ]; then key_path=$2; shift 2; else shift; fi' \
        'done' \
        'mkdir -p "${key_path%/*}"' \
        'printf "%s\n" "fixture private key" > "$key_path"' \
        'printf "%s\n" "ssh-ed25519 AAAANEW bootstrap@test" > "$key_path.pub"' \
        'chmod 600 "$key_path"' \
        'chmod 644 "$key_path.pub"'
    mark_route_up "$state"

    run_bootstrap_with_closed_stdin \
        "$blocked_home" "$fake_bin" "$state" "$log" "$blocked_output"
    ((run_status != 0)) || fail 'new-key confirmation gate accepted closed stdin'
    grep -q 'ssh-ed25519 AAAANEW bootstrap@test' "$blocked_output" || fail 'new public key was not printed'
    grep -q 'https://github.com/settings/keys' "$blocked_output" || fail 'GitHub key settings URL was not printed'
    grep -q 'Press Enter after adding the key' "$blocked_output" || fail 'new key confirmation prompt was not printed'
    grep -q 'confirmation was not received; refusing to continue' "$blocked_output" ||
        fail 'closed stdin did not produce the confirmation refusal'
    [[ ! -e $state/ssh.log ]] || fail 'SSH authentication ran before new-key confirmation'
    [[ ! -e $log ]] || fail 'Git ran before new-key confirmation'

    run_bootstrap "$confirmed_home" "$fake_bin" "$state" "$log" "$confirmed_output" $'\n'
    ((run_status == 0)) || { cat "$confirmed_output"; fail "confirmed new-key run exited $run_status"; }
    [[ -e $state/ssh.log ]] || fail 'SSH authentication did not run after new-key confirmation'
    [[ -e $log ]] || fail 'Git did not run after key confirmation and authentication'
    printf 'PASS: a new key is shown to the user and gated before authentication.\n'
}

test_wifi_password_never_reaches_disk() {
    local case_dir="$fixture/wifi-secret" home fake_bin state log output wifi_password
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    output="$case_dir/output"
    wifi_password='correct horse battery staple'
    mkdir -p "$case_dir" "$state"
    make_home "$home"
    make_fakes "$fake_bin"
    # These variables expand in the generated nmcli fake.
    # shellcheck disable=SC2016
    write_executable "$fake_bin/nmcli" \
        '#!/bin/sh' \
        'printf "%s\n" "$*" >> "$TEST_STATE/nmcli.log"' \
        'case "$*" in' \
        '    *"device status"*) exit 0 ;;' \
        '    *"device wifi connect"*)' \
        '        IFS= read -r wifi_password' \
        '        : "${wifi_password:?password prompt was not forwarded to nmcli}"' \
        '        : > "$TEST_STATE/route-up"' \
        '        exit 0' \
        '        ;;' \
        'esac' \
        'exit 2'

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$output" \
        $'1\nCafe WiFi\ncorrect horse battery staple\n'
    ((run_status == 0)) || { cat "$output"; fail "Wi-Fi run exited $run_status"; }
    grep -q -- '--ask device wifi connect Cafe WiFi' "$state/nmcli.log" ||
        fail 'Wi-Fi connection did not delegate its password prompt to nmcli --ask'
    if grep -R -F -q -- "$wifi_password" "$case_dir"; then
        fail 'Wi-Fi password was written into the test fixture'
    fi
    printf 'PASS: the Wi-Fi password is prompted by nmcli and never written by bootstrap.\n'
}

test_github_host_key_seeding_is_idempotent() {
    local case_dir="$fixture/host-key-idempotent" home fake_bin state log first second before after
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    first="$case_dir/first.out"
    second="$case_dir/second.out"
    before="$case_dir/known-hosts.before"
    after="$case_dir/known-hosts.after"
    mkdir -p "$case_dir"
    make_home "$home"
    make_fakes "$fake_bin"
    mark_route_up "$state"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$first"
    ((run_status == 0)) || { cat "$first"; fail "initial host-key seeding run exited $run_status"; }
    [[ -f $home/.ssh/known_hosts ]] || fail 'GitHub host keys were not seeded'
    cp -- "$home/.ssh/known_hosts" "$before"
    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$second"
    ((run_status == 0)) || { cat "$second"; fail "second host-key seeding run exited $run_status"; }
    cp -- "$home/.ssh/known_hosts" "$after"

    cmp -s "$before" "$after" || fail 'second run changed known_hosts'
    [[ $(grep -Fxc 'github.com ssh-ed25519 QUFBQUZJWFRVUkU=' "$after") -eq 1 ]] ||
        fail 'Ed25519 GitHub host key was missing or duplicated'
    [[ $(grep -Fxc 'github.com ssh-rsa QkJCQkZJWFRVUkU=' "$after") -eq 1 ]] ||
        fail 'RSA GitHub host key was missing or duplicated'
    [[ $(stat -c %a "$home/.ssh") == 700 ]] || fail '.ssh permissions are not 700'
    [[ $(stat -c %a "$after") == 600 ]] || fail 'known_hosts permissions are not 600'
    grep -Fq -- "--proto =https --tlsv1.2 https://api.github.com/meta" "$state/curl.log" ||
        fail 'GitHub metadata was not fetched with the required HTTPS restrictions'
    ! grep -Eq -- '(^|[[:space:]])-k([[:space:]]|$)|--insecure' "$state/curl.log" ||
        fail 'GitHub metadata fetch disabled certificate verification'
    printf 'PASS: GitHub host-key seeding is HTTPS-only, permissioned, and idempotent.\n'
}

test_existing_known_hosts_is_preserved() {
    local case_dir="$fixture/known-hosts-preserved" home fake_bin state log output original prefix
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    output="$case_dir/output"
    original="$case_dir/original"
    prefix="$case_dir/prefix"
    mkdir -p "$case_dir"
    make_home "$home"
    make_fakes "$fake_bin"
    mark_route_up "$state"
    printf '%s\n' \
        'example.com ssh-ed25519 RVhBTVBMRQ==' \
        'github.com ssh-ed25519 QUFBQUZJWFRVUkU=' \
        'internal.example ssh-rsa SU5URVJOQUw=' > "$home/.ssh/known_hosts"
    cp -- "$home/.ssh/known_hosts" "$original"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$output"
    ((run_status == 0)) || { cat "$output"; fail "known_hosts preservation run exited $run_status"; }
    head -n 3 "$home/.ssh/known_hosts" > "$prefix"

    cmp -s "$original" "$prefix" || fail 'existing known_hosts entries were changed or reordered'
    [[ $(grep -Fxc 'github.com ssh-ed25519 QUFBQUZJWFRVUkU=' "$home/.ssh/known_hosts") -eq 1 ]] ||
        fail 'existing correct GitHub host key was changed or duplicated'
    [[ $(grep -Fxc 'github.com ssh-rsa QkJCQkZJWFRVUkU=' "$home/.ssh/known_hosts") -eq 1 ]] ||
        fail 'missing GitHub host key was not appended'
    printf 'PASS: unrelated and existing correct known_hosts entries survive in place.\n'
}

test_failed_github_metadata_fetch_fails_closed() {
    local case_dir="$fixture/metadata-fetch-failure" home fake_bin state log output
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    output="$case_dir/output"
    mkdir -p "$case_dir"
    make_home "$home"
    make_fakes "$fake_bin"
    mark_route_up "$state"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$output" '' TEST_GITHUB_META_FETCH=fail
    ((run_status != 0)) || fail 'failed GitHub metadata fetch was accepted'
    grep -q 'could not fetch GitHub host keys' "$output" || fail 'metadata-fetch error was not actionable'
    [[ ! -e $state/ssh.log ]] || fail 'SSH authentication ran after metadata fetch failed'
    [[ ! -e $log ]] || fail 'Git ran after metadata fetch failed'
    [[ ! -e $home/.ssh/known_hosts ]] || fail 'metadata fetch failure created known_hosts'
    printf 'PASS: a failed GitHub metadata fetch stops before SSH or Git.\n'
}

test_malformed_github_metadata_fails_closed() {
    local case_dir="$fixture/malformed-metadata" home fake_bin state log output
    home="$case_dir/home"
    fake_bin="$case_dir/bin"
    state="$case_dir/state"
    log="$case_dir/git.log"
    output="$case_dir/output"
    mkdir -p "$case_dir"
    make_home "$home"
    make_fakes "$fake_bin"
    mark_route_up "$state"

    run_bootstrap "$home" "$fake_bin" "$state" "$log" "$output" '' TEST_GITHUB_META_FETCH=malformed
    ((run_status != 0)) || fail 'malformed GitHub metadata was accepted'
    grep -q 'could not parse GitHub host keys' "$output" || fail 'metadata-parse error was not actionable'
    [[ ! -e $state/ssh.log ]] || fail 'SSH authentication ran after metadata parsing failed'
    [[ ! -e $log ]] || fail 'Git ran after metadata parsing failed'
    printf 'PASS: malformed GitHub metadata stops before SSH or Git.\n'
}

run_test() {
    local test_name=$1
    if [[ -z ${BOOTSTRAP_TEST_ONLY:-} || $BOOTSTRAP_TEST_ONLY == "$test_name" ]]; then
        "$test_name"
    fi
}

run_test test_github_host_key_seeding_is_idempotent
run_test test_existing_known_hosts_is_preserved
run_test test_failed_github_metadata_fetch_fails_closed
run_test test_malformed_github_metadata_fails_closed
run_test test_existing_checkout_is_idempotent
run_test test_new_clone_happens_only_once
run_test test_missing_public_key_refuses_to_continue
run_test test_missing_git_prints_root_command_and_stops
run_test test_failed_github_authentication_stops_before_git
run_test test_new_key_is_printed_and_gated
run_test test_wifi_password_never_reaches_disk
printf 'PASS: bootstrap behavior suite.\n'
