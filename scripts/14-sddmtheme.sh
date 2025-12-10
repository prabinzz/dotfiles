#!/bin/bash

echo "Installing Vinyl SDDM Theme..."
echo "Source: ./assets/vinyl-sddm-6.4.4.25.8.20.tar.gz"
echo "---"

# Check theme file exists
echo "Checking theme archive..."
if [ ! -f "../assets/vinyl-sddm-6.4.4.25.8.20.tar.gz" ]; then
  echo "ERROR: Theme file not found!"
  exit 1
fi
echo "Archive found."

# Extract theme
echo "Extracting theme..."
sudo tar -xvzf "./assets/vinyl-sddm-6.4.4.25.8.20.tar.gz" -C "/usr/share/sddm/themes/vinyl/"
echo "Extracted successfully."

# Backup and configure SDDM
echo "Backing up current config..."
sudo cp /etc/sddm.conf /etc/sddm.conf.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true

echo "Updating SDDM configuration..."
if ! grep -q "^\[Theme\]" /etc/sddm.conf 2>/dev/null; then
  echo -e "\n[Theme]\nCurrent=vinyl" | sudo tee -a /etc/sddm.conf >/dev/null
else
  sudo sed -i '/^\[Theme\]/,/^$/s/Current=.*/Current=vinyl/' /etc/sddm.conf
fi
echo "Configuration updated."

# Done
echo "---"
echo "Installation complete!"
echo "Log out or run 'sudo systemctl restart sddm' to apply the new theme."
echo "If anything looks wrong, restore with:"
echo "sudo cp /etc/sddm.conf.backup.* /etc/sddm.conf && sudo systemctl restart sddm"
echo "Enjoy!"
