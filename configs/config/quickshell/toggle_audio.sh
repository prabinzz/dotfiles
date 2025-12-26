#!/bin/bash
TARGET="AudioSelector.qml"

# Check if running
if pgrep -f "quickshell.*$TARGET" > /dev/null; then
    pkill -f "quickshell.*$TARGET"
else
    quickshell -p "$(dirname "$0")/AudioSelector.qml" &
fi
