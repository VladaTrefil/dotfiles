#!/usr/bin/env bash

dir="$HOME/Music/New"
output_template="%(title)s.%(ext)s"

clipboard=$(xclip -o)

yt-dlp -x --audio-format 'mp3' -o "$dir/$output_template" --embed-thumbnail "$clipboard" --force-ipv4
