#!/usr/bin/env bash

# Add dunst status colors
# Add repeated download on error
# Optional: Add thumbnail to dunst notification

ERROR_LOG="$HOME/Music/.meta/error.log"
DOWNLOADS="$HOME/Music/.meta/downloaded-urls.txt"

SEPARATOR="========================================================================================================================================================================================================"

url="$(echo "${1:-$(xclip -o)}" | sed 's/\(.*\)&list.*/\1/')"
dir="${2:-$HOME/Music/New}"
playlist="${3:-0}"

function notify_download_status() {
  message=""
  name="$1"

  case $2 in
    "start")
      message=" Download Started..."
      ;;
    "ok")
      message=" Download Finished"
      ;;
    "fail")
      message=" Download Failed!"
      ;;
    "exists")
      message=" Already Exists"
      ;;
  esac

  dunstify --hints=string:x-dunst-stack-tag:test \
           --timeout=20000 \
           --appname="Youtube DL" \
           "$message" "$name"
}

name=$(wget --quiet -O - "$url" | sed -n -e 's!.*<title>\(.*\) -.*</title>.*!\1!p')

if ! grep -qo "$url" "$DOWNLOADS"
then
  if [ "$playlist" -eq 1 ]
  then
    playlist="--yes-playlist"
  else
    playlist="--no-playlist"
  fi

  notify_download_status "$name" "start"

  output=$(yt-dlp --embed-thumbnail \
                  --embed-metadata \
                  --audio-quality 0 \
                  --print-to-file webpage_url "$DOWNLOADS" \
                  -x --audio-format 'mp3' \ \
                  -o "$dir/%(title)s.%(ext)s" \
                  $playlist \
                  "$url")

  if [ -n "$output" ]
  then
    notify_download_status "$name" "ok"
  else
    # Remove last line from DOWNLOADS urls
    sed -i '$ d' ~/Music/.meta/DOWNLOADS-urls.txt
    notify_download_status "$name" "fail"

    echo "$output" >> "$ERROR_LOG"
    printf "\n%s" "$SEPARATOR" >> "$ERROR_LOG"
  fi
else
  notify_download_status "$name" "exists"
fi
