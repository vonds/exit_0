#!/bin/bash

# Lab 253: ACLs — create file, assign/remove user perms, reset ACL — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real files/ACLs are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 253: ACLs — setfacl/getfacl practice"
LAB_ID="lab253"
LAB_XP=21240
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated actors and paths (NOT your real system)
OWNER="alice"
FILE_DIR="/srv/project"
FILE_PATH="${FILE_DIR}/report.txt"
DATE_STR="Jul 22 13:40"

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
  center_text "Goal: Create a file and practice ACLs: add read access for bob, grant rw to charles,"
  center_text "remove bob’s entry, then reset all ACLs — verifying with getfacl at each step (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Prepare a working directory (silent on success)
  draw_lab_ui
  echo "  Step 1: Create the working directory (${FILE_DIR}) if it doesn't exist."
  read -p "  lab@lab253:~$ " cmd1
  if [[ "$cmd1" == "mkdir -p ${FILE_DIR}" || "$cmd1" == "sudo mkdir -p ${FILE_DIR}" ]]; then
    :
  else
    print_error "Hint: Create ${FILE_DIR} (use -p)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create the file (silent)
  echo "  Step 2: Create ${FILE_PATH}."
  read -p "  lab@lab253:~$ " cmd2
  if [[ "$cmd2" == "touch ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Use a standard file creation command on ${FILE_PATH}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Show standard permissions via ls -l
  echo "  Step 3: List the file with long format."
  read -p "  lab@lab253:~$ " cmd3
  if [[ "$cmd3" == "ls -l ${FILE_PATH}" ]]; then
    echo "  -rw-r--r-- 1 ${OWNER} ${OWNER} 0 ${DATE_STR} ${FILE_PATH}"
  else
    print_error "Hint: Use long listing on the file path."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Add an ACL granting read access to user 'bob'
  echo "  Step 4: Grant read access to user 'bob' via ACL."
  read -p "  lab@lab253:~$ " cmd4
  if [[ "$cmd4" == "setfacl -m u:bob:r ${FILE_PATH}" || "$cmd4" == "setfacl -m user:bob:r ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Modify ACL to add user bob with read permission."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Verify ACL after adding bob (mask reflects max effective perms)
  echo "  Step 5: Verify the ACL entries."
  read -p "  lab@lab253:~$ " cmd5
  if [[ "$cmd5" == "getfacl ${FILE_PATH}" ]]; then
    echo "  # file: ${FILE_PATH}"
    echo "  # owner: ${OWNER}"
    echo "  # group: ${OWNER}"
    echo "  user::rw-"
    echo "  user:bob:r--"
    echo "  group::r--"
    echo "  mask::r--"
    echo "  other::r--"
  else
    print_error "Hint: Display access control list for the file."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Grant read-write to user 'charles' (mask should become rw-)
  echo "  Step 6: Grant read-write access to user 'charles'."
  read -p "  lab@lab253:~$ " cmd6
  if [[ "$cmd6" == "setfacl -m u:charles:rw ${FILE_PATH}" || "$cmd6" == "setfacl -m user:charles:rw ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Modify ACL to add user charles with rw permissions."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Verify ACL shows charles with rw and mask updated
  echo "  Step 7: Verify ACL reflects charles' rw and updated mask."
  read -p "  lab@lab253:~$ " cmd7
  if [[ "$cmd7" == "getfacl ${FILE_PATH}" ]]; then
    echo "  # file: ${FILE_PATH}"
    echo "  # owner: ${OWNER}"
    echo "  # group: ${OWNER}"
    echo "  user::rw-"
    echo "  user:bob:r--"
    echo "  user:charles:rw-"
    echo "  group::r--"
    echo "  mask::rw-"
    echo "  other::r--"
  else
    print_error "Hint: Use the ACL viewer again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Remove bob's ACL entry
  echo "  Step 8: Remove the named ACL entry for 'bob'."
  read -p "  lab@lab253:~$ " cmd8
  if [[ "$cmd8" == "setfacl -x u:bob ${FILE_PATH}" || "$cmd8" == "setfacl -x user:bob ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Delete the user:bob ACL entry."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Verify only charles remains as a named entry
  echo "  Step 9: Verify ACL after removing bob."
  read -p "  lab@lab253:~$ " cmd9
  if [[ "$cmd9" == "getfacl ${FILE_PATH}" ]]; then
    echo "  # file: ${FILE_PATH}"
    echo "  # owner: ${OWNER}"
    echo "  # group: ${OWNER}"
    echo "  user::rw-"
    echo "  user:charles:rw-"
    echo "  group::r--"
    echo "  mask::rw-"
    echo "  other::r--"
  else
    print_error "Hint: View the ACL again to confirm removal."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 10: Reset (remove) all ACLs back to base permissions
  echo "  Step 10: Remove all extended ACL entries from the file."
  read -p "  lab@lab253:~$ " cmd10
  if [[ "$cmd10" == "setfacl -b ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Use the option that removes all extended ACL entries."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 11: Verify base ACL (no named users, no mask)
  echo "  Step 11: Verify only base permissions remain."
  read -p "  lab@lab253:~$ " cmd11
  if [[ "$cmd11" == "getfacl ${FILE_PATH}" ]]; then
    echo "  # file: ${FILE_PATH}"
    echo "  # owner: ${OWNER}"
    echo "  # group: ${OWNER}"
    echo "  user::rw-"
    echo "  group::r--"
    echo "  other::r--"
  else
    print_error "Hint: Use the ACL viewer one last time."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You created a file, managed ACLs for bob/charles, and reset to base permissions (simulated)."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
