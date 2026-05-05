#!/bin/bash

echo "Applying XDG Desktop Portal fixes for Niri..."

# Ensure the config directory exists
mkdir -p ~/.config/xdg-desktop-portal

# Copy the niri-specific portal config if it exists in the dotfiles
if [ -f "$1/configs/config/xdg-desktop-portal/niri-portals.conf" ]; then
    cp "$1/configs/config/xdg-desktop-portal/niri-portals.conf" ~/.config/xdg-desktop-portal/niri-portals.conf
    echo "Copied niri-portals.conf to ~/.config/xdg-desktop-portal/"
fi

# Copy the general portals.conf if it exists
if [ -f "$1/configs/config/xdg-desktop-portal/portals.conf" ]; then
    cp "$1/configs/config/xdg-desktop-portal/portals.conf" ~/.config/xdg-desktop-portal/portals.conf
    echo "Copied portals.conf to ~/.config/xdg-desktop-portal/"
fi

# Restart portal services to apply changes
echo "Restarting portal services..."
systemctl --user restart xdg-desktop-portal
systemctl --user restart xdg-desktop-portal-gnome
systemctl --user restart xdg-desktop-portal-gtk

echo "Portal fixes applied."
