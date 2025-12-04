#!/bin/bash

set -e

BASE_DIR="$(dirname "$0")"
SCRIPTS_DIR="$BASE_DIR/scripts"

# An array of scripts to be executed in order.
# To add a new script, just add the file name to this list.
# To disable a script, comment it out.
INSTALL_SCRIPTS=(
  "01-base-packages.sh"
  "02-aur-packages.sh"
  "03-hyprexpoinstall.sh"
  "04-nbfc-linux.sh"
  "05-flatpakconfig.sh"
  "06-themes.sh"
  "07-copyconfigs.sh"
  "08-zshinstall.sh"
  "09-sddm.sh"
  "11-fnminstall.sh"
  "12-gemini-cli.sh"
)

# Function to run a script.
run_script() {
  local script_path="$SCRIPTS_DIR/$1"
  if [ -f "$script_path" ]; then
    echo "--- Running $1 ---"
    bash "$script_path" "$BASE_DIR"
    echo "--- Finished $1 ---"
    echo ""
  else
    echo "--- Warning: Script $1 not found. Skipping. ---"
    echo ""
  fi
}

echo "Starting installation..."
echo "======================"
echo ""

for script_name in "${INSTALL_SCRIPTS[@]}"; do
  run_script "$script_name"
done

read -p "Install nvidia driver? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  run_script "10-nvidia.sh"
fi


echo "======================="
echo "Installation complete! Please reboot your system."
