#!/bin/bash

echo "Installing base packages..."

PACKAGES=(
  hyprland
  hypridle
  sddm
  waybar
  rofi
  swww
  xdg-desktop-portal-hyprland
  kitty
  nautilus
  neovim
  ttf-jetbrains-mono-nerd
  noto-fonts-emoji
  polkit-gnome
  qt5-wayland
  qt6-wayland
  brightnessctl
  pamixer
  jq
  fzf
  swaync
  libnotify
  btop
  zed
  less
  slurp
  grim
  wl-clipboard
  pavucontrol
  zed
  dnsmasq
  rustup
  blueman
  imagemagick
  swappy
)

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

echo "Base packages installed."
