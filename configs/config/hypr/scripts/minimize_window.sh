#!/bin/bash

# Define the name of your special workspace
MINIMIZE_WORKSPACE="minimized"

# Check if a window is currently active
if ! hyprctl activewindow | grep 'workspace: ' >/dev/null; then
  exit 0
fi

# Move the active window to the special workspace silently
hyprctl dispatch movetoworkspacesilent special:$MINIMIZE_WORKSPACE
