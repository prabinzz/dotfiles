#!/bin/bash

# Monitor mode switcher for Hyprland with wofi menu
# Usage: ./monitor-switch.sh

LAPTOP="eDP-1"

# Get all external monitors (including disabled ones)
get_external_monitors() {
  hyprctl monitors all -j | jq -r '.[] | select(.name != "'"$LAPTOP"'") | .name + " (" + .description + ")"'
}

# Extract monitor name from selection
get_monitor_name() {
  echo "$1" | cut -d' ' -f1
}

laptop_mode() {
  echo "Switching to laptop mode..."

  # Move all workspaces to laptop monitor
  for ws in $(hyprctl workspaces -j | jq -r '.[].id'); do
    hyprctl dispatch moveworkspacetomonitor "$ws" "$LAPTOP"
  done

  # Disable all external monitors
  hyprctl monitors all -j | jq -r '.[] | select(.name != "'"$LAPTOP"'") | .name' | while read -r monitor; do
    hyprctl keyword monitor "$monitor,disable"
  done

  notify-send "Monitor Mode" "Laptop mode activated\nAll external monitors disabled"
}

dual_mode() {
  echo "Switching to dual monitor mode..."

  # Get list of external monitors
  MONITORS=$(get_external_monitors)

  if [ -z "$MONITORS" ]; then
    notify-send "Monitor Mode" "No external monitor detected!" -u critical
    exit 1
  fi

  # Let user select which monitor to use
  SELECTED=$(echo "$MONITORS" | rofi -dmenu -p "Select External Monitor" -theme-str 'window {width: 500px; height: 400px;}')

  if [ -z "$SELECTED" ]; then
    exit 0
  fi

  EXTERNAL=$(get_monitor_name "$SELECTED")

  # Enable the selected external monitor
  hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"

  # Give it a moment to initialize
  sleep 0.5

  # Move workspace 1 to laptop, workspace 2 to external
  hyprctl dispatch moveworkspacetomonitor 1 "$LAPTOP"
  hyprctl dispatch moveworkspacetomonitor 2 "$EXTERNAL"

  notify-send "Monitor Mode" "Dual mode activated\nLaptop: $LAPTOP\nExternal: $EXTERNAL"
}

mirror_mode() {
  echo "Switching to mirror mode..."

  # Get list of external monitors
  MONITORS=$(get_external_monitors)

  if [ -z "$MONITORS" ]; then
    notify-send "Monitor Mode" "No external monitor detected!" -u critical
    exit 1
  fi

  # Let user select which monitor to mirror to
  SELECTED=$(echo "$MONITORS" | rofi -dmenu -p "Select Monitor to Mirror" -theme-str 'window {width: 500px; height: 400px;}')

  if [ -z "$SELECTED" ]; then
    exit 0
  fi

  EXTERNAL=$(get_monitor_name "$SELECTED")

  # Enable external monitor in mirror mode
  hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror,$LAPTOP"

  notify-send "Monitor Mode" "Mirror mode activated\nMirroring $LAPTOP to $EXTERNAL"
}

# Show wofi menu for mode selection
CHOICE=$(echo -e "󰍹  Laptop Only\n󰍺  Dual Monitor\n󰹑  Mirror Display" |
  rofi -dmenu -p "Select Monitor Mode" -theme-str 'window {width: 400px; height: 400px;}')

case "$CHOICE" in
"󰍹  Laptop Only")
  laptop_mode
  ;;
"󰍺  Dual Monitor")
  dual_mode
  ;;
"󰹑  Mirror Display")
  mirror_mode
  ;;
*)
  exit 0
  ;;
esac
