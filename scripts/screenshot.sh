#!/bin/sh

# Usage: screenshot.sh [mode]
# mode: "full", "region", or "regiontext"

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
file="$dir/screenshot_$timestamp.png"

if [ "$1" = "region" ]; then
    grim -g "$(slurp)" "$file"
    wl-copy < "$file"
elif [ "$1" = "regiontext" ]; then
    region="$(slurp)"
    [ -z "$region" ] && exit 1
    grim -g "$region" "$file"
    grim -g "$region" - | tesseract stdin stdout 2>/dev/null | wl-copy
else
    grim "$file"
    wl-copy < "$file"
fi

