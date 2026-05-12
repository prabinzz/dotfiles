#!/bin/bash
# random_wallpaper.sh
# Pick a random wallpaper via Noctalia Shell IPC (respects transitions,
# color-scheme syncing, and automation settings).
# Falls back to raw awww if Noctalia Shell is not running.

SCREEN="${1:-}"   # Optional: pass monitor name, e.g. eDP-1

if qs -c noctalia-shell ipc show &>/dev/null; then
    qs -c noctalia-shell ipc call wallpaper random "$SCREEN"
else
    # Fallback – set directly with awww
    WALLPAPER=$(find ~/Pictures/wallz/ -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
           -o -iname "*.gif" -o -iname "*.webp" \) \
        -print0 | shuf -z -n 1 | xargs -0)
    awww img "$WALLPAPER" \
        --transition-type wipe \
        --transition-duration 0.5 \
        --transition-fps 60
fi
