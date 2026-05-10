#!/bin/bash

# Monitor mode switcher for Niri
# Detects available monitors and offers switching options via rofi

LAPTOP="eDP-1"

# Get all monitors from niri (connected outputs)
get_monitors() {
    niri msg -j outputs | jq -r 'keys[]'
}

# Get external monitors
get_external_monitors() {
    niri msg -j outputs | jq -r 'keys[] | select(. != "'"$LAPTOP"'")'
}

laptop_only() {
    notify-send "Monitor Switch" "Switching to Laptop Only mode..."
    # Turn off all external monitors
    EXT_MONITORS=$(get_external_monitors)
    for monitor in $EXT_MONITORS; do
        niri msg output "$monitor" off
    done
    # Ensure laptop monitor is on
    niri msg output "$LAPTOP" on
    notify-send "Monitor Switch" "Laptop mode activated"
}

external_only() {
    EXT_MONITORS=$(get_external_monitors)
    if [ -z "$EXT_MONITORS" ]; then
        notify-send "Monitor Switch" "No external monitor detected!" -u critical
        exit 1
    fi

    # If multiple, let user choose
    COUNT=$(echo "$EXT_MONITORS" | wc -l)
    if [ "$COUNT" -gt 1 ]; then
        SELECTED=$(echo "$EXT_MONITORS" | rofi -dmenu -p "Select External Monitor" -theme-str 'window {width: 500px; height: 400px;}')
        [ -z "$SELECTED" ] && exit 0
    else
        SELECTED=$EXT_MONITORS
    fi

    notify-send "Monitor Switch" "Switching to External Only mode ($SELECTED)..."
    niri msg output "$SELECTED" on
    niri msg output "$LAPTOP" off
    notify-send "Monitor Switch" "External monitor activated: $SELECTED\nLaptop screen disabled"
}

dual_monitor() {
    EXT_MONITORS=$(get_external_monitors)
    if [ -z "$EXT_MONITORS" ]; then
        notify-send "Monitor Switch" "No external monitor detected!" -u critical
        exit 1
    fi

    notify-send "Monitor Switch" "Switching to Dual Monitor mode..."
    niri msg output "$LAPTOP" on
    
    # We use the positions from the config or set them here if needed.
    # Niri usually respects the config positions if we just turn them on.
    # We reset to auto to ensure they are not overlapping if they were mirrored.
    niri msg output "$LAPTOP" position auto
    for monitor in $EXT_MONITORS; do
        niri msg output "$monitor" on
        niri msg output "$monitor" position auto
    done
    notify-send "Monitor Switch" "Dual monitor mode activated"
}

mirror_mode() {
    EXT_MONITORS=$(get_external_monitors)
    if [ -z "$EXT_MONITORS" ]; then
        notify-send "Monitor Switch" "No external monitor detected!" -u critical
        exit 1
    fi
    
    SELECTED=$(echo "$EXT_MONITORS" | rofi -dmenu -p "Select Monitor to Mirror" -theme-str 'window {width: 500px; height: 400px;}')
    [ -z "$SELECTED" ] && exit 0

    notify-send "Monitor Switch" "Mirroring $LAPTOP to $SELECTED..."
    niri msg output "$LAPTOP" on
    niri msg output "$SELECTED" on
    # Set position to 0,0 to overlap (niri mirroring)
    niri msg output "$SELECTED" position set 0 0
}

# Menu
CHOICE=$(echo -e "󰍹  Laptop Only\n󰍺  External Only\n󰹑  Dual Monitor\n󰹑  Mirror Display" |
  rofi -dmenu -p "Select Monitor Mode" -theme-str 'window {width: 400px; height: 300px;}')

case "$CHOICE" in
    *"Laptop Only"*)
        laptop_only
        ;;
    *"External Only"*)
        external_only
        ;;
    *"Dual Monitor"*)
        dual_monitor
        ;;
    *"Mirror Display"*)
        mirror_mode
        ;;
    *)
        exit 0
        ;;
esac
