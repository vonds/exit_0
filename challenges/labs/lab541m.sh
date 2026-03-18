#!/bin/bash

# Lab 541M: Configure a Collaboration Directory with SetGID (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541M: Configure a Collaboration Directory with SetGID"
LAB_ID="lab541m"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "ServerA needs a shared collaboration directory for developers."
  center_text "Create the group and directory, assign the correct ownership,"
  center_text "restrict access for others, and ensure new files inherit the"
  center_text "developers group automatically."
  echo

  center_text "Requirements:"
  center_text "- Group name: developers"
  center_text "- Directory: /opt/dev-data"
  center_text "- Owner and group: rwx"
  center_text "- Others: no access"
  center_text "- New files must inherit group ownership developers"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Check whether the developers group already exists."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "getent group developers" ]]; then
    print_error "Incorrect. Use: getent group developers"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo
  echo "  Step 2: Create the developers group."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo groupadd developers" ]]; then
    print_error "Incorrect. Use: sudo groupadd developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Verify the developers group now exists."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "getent group developers" ]]; then
    print_error "Incorrect. Use: getent group developers"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  developers:x:1002:"
  echo

  echo "  Step 4: Create the collaboration directory /opt/dev-data."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo mkdir -p /opt/dev-data" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /opt/dev-data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Set the group ownership of /opt/dev-data to developers."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo chgrp developers /opt/dev-data" ]]; then
    print_error "Incorrect. Use: sudo chgrp developers /opt/dev-data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Set permissions so owner and group have rwx, and others have no access."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo chmod 770 /opt/dev-data" ]]; then
    print_error "Incorrect. Use: sudo chmod 770 /opt/dev-data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Set the SetGID bit on /opt/dev-data so new files inherit the developers group."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "sudo chmod g+s /opt/dev-data" ]]; then
    print_error "Incorrect. Use: sudo chmod g+s /opt/dev-data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Verify the directory ownership and permissions."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "ls -ld /opt/dev-data" ]]; then
    print_error "Incorrect. Use: ls -ld /opt/dev-data"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  drwxrws---. 2 root developers 6 Mar 14 13:20 /opt/dev-data"
  echo

  echo "  Step 9: Create a test file inside /opt/dev-data to verify inherited group ownership."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "sudo touch /opt/dev-data/testfile" ]]; then
    print_error "Incorrect. Use: sudo touch /opt/dev-data/testfile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Verify the new file inherited the developers group."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "ls -l /opt/dev-data/testfile" ]]; then
    print_error "Incorrect. Use: ls -l /opt/dev-data/testfile"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  -rw-r--r--. 1 root developers 0 Mar 14 13:21 /opt/dev-data/testfile"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created the developers group"
  print_info "- created the /opt/dev-data collaboration directory"
  print_info "- assigned group ownership to developers"
  print_info "- configured rwx access for owner and group only"
  print_info "- set the SetGID bit for inherited group ownership"
  print_info "- verified new files inherit the developers group"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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