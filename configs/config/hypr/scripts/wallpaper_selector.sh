#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/Pictures/wallz"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Generate list for Rofi (Format: Name\0icon\x1fPath)
# We use null separator for safety with spaces
list_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | while IFS= read -r -d '' file;
    do
        name=$(basename "$file")
        echo -en "$name\0icon\x1f$file\n"
    done
}

# Show Rofi selection
# -dmenu: read from stdin
# -i: case insensitive
# -show-icons: show the icons
# -p: prompt
SELECTED=$(list_wallpapers | rofi -dmenu -i -show-icons -p "Wallpaper" -theme-str 'element-icon { size: 4.0ch; }')

# Exit if no selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Reconstruct full path (since we only showed the filename in the main text, but we need to find it again)
# Wait, rofi returns the *text* (name).
# If filenames are unique, we can find it. If not, we might have an issue.
# Better way: Pass the full path as the visible text? No, ugly.
# Let's assume unique filenames or find the file again.
FULL_PATH=$(find "$WALLPAPER_DIR" -type f -name "$SELECTED" | head -n 1)

if [ -z "$FULL_PATH" ] || [ ! -f "$FULL_PATH" ]; then
    echo "Error: Could not locate selected wallpaper: $SELECTED"
    exit 1
fi

echo "Selected: $FULL_PATH"

# Update Desktop Wallpaper
echo "Setting desktop wallpaper..."
swww img "$FULL_PATH" --transition-type wipe --transition-duration 0.5 --transition-fps 60

notify-send "Wallpaper Updated" "Desktop background changed."
