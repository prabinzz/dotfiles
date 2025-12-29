#!/bin/bash

echo "Configuring SDDM..."

# Install Dependencies for Silent Theme
echo "Installing dependencies for Silent SDDM theme..."
sudo pacman -S --noconfirm --needed qt6-svg qt6-declarative qt6-virtualkeyboard qt6-multimedia

# Install Theme
THEME_DIR="/usr/share/sddm/themes/silent"
if [ ! -d "$THEME_DIR" ]; then
    echo "Fetching latest Silent SDDM release tag..."
    
    # Get latest tag from GitHub API
    LATEST_TAG=$(curl -s https://api.github.com/repos/uiriansan/SilentSDDM/releases/latest | grep "tag_name" | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p')
    
    if [ -z "$LATEST_TAG" ]; then
        echo "Error: Could not fetch latest release tag. Defaulting to v1.4.0"
        LATEST_TAG="v1.4.0"
    fi
    
    echo "Installing Silent SDDM theme ($LATEST_TAG)..."
    
    # Create temp dir
    TEMP_DIR=$(mktemp -d)
    
    # Download release tarball
    echo "Downloading release archive..."
    curl -L "https://github.com/uiriansan/SilentSDDM/archive/refs/tags/${LATEST_TAG}.tar.gz" -o "$TEMP_DIR/silent-sddm.tar.gz"
    
    # Extract
    echo "Extracting..."
    tar -xzf "$TEMP_DIR/silent-sddm.tar.gz" -C "$TEMP_DIR"
    
    # Find the extracted directory (it changes based on version)
    # Usually SilentSDDM-version (without v) or SilentSDDM-tag
    EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "SilentSDDM*" | head -n 1)
    
    if [ -d "$EXTRACTED_DIR" ]; then
        echo "Found extracted directory: $(basename "$EXTRACTED_DIR")"
        echo "Installing to $THEME_DIR..."
        sudo mkdir -p "$THEME_DIR"
        sudo cp -r "$EXTRACTED_DIR/"* "$THEME_DIR/"
        echo "Silent SDDM theme installed successfully."
    else
        echo "Error: Extraction failed or unexpected directory structure."
        ls -R "$TEMP_DIR"
        exit 1
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
else
    echo "Silent SDDM theme directory already exists. Skipping installation."
fi

# Enable SDDM Service
echo "Enabling SDDM service..."
sudo systemctl enable sddm
echo "SDDM service enabled."

# Configure SDDM Theme
echo "Setting SDDM theme to 'silent'..."

# Backup current config
if [ -f /etc/sddm.conf ]; then
    echo "Backing up /etc/sddm.conf..."
    sudo cp /etc/sddm.conf /etc/sddm.conf.backup.$(date +%Y%m%d-%H%M%S)
fi

# Apply theme
# We use sed to replace the Current=... line or append if not found.
if grep -q "^[Theme]" /etc/sddm.conf 2>/dev/null; then
    # Section exists, check if Current exists
    if grep -q "Current=" /etc/sddm.conf; then
        sudo sed -i 's/^Current=.*/Current=silent/' /etc/sddm.conf
    else
        sudo sed -i '/^[Theme]/a Current=silent' /etc/sddm.conf
    fi
else
    # Section doesn't exist, append it
    echo -e "\n[Theme]\nCurrent=silent" | sudo tee -a /etc/sddm.conf >/dev/null
fi

echo "SDDM theme configured to 'silent'."