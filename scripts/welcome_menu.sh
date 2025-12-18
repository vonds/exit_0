#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

# Menu options
options=(" Start " " Exit ")
selected=0

# Helper to center plain text
center_text() {
  local text="$1"
  local width=$(tput cols)
  local padding=$(( (width - ${#text}) / 2 ))
  printf "%*s%s\n" "$padding" "" "$text"
}


center_option() {
  local display="$1"
  local visual="${2:-$1}"
  local width=$(tput cols)
  local padding=$(( (width - ${#visual}) / 2 ))
  printf "%*s%s\n" "$padding" "" "$display"
}

draw_menu() {
  clear
  echo#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

HIGHLIGHT=$(tput smso)
NORMAL=$(tput rmso)

# Menu options
options=(" Start " " Exit ")
selected=0

draw_menu() {
  clear
  echo
  echo
  echo
  echo
  echo

  # Draw title using shared UI function
  draw_colored_title

  echo
  echo
  center_text "Use ↑ ↓ to move, and press Enter to select"
  echo

  for i in "${!options[@]}"; do
    if [[ $i -eq $selected ]]; then
      center_option "${HIGHLIGHT}${options[$i]}${NORMAL}" "${options[$i]}"
    else
      center_option "${options[$i]}" "${options[$i]}"
    fi
  done
}

# Main input loop
while true; do
  draw_menu

  IFS= read -rsn1 key
  if [[ $key == $'\x1b' ]]; then
    read -rsn2 -t 0.01 key_tail
    key+=$key_tail
  fi

  case "$key" in
    $'\x1b[A') # Up arrow
      ((selected--))
      [[ $selected -lt 0 ]] && selected=$((${#options[@]} - 1))
      ;;
    $'\x1b[B') # Down arrow
      ((selected++))
      [[ $selected -ge ${#options[@]} ]] && selected=0
      ;;
    "") # Enter
      case $selected in
        0)
          clear
          echo
          echo
          echo
          echo
          echo
          echo
          echo
          echo
          center_text "Loading..."
          sleep 1
          exec "$SCRIPT_DIR/start_game.sh"
          ;;
        1)
          clear
          center_text "Application Closed"
          sleep 1
          exit 0
          ;;
      esac
      ;;
  esac
done

  echo
  echo
  echo
  echo

  # 24-bit color escape for background #079aa5 and white foreground
  TITLE_COLOR="\033[48;2;7;154;165m\033[38;2;255;255;255m"
  RESET="\033[0m"

  center_text "${TITLE_COLOR}░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓████████▓▒░▒▓████████▓▒░${RESET}"
  center_text "${TITLE_COLOR}░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░${RESET}"
  center_text "${TITLE_COLOR}░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░${RESET}"
  center_text "${TITLE_COLOR}░▒▓██████▓▒░  ░▒▓██████▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░${RESET}"
  center_text "${TITLE_COLOR}░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░${RESET}"
  center_text "${TITLE_COLOR}░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░${RESET}"
  center_text "${TITLE_COLOR}░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓████████▓▒░${RESET}"

  echo
  echo
  center_text "Use ↑ ↓ to move, and press Enter to select"
  echo

  for i in "${!options[@]}"; do
    if [[ $i -eq $selected ]]; then
      center_option "${HIGHLIGHT}${options[$i]}${NORMAL}" "${options[$i]}"
    else
      center_option "${options[$i]}" "${options[$i]}"
    fi
  done
}

# Main input loop
while true; do
  draw_menu

  IFS= read -rsn1 key
  if [[ $key == $'\x1b' ]]; then
    read -rsn2 -t 0.01 key_tail
    key+=$key_tail
  fi

  case "$key" in
    $'\x1b[A') # Up arrow
      ((selected--))
      [[ $selected -lt 0 ]] && selected=$((${#options[@]} - 1))
      ;;
    $'\x1b[B') # Down arrow
      ((selected++))
      [[ $selected -ge ${#options[@]} ]] && selected=0
      ;;
    "") # Enter
      case $selected in
        0)
          clear
          echo
          echo
          echo
          echo
          echo
          echo
          echo
          echo
          center_text "Loading..."
          sleep 1
          exec "$SCRIPT_DIR/start_game.sh"
          ;;
        1)
          clear
          center_text "Application Closed"
          sleep 1
          exit 0
          ;;
      esac
      ;;
  esac
done
