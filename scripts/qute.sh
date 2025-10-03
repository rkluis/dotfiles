#!/usr/bin/env bash
# ~/.local/bin/qute

# Ensure Qt apps run on Wayland
export QT_QPA_PLATFORM=wayland

URL="$1"

# Check if qutebrowser is running
if ! pgrep -x qutebrowser >/dev/null; then
    # Qutebrowser not running
    if [ -z "$URL" ]; then
        # No URL → just start qutebrowser with default profile
        exec qutebrowser -r default
    else
        # Start with URL
        exec qutebrowser -r default "$URL"
    fi
else
    if [ -n "$URL" ]; then
        # URL provided → open it in new tab
        qutebrowser "$URL"
    fi

    # Focus the tag where qutebrowser lives
    dwlmsg -s -t 1
fi

