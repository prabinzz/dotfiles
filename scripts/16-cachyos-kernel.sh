#!/bin/bash

echo "CachyOS Kernel Installer"
echo "========================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Do not run as root. Script will ask for sudo when needed."
    exit 1
fi

echo "This script will:"
echo "1. Add CachyOS repositories to your system (using official helper script)"
echo "2. Install linux-cachyos and linux-cachyos-headers"
echo ""
read -p "Do you want to proceed? (y/N): " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
echo "Working in temporary directory: $TEMP_DIR"

# Download CachyOS repo script
echo "Downloading CachyOS repository setup script..."
if curl -L https://mirror.cachyos.org/cachyos-repo.tar.xz -o "$TEMP_DIR/cachyos-repo.tar.xz"; then
    echo "Download successful."
else
    echo "Failed to download script."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Extract and run
echo "Extracting..."
tar xvf "$TEMP_DIR/cachyos-repo.tar.xz" -C "$TEMP_DIR"

echo "Running CachyOS repository setup..."
echo "You may be prompted for your password."
cd "$TEMP_DIR/cachyos-repo"
sudo ./cachyos-repo.sh

# Install Kernel
echo "Installing CachyOS Kernel..."
# Sync DB first
sudo pacman -Sy

echo "Installing linux-cachyos and headers..."
sudo pacman -S --needed linux-cachyos linux-cachyos-headers

# Cleanup
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo ""
echo "Installation complete."
echo "Please reboot your system to use the new kernel."
echo "Note: If you use GRUB, you might need to run 'sudo grub-mkconfig -o /boot/grub/grub.cfg' if the kernel is not detected automatically."
echo "If you use systemd-boot, check your loader entries."
