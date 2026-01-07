#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABS_DIR="$SCRIPT_DIR/../challenges/labs"
SAVE_JSON="$SCRIPT_DIR/../data/.player_save.json"

# Optional helpers (ignored if missing)
source "$SCRIPT_DIR/ui.sh" > /dev/null 2>&1 || true
source "$SCRIPT_DIR/xp.sh" > /dev/null 2>&1 || true

# Read player stats once
XP=0
LEVEL=1
if command -v jq >/dev/null 2>&1 && [ -f "$SAVE_JSON" ]; then
  XP=$(jq -r '.XP // 0' "$SAVE_JSON" 2>/dev/null)
  LEVEL=$(jq -r '.LEVEL // 1' "$SAVE_JSON" 2>/dev/null)
fi
export XP LEVEL

# Drain any pending buffered input (macOS bash-safe: no fractional -t)
drain_stdin() {
  local _junk
  [ -t 0 ] || return 0
  while IFS= read -r -t 0 -n 1 _junk 2>/dev/null; do :; done
}

pause() {
  drain_stdin
  read -r -p "     Press Enter to continue... " _
}

draw_header() {
  clear
  if type center_draw_stats_panel >/dev/null 2>&1; then
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
    print_banner "Sysadmin Lab Mode - Linux"
    echo
  else
    echo "Sysadmin Lab Mode - Linux"
    echo
  fi
}

reload_stats() {
  if command -v jq >/dev/null 2>&1 && [ -f "$SAVE_JSON" ]; then
    XP=$(jq -r '.XP // 0' "$SAVE_JSON" 2>/dev/null)
    LEVEL=$(jq -r '.LEVEL // 1' "$SAVE_JSON" 2>/dev/null)
    export XP LEVEL
  fi
}

main_lab_menu() {
  draw_header

  while true; do
    echo "     What would you like to do?"
    echo
    echo "       1) Run a lab by number"
    echo "       2) Help / examples"
    echo
    echo "     Press Enter 2x to return to main menu"
    echo

    drain_stdin
    printf "     Select an option (1 or 2): "
    IFS= read -r menu_choice

    # If user presses Enter with no input, return to the parent menu immediately
    if [[ -z "$menu_choice" ]]; then
      drain_stdin
      return
    fi

    case "$menu_choice" in
      1)
        while true; do
          echo
          echo "     Enter a lab number (example: 148)"
          echo "     Or type 'b' to go back."
          echo

          drain_stdin
          printf "     Lab # > "
          IFS= read -r choice

          case "$choice" in
            b|B|back)
              draw_header
              break
              ;;
            "" )
              # Enter here also backs out to the lab menu (same as 'b')
              draw_header
              break
              ;;
            q|Q|quit|exit)
              return
              ;;
          esac

          if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            echo
            echo "     Invalid input. Please enter a number like 148."
            echo
            pause
            draw_header
            continue
          fi

          lab_file="$LABS_DIR/lab${choice}.sh"

          if [ ! -f "$lab_file" ]; then
            echo
            echo "     Lab not found: lab${choice}.sh"
            echo "     Expected path: $lab_file"
            echo
            pause
            draw_header
            continue
          fi

          echo
          echo "     Launching: lab${choice}.sh"
          echo

          bash "$lab_file"
          drain_stdin

          reload_stats
          draw_header
        done
        ;;
      2)
        echo
        echo "     Help / examples"
        echo
        echo "       • Run lab 148: choose 1, then type 148"
        echo "       • Back to this menu: type b (or press Enter at the lab # prompt)"
        echo "       • Return to main menu: press Enter 2x"
        echo
        pause
        draw_header
        ;;
      *)
        echo
        echo "     Invalid selection. Choose 1 or 2, or press Enter 2x to return."
        echo
        pause
        draw_header
        ;;
    esac
  done
}

main_lab_menu
