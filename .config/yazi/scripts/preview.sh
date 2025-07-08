#!/bin/bash

file="$1"

mime=$(file --mime-type -b "$file")

if [[ "$mime" == video/* || "$mime" == audio/* ]]; then
    duration=$(ffprobe -v error -show_entries format=duration \
                -of default=noprint_wrappers=1:nokey=1 "$file")
    if [[ -n "$duration" ]]; then
        mins=$(printf "%02d" $((${duration%.*}/60)))
        secs=$(printf "%02d" $((${duration%.*}%60)))
        echo "🎵 Media duration: ${mins}:${secs}"
    else
        echo "🎵 Media duration: unknown"
    fi
    exit 0
fi

# fallback preview
if [[ -f "$file" ]]; then
    bat --style=plain --color=always "$file" || cat "$file"
fi

