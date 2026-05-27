#!/bin/bash

echo "Applying XDG Desktop Portal fixes for Niri..."

# Ensure the config directory exists
mkdir -p ~/.config/xdg-desktop-portal

# Copy the hyprland-specific portal config if it exists
if [ -f "$1/configs/config/xdg-desktop-portal/hyprland-portals.conf" ]; then
    cp "$1/configs/config/xdg-desktop-portal/hyprland-portals.conf" ~/.config/xdg-desktop-portal/hyprland-portals.conf
    echo "Copied hyprland-portals.conf to ~/.config/xdg-desktop-portal/"
fi

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
systemctl --user restart xdg-desktop-portal-hyprland
systemctl --user restart xdg-desktop-portal-kde
systemctl --user restart xdg-desktop-portal-gtk
systemctl --user restart xdg-desktop-portal-gnome

# Rebuild KDE service cache (fixes empty 'Open With' menu in Dolphin)
echo "Rebuilding KDE service cache..."
if command -v kbuildsycoca6 &> /dev/null; then
    kbuildsycoca6 --noincremental
elif command -v kbuildsycoca5 &> /dev/null; then
    kbuildsycoca5 --noincremental
fi

# Update desktop and mime databases
echo "Updating desktop and mime databases..."
update-desktop-database ~/.local/share/applications
sudo update-desktop-database /usr/share/applications
update-mime-database ~/.local/share/mime
sudo update-mime-database /usr/share/mime

echo "Portal fixes applied."
