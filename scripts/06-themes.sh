#!/bin/bash

echo "Installing themes..."

sudo pacman -S --noconfirm --needed tela-circle-icon-theme-dracula
yay -S --noconfirm --needed catppuccin-gtk-theme-mocha bibata-cursor-theme-modern-ice

if [ $? -eq 0 ]; then
  echo "Themes installed successfully."
else
  echo "Failed to install themes."
fi
