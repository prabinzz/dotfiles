#!/bin/bash

set -e

# --- Help Function ---
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -a, --ask                Prompt before executing each installation script."
  echo "  -c, --sync-configs       Only sync configuration files."
  echo "  -p, --install-packages   Install base and AUR packages, then sync configs."
  echo "  -s, --select             Select which scripts to run from a menu."
  echo "  -h, --help               Show this help message."
}

# --- Argument Parsing ---
ask_before_exec=false
sync_only=false
install_packages_and_sync=false
select_mode=false

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
  -s | --select)
    select_mode=true
    shift
    ;; 
  esac
done

BASE_DIR="$(dirname "$0")"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Default ordered list for standard installation
INSTALL_SCRIPTS=(
  # --- Package Installation ---
  "01-base-packages.sh"
  "02-aur-packages.sh"

  # --- System Configuration ---
  "04-nbfc-linux.sh"
  "05-flatpakconfig.sh"
  "09-sddm.sh"      # Enables SDDM and sets theme
  "10-nvidia.sh"    # Optional (will prompt if not interactive, but included here for completeness if selected)

  # --- UI & Themes ---
  "06-themes.sh"    # GTK/Icon themes
  
  # --- Dotfiles Sync ---
  "07-copyconfigs.sh"

  # --- User Shell & Tools ---
  "08-zshinstall.sh"
  "11-fnminstall.sh"
  "12-gemini-cli.sh"
  "15-tmux.sh"
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

if [ "$select_mode" = true ]; then
  # Check if whiptail is installed
  if ! command -v whiptail &> /dev/null; then
      echo "Error: whiptail is not installed. Please install it to use the selection menu."
      exit 1
  fi

  # Find all numbered scripts
  mapfile -t ALL_SCRIPTS < <(find "$SCRIPTS_DIR" -maxdepth 1 -name "[0-9]*.sh" -printf "%f\n" | sort)

  # Build checklist arguments
  CHECKLIST_ARGS=()
  for script in "${ALL_SCRIPTS[@]}"; do
      # Default to OFF (unchecked) for all, user selects what they want.
      status="OFF"
      for default_script in "${INSTALL_SCRIPTS[@]}"; do
          if [[ "$script" == "$default_script" ]]; then
              status="ON"
              break
          fi
      done
      
      CHECKLIST_ARGS+=("$script" "" "$status")
  done

  # Show checklist
  SELECTED_SCRIPTS=$(whiptail --title "Select Installation Scripts" --checklist \
  "Choose the scripts you want to run (Space to select, Enter to confirm):" \
  20 78 12 "${CHECKLIST_ARGS[@]}" 3>&1 1>&2 2>&3)

  exit_status=$?
  if [ $exit_status -ne 0 ]; then
      echo "Selection cancelled."
      exit 0
  fi

  # Remove quotes from result
  SELECTED_SCRIPTS="${SELECTED_SCRIPTS//\"/}"

  if [ -z "$SELECTED_SCRIPTS" ]; then
      echo "No scripts selected."
      exit 0
  fi

  echo "Selected scripts: $SELECTED_SCRIPTS"
  echo ""

  # Run selected scripts
  for script_name in $SELECTED_SCRIPTS; do
      run_script "$script_name"
  done

elif [ "$sync_only" = true ]; then
  run_script "07-copyconfigs.sh"
elif [ "$install_packages_and_sync" = true ]; then
  run_script "01-base-packages.sh"
  run_script "02-aur-packages.sh"
  run_script "07-copyconfigs.sh"
else
  # Default standard installation
  
  # Run the scripts defined in INSTALL_SCRIPTS
  # Note: logic for optional scripts (nvidia, gaming) was handled specially before.
  # We will restore that logic but only run scripts that are NOT those specific ones from the list,
  # OR we can just keep the list clean and handle the optionals manually like before.
  
  # Let's filter out 10-nvidia.sh and 13-gaming.sh from the auto-run list if they are in there,
  # because we want to ask for them.
  
  for script_name in "${INSTALL_SCRIPTS[@]}"; do
    if [[ "$script_name" == "10-nvidia.sh" || "$script_name" == "13-gaming.sh" ]]; then
      continue
    fi
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

echo "======================"
echo "Installation complete!"
