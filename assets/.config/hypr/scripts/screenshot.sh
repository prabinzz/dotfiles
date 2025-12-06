#!/bin/bash

# Default directory to save screenshots
SAVE_DIR=~/Pictures/Screenshots
mkdir -p "$SAVE_DIR"

# Editor for screenshots. Requires swappy.
EDITOR="swappy -f"

# Mode can be:
# crop_and_copy
# crop_and_edit
# full_and_copy
# full_and_edit
# window_and_copy
# window_and_edit
MODE=$1

# Get active window geometry. Requires jq.
get_active_window_geometry() {
  hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

# Get focused monitor name. Requires jq.
get_focused_monitor_name() {
  hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
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

  "window_and_copy")
    grim -g "$(get_active_window_geometry)" - | wl-copy
    notify-send "Screenshot" "Active window copied to clipboard."
    ;;

  "window_and_edit")
    grim -g "$(get_active_window_geometry)" - | $EDITOR -
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

