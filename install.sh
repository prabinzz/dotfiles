#!/bin/bash

set -e

# --- Help Function ---
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -a, --ask                Prompt before executing each installation script."
  echo "  -c, --sync-configs       Only sync configuration files."
  echo "  -p, --install-packages   Install base and AUR packages, then sync configs."
  echo "  -h, --help               Show this help message."
}

# --- Argument Parsing ---
ask_before_exec=false
sync_only=false
install_packages_and_sync=false

# Simple argument parsing
for arg in "$@"; do
  case "$arg" in
  -h | --help)
    show_help
    exit 0
    ;;
  -a | --ask)
    ask_before_exec=true
    shift
    ;;
  -c | --sync-configs)
    sync_only=true
    shift
    ;;
  -p | --install-packages)
    install_packages_and_sync=true
    shift
    ;;
  esac
done

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
    if [ "$ask_before_exec" = true ]; then
      read -p "--- Run script $1? (y/n): " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "--- Skipping $1 ---"
        echo ""
        return
      fi
    fi
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

if [ "$sync_only" = true ]; then
  run_script "07-copyconfigs.sh"
elif [ "$install_packages_and_sync" = true ]; then
  run_script "01-base-packages.sh"
  run_script "02-aur-packages.sh"
  run_script "07-copyconfigs.sh"
else
  for script_name in "${INSTALL_SCRIPTS[@]}"; do
    run_script "$script_name"
  done

  read -p "Install nvidia driver? (y/n): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_script "10-nvidia.sh"
  fi

  read -p "Install Game packages? (y/n): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_script "13-gaming.sh"
  fi

fi

echo "======================="
echo "Installation complete!"

