#!/bin/bash

# Theme Switcher Script
# Usage: ./theme_switcher.sh [theme_name]
# Example: ./theme_switcher.sh nord

THEME=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
THEMES_DIR="$SCRIPT_DIR/../themes"

if [ -z "$THEME" ]; then
  echo "Available themes:"
  ls "$THEMES_DIR" | sed 's/\.sh//'
  exit 0
fi

THEME_FILE="$THEMES_DIR/$THEME.sh"

if [ ! -f "$THEME_FILE" ]; then
  echo "Error: Theme '$THEME' not found."
  exit 1
fi

# Load theme variables
source "$THEME_FILE"

echo "Applying theme: $THEME"

# 1. Update Hyprland Colors
cat >"$HOME/.config/hypr/colors.conf" <<EOF
\$active_border_col = $HYPR_ACTIVE_BORDER
\$inactive_border_col = $HYPR_INACTIVE_BORDER
EOF

# 2. Update Waybar Colors
cat >"$HOME/.config/waybar/colors.css" <<EOF
@define-color background $WAYBAR_BACKGROUND;
@define-color foreground $WAYBAR_FOREGROUND;
@define-color primary $WAYBAR_PRIMARY;
@define-color secondary $WAYBAR_SECONDARY;
@define-color alert $WAYBAR_ALERT;
@define-color success $WAYBAR_SUCCESS;
EOF

# 3. Update Kitty Theme
# Assumes kitty themes are available or defined in the theme file.
# For simplicity, we'll write the colors directly or use a kitty theme file if provided.
cat >"$HOME/.config/kitty/current-theme.conf" <<EOF
background $KITTY_BACKGROUND
foreground $KITTY_FOREGROUND
cursor $KITTY_CURSOR
selection_background $KITTY_SELECTION_BACKGROUND
selection_foreground $KITTY_SELECTION_FOREGROUND
EOF

# 4. Reload Components
# Reload Waybar
pkill waybar
waybar &
disown

# Reload Hyprland (not always needed for colors if using variables, but good practice)
# hyprctl reload

# Send notification
notify-send "Theme Changed" "Applied theme: $THEME"
