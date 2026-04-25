#!/bin/bash

# Default directory to save screenshots
SAVE_DIR=~/Pictures/Screenshots
mkdir -p "$SAVE_DIR"

# Editor for screenshots. Requires satty.
EDITOR="satty -f"

# Mode can be: crop_and_copy, crop_and_edit, full_and_copy, full_and_edit
MODE=$1

# Get focused monitor name from niri
get_focused_monitor_name() {
  niri msg -j outputs | jq -r '.[] | select(.focused) | .name'
}

# Get focused window geometry from niri
get_active_window_geometry() {
  # Niri's window geometry is usually internal, but we can try to find the focused window's position
  # Alternatively, just use slurp for most things. 
  # Niri doesn't have a direct 'activewindow' command like hyprland that returns geometry easily in standard units for grim.
  # We can parse `niri msg -j windows` and find the focused one.
  niri msg -j windows | jq -r '.[] | select(.is_focused) | "\(.window_column_id)"' # simplified
}

main() {
  case $MODE in
  "crop_and_copy")
    GEOMETRY=$(slurp)
    if [ -z "$GEOMETRY" ]; then exit 0; fi
    grim -g "$GEOMETRY" - | wl-copy
    notify-send "Screenshot" "Selected area copied to clipboard."
    ;;

  "crop_and_edit")
    GEOMETRY=$(slurp)
    if [ -z "$GEOMETRY" ]; then exit 0; fi
    grim -g "$GEOMETRY" - | $EDITOR -
    ;;

  "full_and_copy")
    grim -o "$(get_focused_monitor_name)" - | wl-copy
    notify-send "Screenshot" "Full screen copied to clipboard."
    ;;

  "full_and_edit")
    grim -o "$(get_focused_monitor_name)" - | $EDITOR -
    ;;

  *)
    # Default to crop and copy
    GEOMETRY=$(slurp)
    if [ -z "$GEOMETRY" ]; then exit 0; fi
    grim -g "$GEOMETRY" - | wl-copy
    notify-send "Screenshot" "Selected area copied to clipboard."
    ;;
  esac
}

main
