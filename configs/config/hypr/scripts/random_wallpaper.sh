#!/bin/bash

# Find a random image
WALLPAPER=$(find ~/Pictures/wallz/ -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -print0 | shuf -z -n 1 | xargs -0)

# Set wallpaper with fast transition
swww img "$WALLPAPER" --transition-type wipe --transition-duration 0.5 --transition-fps 60
