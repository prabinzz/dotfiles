#!/bin/bash

echo "Installing hyprexpo..."

# Check if already installed
if hyprpm list 2>/dev/null | grep -q "hyprexpo" && hyprpm list 2>/dev/null | grep -q "enabled"; then
  echo "hyprexpo already installed and enabled."
  exit 0
fi

# Install dependencies
echo "Installing dependencies..."
sudo pacman -S --needed --noconfirm cmake meson cpio pkgconf git gcc >/dev/null 2>&1

# Update hyprpm
echo "Updating hyprpm..."
hyprpm update >/dev/null 2>&1

# Add repository if not exists
if ! hyprpm list 2>/dev/null | grep -q "hyprland-plugins"; then
  echo "Adding hyprland-plugins repository..."
  echo "Y" | hyprpm add https://github.com/hyprwm/hyprland-plugins >/dev/null 2>&1
fi

# Enable hyprexpo
echo "Enabling hyprexpo..."
hyprpm enable hyprexpo >/dev/null 2>&1

# Reload
hyprctl reload >/dev/null 2>&1

if hyprpm list 2>/dev/null | grep -q "hyprexpo" && hyprpm list 2>/dev/null | grep -q "enabled"; then
  echo "hyprexpo installed successfully."
else
  echo "Failed to install hyprexpo."
fi
