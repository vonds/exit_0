#!/bin/bash

# Lab 56: Using the 'screen' Command for Persistent Terminal Sessions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 56: Persistent Sessions with screen"
LAB_ID="lab56"
LAB_XP=11250
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo; echo; echo
}

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

SESSION_NAME="devsession"

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "You are performing a long upgrade process on a remote server."
  center_text "To prevent losing progress if disconnected, use the 'screen' command."
  echo
  center_text "Press Enter to begin the lab..."
  read _

  draw_lab_ui
  echo "  Step 1: Start a new screen session named '$SESSION_NAME'."
  read -p "  lab@lpic-lab56:~$ " cmd1
  echo
  [[ "$cmd1" != "screen -S $SESSION_NAME" ]] && {
    print_error "Incorrect. Use: screen -S $SESSION_NAME"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Screen session '$SESSION_NAME' started."
  echo

  echo "  Step 2: Detach from the screen session."
  read -p "  lab@lpic-lab56:~$ " cmd2
  echo
  [[ "$cmd2" != "ctrl+a then d" ]] && {
    print_error "Incorrect. Detach using: Ctrl+a then d"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Detached from '$SESSION_NAME'."
  echo

  echo "  Step 3: Reattach to the screen session."
  read -p "  lab@lpic-lab56:~$ " cmd3
  echo
  [[ "$cmd3" != "screen -r $SESSION_NAME" ]] && {
    print_error "Incorrect. Use: screen -r $SESSION_NAME"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Reattached to screen session."
  echo

  echo "  Step 4: List available screen sessions."
  read -p "  lab@lpic-lab56:~$ " cmd4
  echo
  [[ "$cmd4" != "screen -ls" ]] && {
    print_error "Incorrect. Use: screen -ls"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  There is a screen on:
	11234.$SESSION_NAME	(Detached)
  1 Socket in /run/screen/S-user."
  echo

  echo "  Step 5: Kill the screen session."
  read -p "  lab@lpic-lab56:~$ " cmd5
  echo
  [[ "$cmd5" != "screen -S $SESSION_NAME -X quit" ]] && {
    print_error "Incorrect. Use: screen -S $SESSION_NAME -X quit"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Session '$SESSION_NAME' terminated."
  echo

  print_success "Great work! You used screen like a pro."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice

  [[ "$post_choice" == "2" ]] && exit 0

done
