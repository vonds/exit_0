#!/bin/bash

# Lab 494: Preserve System Journals (Persistent systemd-journald Logs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 494: Preserve System Journals"
LAB_ID="lab494"
LAB_XP=49400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab494:~$ "

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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "Your system currently stores logs only in volatile memory."
  center_text "After reboot, all journal logs are lost."
  center_text "You must configure persistent system journals and verify storage."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Check current journal storage
  echo "  Step 1: Verify current journal storage location."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "journalctl | grep /log" && "$cmd1" != "sudo journalctl | grep /log" ]]; then
    print_error "Incorrect. Use: journalctl | grep /log"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Mar 29 15:49:13 rhel-lab494 systemd-journald[318]: Runtime journal (/run/log/journal/2e407637679b477eb3e2a25b8ad9611d) is 820.0K, max 6.4M, 5.6M free."
  echo

  # STEP 2: Edit journald configuration
  echo "  Step 2: Edit journald configuration file."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo vim /etc/systemd/journald.conf" && "$cmd2" != "vim /etc/systemd/journald.conf" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/systemd/journald.conf"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo
  echo "  Locate:"
  echo "    #Storage=auto"
  echo
  echo "  Change to:"
  echo "    Storage=persistent"
  echo
  echo "  (file saved and closed)"
  echo

  # STEP 3: Restart journald
  echo "  Step 3: Restart the journald service."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl restart systemd-journald.service" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart systemd-journald.service"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (systemd-journald restarted)"
  echo

  # STEP 4: Flush volatile logs to disk
  echo "  Step 4: Flush runtime logs to persistent storage."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo journalctl --flush" && "$cmd4" != "journalctl --flush" ]]; then
    print_error "Incorrect. Use: sudo journalctl --flush"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (runtime journal flushed to persistent storage)"
  echo

  # STEP 5: Verify persistent storage path
  echo "  Step 5: Verify logs are now stored persistently."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "journalctl | grep /log" && "$cmd5" != "sudo journalctl | grep /log" ]]; then
    print_error "Incorrect. Use: journalctl | grep /log"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Mar 29 16:53:39 rhel-lab494 systemd-journald[1727]: System journal (/var/log/journal/2e407637679b477eb3e2a25b8ad9611d) is 8.0M, max 4.0G, 3.9G free."
  echo

  # STEP 6: Verify persistent journal directory exists
  echo "  Step 6: Verify persistent journal directory exists."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls /var/log/journal" ]]; then
    print_error "Incorrect. Use: ls /var/log/journal"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "2e407637679b477eb3e2a25b8ad9611d"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified volatile journal storage"
  print_info "- configured persistent logging"
  print_info "- restarted journald safely"
  print_info "- flushed runtime logs"
  print_info "- validated persistent log storage"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done
