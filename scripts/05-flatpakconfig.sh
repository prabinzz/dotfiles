#!/bin/bash

echo "Installing flatpak..."

sudo pacman -S --noconfirm --needed flatpak

if [ $? -eq 0 ]; then
  echo "Flatpak installed successfully."
else
  echo "Failed to install flatpak."
fi
