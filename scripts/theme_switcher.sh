#!/bin/bash

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

source "$THEME_FILE"

echo "Applying theme: $THEME..."

# --- Update Configuration Files ---

cat >"$HOME/.config/colors.json" <<EOF
{
  "background": "$WAYBAR_BACKGROUND",
  "foreground": "$WAYBAR_FOREGROUND",
  "primary": "$WAYBAR_PRIMARY",
  "secondary": "$WAYBAR_SECONDARY",
  "alert": "$WAYBAR_ALERT",
  "success": "$WAYBAR_SUCCESS"
}
EOF

cat >"$HOME/.config/hypr/colors.conf" <<EOF
\$active_border_col = $HYPR_ACTIVE_BORDER
\$inactive_border_col = $HYPR_INACTIVE_BORDER
EOF

cat >"$HOME/.config/waybar/colors.css" <<EOF
@define-color background $WAYBAR_BACKGROUND;
@define-color foreground $WAYBAR_FOREGROUND;
@define-color primary $WAYBAR_PRIMARY;
@define-color secondary $WAYBAR_SECONDARY;
@define-color alert $WAYBAR_ALERT;
@define-color success $WAYBAR_SUCCESS;
EOF

cat >"$HOME/.config/kitty/current-theme.conf" <<EOF
background $KITTY_BACKGROUND
foreground $KITTY_FOREGROUND
cursor $KITTY_CURSOR
selection_background $KITTY_SELECTION_BACKGROUND
selection_foreground $KITTY_SELECTION_FOREGROUND
EOF

# --- Reload Components ---

pkill waybar || true
waybar &
disown

notify-send "Theme Changed" "Applied theme: $THEME"

echo "Theme '$THEME' applied successfully."
