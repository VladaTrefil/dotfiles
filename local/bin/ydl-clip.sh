#!/usr/bin/env bash
set -euo pipefail

notify_download_status() {
    local name=$1 state=$2 message
    case $state in
        start) message='  Download Started...' ;;
        ok) message='  Download Finished' ;;
        fail) message='  Download Failed!' ;;
        *) return 2 ;;
    esac
    dunstify --hints=string:x-dunst-stack-tag:youtube-download \
        --timeout=5000 -a 'Youtube DL' "$message" "$name" || true
}

url=${1:-}
if [[ -z $url ]]; then
    url=$(wl-paste --no-newline)
fi
[[ $url =~ ^https?://[^[:space:]]+$ ]] || {
    printf 'Usage: %s [http(s)-url] [output-directory] [0|1 playlist]\n' "$0" >&2
    exit 2
}

output_dir=${2:-"$HOME/Music/New"}
playlist=${3:-0}
[[ -n $output_dir ]] || { printf 'Output directory must not be empty.\n' >&2; exit 2; }
[[ $playlist == 0 || $playlist == 1 ]] || { printf 'Playlist must be 0 or 1.\n' >&2; exit 2; }

metadata_dir="$HOME/Music/.meta"
error_log="$metadata_dir/error.log"
archive="$metadata_dir/downloaded-urls.txt"
mkdir -p -- "$metadata_dir" "$output_dir"
touch -- "$archive"

base_url=${url%%&list=*}
name=$(yt-dlp --no-playlist --skip-download --print '%(title)s' -- "$base_url" 2>/dev/null || true)
name=${name%%$'\n'*}
[[ -n $name ]] || name=$base_url

playlist_args=(--no-playlist)
if [[ $playlist == 1 ]]; then playlist_args=(--yes-playlist); fi

notify_download_status "$name" start
if output=$(yt-dlp --embed-thumbnail --embed-metadata --audio-quality 0 \
    --download-archive "$archive" -x --audio-format mp3 \
    -o "$output_dir/%(title)s.%(ext)s" "${playlist_args[@]}" -- "$url" 2>&1); then
    notify_download_status "$name" ok
else
    status=$?
    notify_download_status "$name" fail
    dunstify --timeout=10000 -a 'Youtube DL' 'Error' "$output" || true
    {
        printf '%s\n' "$output"
        printf '%s\n' '================================================================================'
    } >> "$error_log"
    exit "$status"
fi

