#!/bin/bash

# Lab 541W: Configure ACLs for User Access on a File (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541W: Configure ACLs for User Access on a File"
LAB_ID="lab541w"
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
  center_text "A copy of /etc/fstab must be placed in /var/tmp and modified"
  center_text "so user alex can read and write the file without changing"
  center_text "the file owner or group owner."
  echo
  center_text "Requirements:"
  center_text "- Copy /etc/fstab to /var/tmp/fstab_copy"
  center_text "- Give alex read and write access"
  center_text "- Preserve existing group and other permissions"
  center_text "- Do not change owner or group owner"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Copy /etc/fstab to /var/tmp/fstab_copy."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo cp /etc/fstab /var/tmp/fstab_copy" ]]; then
    print_error "Incorrect. Use: sudo cp /etc/fstab /var/tmp/fstab_copy"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [no output]"
  echo

  echo "  Step 2: Verify the copied file and its standard permissions."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "ls -l /var/tmp/fstab_copy" ]]; then
    print_error "Incorrect. Use: ls -l /var/tmp/fstab_copy"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-r--r--. 1 root root 612 Mar 15 11:24 /var/tmp/fstab_copy"
  echo

  echo "  Step 3: Grant user alex read and write access using an ACL."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo setfacl -m u:alex:rw /var/tmp/fstab_copy" ]]; then
    print_error "Incorrect. Use: sudo setfacl -m u:alex:rw /var/tmp/fstab_copy"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [no output]"
  echo

  echo "  Step 4: Display the ACLs on the file."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "getfacl /var/tmp/fstab_copy" ]]; then
    print_error "Incorrect. Use: getfacl /var/tmp/fstab_copy"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  # file: var/tmp/fstab_copy"
  echo "  # owner: root"
  echo "  # group: root"
  echo "  user::rw-"
  echo "  user:alex:rw-"
  echo "  group::r--"
  echo "  mask::rw-"
  echo "  other::r--"
  echo

  echo "  Step 5: Verify the owner and group owner have not changed."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "ls -l /var/tmp/fstab_copy" ]]; then
    print_error "Incorrect. Use: ls -l /var/tmp/fstab_copy"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-rw-r--+ 1 root root 612 Mar 15 11:24 /var/tmp/fstab_copy"
  echo

  echo "  Step 6: Confirm alex now has read and write access through the ACL."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "getfacl /var/tmp/fstab_copy | grep alex" ]]; then
    print_error "Incorrect. Use: getfacl /var/tmp/fstab_copy | grep alex"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  user:alex:rw-"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- copied /etc/fstab to /var/tmp/fstab_copy"
  print_info "- granted alex read and write access with an ACL"
  print_info "- preserved the file owner and group owner"
  print_info "- preserved the existing base group and other permissions"
  print_info "- verified the ACL configuration"
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