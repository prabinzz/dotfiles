S#!/bin/bash

# Define the workspace to use for "minimized" windows
MINIMIZE_WORKSPACE="minimized"

# Move the focused column to the minimized workspace
niri msg action move-column-to-workspace "$MINIMIZE_WORKSPACE"
notify-send "Minimize Manager" "Window moved to $MINIMIZE_WORKSPACE workspace."
