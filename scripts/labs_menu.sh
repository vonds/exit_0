#!/bin/bash
# Sysadmin Lab Menu — Minimal Prompt Mode (no scanning, no names)
# User types the LAB NUMBER, we run lab<N>.sh if it exists.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABS_DIR="$SCRIPT_DIR/../challenges/labs"
SAVE_JSON="$SCRIPT_DIR/../data/.player_save.json"

# Optional helpers (ignored if missing)
source "$SCRIPT_DIR/ui.sh" > /dev/null 2>&1 || true
source "$SCRIPT_DIR/xp.sh" > /dev/null 2>&1 || true

# Read player stats once
if command -v jq >/dev/null 2>&1 && [ -f "$SAVE_JSON" ]; then
  XP=$(jq '.XP' "$SAVE_JSON" 2>/dev/null)
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON" 2>/dev/null)
fi
export XP LEVEL

main_lab_menu() {
  clear
  if type center_draw_stats_panel >/dev/null 2>&1; then
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo; echo
    print_banner "Sysadmin Lab Mode - Linux"
    echo
  else
    echo "Sysadmin Lab Mode - Linux"
    echo
  fi

  while true; do
    echo "    Instructions:"
    echo
    echo "      • Enter the LAB NUMBER you want to run (e.g., 148)."
    echo "      • Lab numbers correspond directly to filenames (lab<N>.sh)."
    echo "      • Type 'q' to return."
    echo
    printf "     Which lab would you like to do? > "
    read -r choice

    case "$choice" in
      q|Q|quit|exit|back) return ;;
    esac

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
      echo
      echo "     Invalid input. Please enter a numeric LAB NUMBER (e.g., 148)."
      echo
      continue
    fi

    lab_file="$LABS_DIR/lab${choice}.sh"

    if [ ! -f "$lab_file" ]; then
      echo
      echo "     Lab file not found: $lab_file"
      echo "     Make sure the file exists (lab${choice}.sh)."
      echo
      continue
    fi

    echo
    echo "     Launching $lab_file"
    echo
    bash "$lab_file"
    echo
  done
}

main_lab_menu
