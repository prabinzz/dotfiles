#!/bin/bash

echo "NVIDIA Proprietary Driver Installer for Hyprland"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "Do not run as root. Script will ask for sudo when needed."
  exit 1
fi

# Detect NVIDIA GPU
if ! lspci | grep -i nvidia >/dev/null; then
  echo "No NVIDIA GPU detected. Exiting."
  exit 1
fi

echo "NVIDIA GPU detected:"
lspci | grep -i nvidia
echo ""

# Check current driver
echo "Checking current driver..."
if lsmod | grep -q nouveau; then
  echo "Nouveau (open source) driver currently loaded"
  NOUVEAU_LOADED=true
else
  echo "Nouveau not loaded"
  NOUVEAU_LOADED=false
fi

if lsmod | grep -q nvidia; then
  echo "NVIDIA proprietary driver already loaded"
  NVIDIA_LOADED=true
else
  echo "NVIDIA proprietary driver not loaded"
  NVIDIA_LOADED=false
fi
echo ""

# Remove nouveau and install nvidia
echo "Installing NVIDIA proprietary drivers..."
echo ""

# Remove nouveau drivers
sudo pacman -Rns --noconfirm xf86-video-nouveau 2>/dev/null || true

# Detect installed kernels and select appropriate headers
HEADERS=()
if pacman -Q linux &>/dev/null; then
  HEADERS+=(linux-headers)
fi
if pacman -Q linux-lts &>/dev/null; then
  HEADERS+=(linux-lts-headers)
fi
if pacman -Q linux-cachyos &>/dev/null; then
  HEADERS+=(linux-cachyos-headers)
fi
if pacman -Q linux-zen &>/dev/null; then
  HEADERS+=(linux-zen-headers)
fi

# Fallback to base linux-headers if no kernel package was matched (unlikely)
if [ ${#HEADERS[@]} -eq 0 ]; then
  HEADERS+=(linux-headers)
fi

echo "Installing NVIDIA proprietary drivers and matching headers: ${HEADERS[*]}"
sudo pacman -S --needed \
  "${HEADERS[@]}" \
  nvidia-dkms \
  nvidia-utils \
  nvidia-settings \
  egl-wayland

if [ $? -ne 0 ]; then
  echo "Failed to install NVIDIA drivers"
  exit 1
fi

echo "NVIDIA drivers installed"
echo ""

# Blacklist nouveau
echo "Blacklisting nouveau driver..."
sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveau.conf << EOF
blacklist nouveau
options nouveau modeset=0
EOF'

# Enable nvidia-drm
echo "Configuring NVIDIA DRM..."
sudo bash -c 'cat > /etc/modprobe.d/nvidia.conf << EOF
options nvidia_drm modeset=1 fbdev=1
EOF'

# Update mkinitcpio for NVIDIA
echo "Updating initramfs..."
if grep -q "^MODULES=" /etc/mkinitcpio.conf; then
  sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
else
  sudo bash -c 'echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" >> /etc/mkinitcpio.conf'
fi

sudo mkinitcpio -P

# Update bootloader
echo "Detecting bootloader..."

BOOTLOADER=""

# Detect systemd-boot
if [ -d /boot/loader/entries ] && [ -f /boot/loader/loader.conf ]; then
  BOOTLOADER="systemd-boot"
# Detect GRUB
elif [ -f /etc/default/grub ] || [ -d /boot/grub ]; then
  BOOTLOADER="grub"
# Detect rEFInd
elif [ -f /boot/refind_linux.conf ] || [ -d /boot/EFI/refind ]; then
  BOOTLOADER="refind"
# Detect LILO
elif [ -f /etc/lilo.conf ]; then
  BOOTLOADER="lilo"
fi

if [ -z "$BOOTLOADER" ]; then
  echo "Warning: Could not detect bootloader"
  echo "Manually add 'nvidia_drm.modeset=1' to your bootloader configuration"
else
  echo "Detected: $BOOTLOADER"

  case "$BOOTLOADER" in
  systemd-boot)
    ENTRY_FILE=$(ls /boot/loader/entries/*.conf 2>/dev/null | head -n 1)

    if [ -n "$ENTRY_FILE" ]; then
      if grep -q "nvidia_drm.modeset=1" "$ENTRY_FILE"; then
        echo "Already configured for NVIDIA"
      else
        sudo sed -i 's/^options /options nvidia_drm.modeset=1 /' "$ENTRY_FILE"
        echo "systemd-boot configured"
      fi
    else
      echo "Warning: Could not find entry file in /boot/loader/entries/"
    fi
    ;;

  grub)
    if grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
      echo "Already configured for NVIDIA"
    else
      sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 /' /etc/default/grub
      sudo grub-mkconfig -o /boot/grub/grub.cfg
      echo "GRUB configured"
    fi
    ;;

  refind)
    if [ -f /boot/refind_linux.conf ]; then
      if grep -q "nvidia_drm.modeset=1" /boot/refind_linux.conf; then
        echo "Already configured for NVIDIA"
      else
        sudo sed -i 's/"$/ nvidia_drm.modeset=1"/' /boot/refind_linux.conf
        echo "rEFInd configured"
      fi
    fi
    ;;

  lilo)
    if grep -q "nvidia_drm.modeset=1" /etc/lilo.conf; then
      echo "Already configured for NVIDIA"
    else
      sudo sed -i '/append=/s/"$/ nvidia_drm.modeset=1"/' /etc/lilo.conf
      sudo lilo
      echo "LILO configured"
    fi
    ;;
  esac
fi

# Final message
echo "================================================"