#!/bin/bash

MINIMIZE_WORKSPACE="minimized"

MINIMIZED_WINDOWS=$(
  hyprctl clients -j |
    jq -r --arg WS "$MINIMIZE_WORKSPACE" '.[] | 
        select(.workspace.name == "special:" + $WS) | 
        "\(.address) | \(.title) (\(.class))"'
)

if [ -z "$MINIMIZED_WINDOWS" ]; then
  notify-send "Minimize Manager" "No minimized windows to restore."
  exit 0
fi

SELECTED_WINDOW_LINE=$(echo "$MINIMIZED_WINDOWS" | rofi -dmenu -i -p "Restore Window:")

if [ -z "$SELECTED_WINDOW_LINE" ]; then
  exit 0
fi

WINDOW_ADDRESS=$(echo "$SELECTED_WINDOW_LINE" | awk -F '|' '{print $1}' | tr -d '[:space:]')

hyprctl dispatch movetoworkspace +0,address:"$WINDOW_ADDRESS"

hyprctl dispatch focuswindow address:"$WINDOW_ADDRESS"
