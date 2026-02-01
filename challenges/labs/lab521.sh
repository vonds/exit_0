#!/bin/bash

# Lab 521: Create, Delete, and Modify Local Groups + Group Memberships (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 521: Local Groups + Memberships (RHCSA)"
LAB_ID="lab521"
LAB_XP=52100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab521:~$ "

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
  center_text "A new project team needs controlled access to shared resources."
  center_text "You must create groups, create users, assign primary/secondary groups,"
  center_text "verify membership, remove membership safely, and delete groups cleanly."
  echo
  center_text "Targets:"
  center_text "- groupadd / groupdel"
  center_text "- useradd / userdel"
  center_text "- usermod (primary + secondary groups)"
  center_text "- gpasswd (remove group members)"
  center_text "- verification using getent, id, groups, /etc/group"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create a group named developers."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo groupadd developers" ]]; then
    print_error "Incorrect. Use: sudo groupadd developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Verify the developers group exists using getent."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "getent group developers" ]]; then
    print_error "Incorrect. Use: getent group developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  developers:x:10050:"
  echo

  echo "  Step 3: Create two users: jdoe and webadmin."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo useradd jdoe && sudo useradd webadmin" ]]; then
    print_error "Incorrect. Use: sudo useradd jdoe && sudo useradd webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 4: Add jdoe to developers as a secondary (supplementary) group."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo usermod -aG developers jdoe" ]]; then
    print_error "Incorrect. Use: sudo usermod -aG developers jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Verify jdoe's group membership using groups."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "groups jdoe" ]]; then
    print_error "Incorrect. Use: groups jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  jdoe : jdoe developers"
  echo

  echo "  Step 6: Change jdoe's primary group to developers."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo usermod -g developers jdoe" ]]; then
    print_error "Incorrect. Use: sudo usermod -g developers jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Verify jdoe now has developers as the primary group (use id)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "id jdoe" ]]; then
    print_error "Incorrect. Use: id jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  uid=1001(jdoe) gid=10050(developers) groups=10050(developers)"
  echo

  echo "  Step 8: Add webadmin to developers as a secondary group."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo usermod -aG developers webadmin" ]]; then
    print_error "Incorrect. Use: sudo usermod -aG developers webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Verify the developers group now shows members (use getent)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "getent group developers" ]]; then
    print_error "Incorrect. Use: getent group developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  developers:x:10050:webadmin"
  echo

  echo "  Step 10: Remove webadmin from the developers group using gpasswd."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo gpasswd -d webadmin developers" ]]; then
    print_error "Incorrect. Use: sudo gpasswd -d webadmin developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removing user webadmin from group developers"
  echo

  echo "  Step 11: Verify webadmin is no longer a member of developers."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "groups webadmin" ]]; then
    print_error "Incorrect. Use: groups webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  webadmin : webadmin"
  echo

  echo "  Step 12: Confirm developers membership list again (getent)."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "getent group developers" ]]; then
    print_error "Incorrect. Use: getent group developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  developers:x:10050:"
  echo

  echo "  Step 13: Remove jdoe from developers as a secondary group by resetting supplementary groups."
  echo "          Set jdoe's supplementary groups to just their own name (jdoe)."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo usermod -G jdoe jdoe" ]]; then
    print_error "Incorrect. Use: sudo usermod -G jdoe jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 14: Restore jdoe's primary group back to jdoe (so groupdel is clean)."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo usermod -g jdoe jdoe" ]]; then
    print_error "Incorrect. Use: sudo usermod -g jdoe jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 15: Delete the developers group."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sudo groupdel developers" ]]; then
    print_error "Incorrect. Use: sudo groupdel developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 16: Verify developers group no longer exists."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "getent group developers" ]]; then
    print_error "Incorrect. Use: getent group developers"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (no output)"
  echo

  echo "  Step 17: Clean up: delete the users jdoe and webadmin and remove their home directories."
  read -p "$PROMPT" cmd17
  echo
  if [[ "$cmd17" != "sudo userdel -r jdoe && sudo userdel -r webadmin" ]]; then
    print_error "Incorrect. Use: sudo userdel -r jdoe && sudo userdel -r webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created and verified a local group"
  print_info "- added users to groups safely (secondary + primary)"
  print_info "- verified membership with groups/id/getent"
  print_info "- removed a user from a group using gpasswd"
  print_info "- cleaned up primary group assignments before deleting groups"
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
