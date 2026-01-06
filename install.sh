#!/bin/bash

set -e

# --- Help Function ---
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -a, --ask                Prompt before executing each installation script."
  echo "  -c, --sync-configs       Only sync configuration files."
  echo "  -s, --select             Select which scripts to run from a menu (Pure Bash)."
  echo "  -h, --help               Show this help message."
  echo ""
  echo "Default behavior (no options): Installs base/AUR packages and syncs configs."
}

# --- Argument Parsing ---
ask_before_exec=false
sync_only=false
select_mode=false

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
  -s | --select)
    select_mode=true
    shift
    ;; 
  esac
done

BASE_DIR="$(dirname "$0")"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Function to run a script
run_script() {
  local script_name="$1"
  local script_path="$SCRIPTS_DIR/$script_name"
  
  if [ -f "$script_path" ]; then
    if [ "$ask_before_exec" = true ]; then
      read -p "--- Run script $script_name? (y/n): " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "--- Skipping $script_name ---"
        echo ""
        return
      fi
    fi
    echo "--- Running $script_name ---"
    bash "$script_path" "$BASE_DIR"
    echo "--- Finished $script_name ---"
    echo ""
  else
    echo "--- Warning: Script $script_name not found. Skipping. ---"
    echo ""
  fi
}

echo "Starting installation..."
echo "======================"
echo ""

# Always ensure 07-copyconfigs.sh is NOT in the list of scripts to run manually
# because we will force it to run last.
CONFIG_SCRIPT="07-copyconfigs.sh"

if [ "$select_mode" = true ]; then
  # Pure Bash Selector
  echo "Select scripts to run (enter numbers separated by spaces, e.g., '1 3 5'):" 
  
  # Get all scripts except config script
  mapfile -t ALL_SCRIPTS < <(find "$SCRIPTS_DIR" -maxdepth 1 -name "[0-9]*.sh" ! -name "$CONFIG_SCRIPT" -printf "%f\n" | sort)
  
  PS3="Enter selection (or 'q' to quit selection, 'a' for all): "
  
  # Display options manually since 'select' is a bit rigid for multi-select
  i=1
  for script in "${ALL_SCRIPTS[@]}"; do
    echo "$i) $script"
    ((i++))
  done
  
  echo ""
  read -p "Selections: " -r user_input
  
  SELECTED_SCRIPTS=()
  
  if [[ "$user_input" == "a" ]]; then
      SELECTED_SCRIPTS=("${ALL_SCRIPTS[@]}")
  elif [[ "$user_input" != "q" ]]; then
      for num in $user_input; do
          if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#ALL_SCRIPTS[@]}" ]; then
              idx=$((num-1))
              SELECTED_SCRIPTS+=("${ALL_SCRIPTS[$idx]}")
          fi
      done
  fi
  
  if [ ${#SELECTED_SCRIPTS[@]} -eq 0 ]; then
      echo "No scripts selected (except mandatory config sync)."
  else 
      echo "Selected scripts: ${SELECTED_SCRIPTS[*]}"
      echo ""
      for script in "${SELECTED_SCRIPTS[@]}"; do
        run_script "$script"
      done
  fi

  # Always run config sync last
  run_script "$CONFIG_SCRIPT"

elif [ "$sync_only" = true ]; then
  run_script "$CONFIG_SCRIPT"

else
  # Default behavior: Base Packages + AUR Packages + Config Sync
  echo "Running default installation: Base Packages, AUR Packages, and Config Sync."
  
  run_script "01-base-packages.sh"
  run_script "02-aur-packages.sh"
  
  # Always run config sync last
  run_script "$CONFIG_SCRIPT"
fi

echo "======================"
echo "Installation complete!"