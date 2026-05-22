#!/bin/bash

echo "Installing base packages..."

PACKAGES=(
  hypridle
  sddm
  rofi
  swww
  xdg-desktop-portal-hyprland
  niri
  xdg-desktop-portal-gnome
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  pipewire
  pipewire-pulse
  pipewire-alsa
  wireplumber
  gst-plugin-pipewire
  kitty
  dolphin
  neovim
  ttf-jetbrains-mono-nerd
  noto-fonts-emoji
  polkit-gnome
  qt5-wayland
  qt6-wayland
  brightnessctl
  pamixer
  playerctl
  jq
  fzf
  swaync
  libnotify
  btop
  zed
  less
  slurp
  wtype
  grim
  wl-clipboard
  wl-mirror
  pavucontrol
  dnsmasq
  rustup
  blueman
  imagemagick
  satty
  github-cli
  starship
  unzip
  zoxide
  rclone
  conky
  network-manager-applet
  wlogout
)

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

echo "Base packages installed."
