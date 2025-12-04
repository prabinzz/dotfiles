#!/bin/bash

set -e

BASE_DIR="$(dirname "$SCRIPT_PATH")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() {
  echo -e "${BLUE}[INSTALLER]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check for yay
if ! command -v yay &>/dev/null; then
  log "yay is not installed. Installing it."
  ./scripts/yayinstall.sh "$BASE_DIR"
  exit 1
fi

log "Starting installation..."

# 1. Base Packages
log "Installing base packages..."
PACKAGES=(
  hyprland
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
)
sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

AURPACKAGES=(
  google-chrome
  linux-wifi-hotspot
  nwg-look
  nwg-displays
)

yay -S --noconfirm --needed "${AURPACKAGES[@]}"
./scripts/hyprexpoinstall.sh
./scripts/nbfc-linux.sh

success "Base packages installed."

log ./scripts/flatpakconfig.sh

success "Flatpak configured"

log "Installing themes"
./scripts/themes.sh "$BASE_DIR"
success "Themes installed."

log "Copying configs."
./scripts/copyconfigs.sh "$BASE_DIR"
log "Copying configs."

# Enable SDDM
log "Enabling SDDM..."
sudo systemctl enable sddm
success "SDDM enabled."

read -p "Install nvidia driver? (y/n): " -n 0 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  ./scripts/nvidiainstall.sh
fi

log "Installation complete! Please reboot your system."
