#!/bin/bash

# Lab 248: Modify user200 → user200new (UID, home, shell) and remove — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/groups/files are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 248: Rename + retune user, then remove"
LAB_ID="lab248"
LAB_XP=20920
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated, not your real system:
OLDUSER="user200"
NEWUSER="user200new"
OLDUID=1200
NEWUID=2200
OLDHOME="/home/${OLDUSER}"
NEWHOME="/home/staff/${NEWUSER}"
OLDSHELL="/bin/bash"
NEWSHELL="/bin/zsh"
OLDGID=1200           # primary group stays as-is in this lab
DATE_STR="Jul 22 12:55"

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
  center_text "Goal: Inspect ${OLDUSER}, rename to ${NEWUSER}, change UID, move home, change shell, verify, then remove the account (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Inspect current passwd entry
  draw_lab_ui
  echo "  Step 1: Show the current account record for ${OLDUSER}."
  read -p "  lab@lab248:~$ " cmd1
  if [[ "$cmd1" == "getent passwd ${OLDUSER}" || "$cmd1" == "grep '^${OLDUSER}:' /etc/passwd" ]]; then
    echo "  ${OLDUSER}:x:${OLDUID}:${OLDGID}::${OLDHOME}:${OLDSHELL}"
  else
    print_error "Hint: Query the passwd database for ${OLDUSER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Inspect current IDs
  echo "  Step 2: Display numeric IDs and primary group for ${OLDUSER}."
  read -p "  lab@lab248:~$ " cmd2
  if [[ "$cmd2" == "id ${OLDUSER}" ]]; then
    echo "  uid=${OLDUID}(${OLDUSER}) gid=${OLDGID}(${OLDUSER}) groups=${OLDGID}(${OLDUSER})"
  else
    print_error "Hint: Use the standard identity command on ${OLDUSER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Rename the login (silent on success)
  echo "  Step 3: Change the login name from ${OLDUSER} to ${NEWUSER}."
  read -p "  lab@lab248:~$ " cmd3
  if [[ "$cmd3" == "usermod -l ${NEWUSER} ${OLDUSER}" || "$cmd3" == "sudo usermod -l ${NEWUSER} ${OLDUSER}" ]]; then
    :
  else
    print_error "Hint: Use the login rename option for usermod."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify renamed account appears
  echo "  Step 4: Verify the renamed account exists."
  read -p "  lab@lab248:~$ " cmd4
  if [[ "$cmd4" == "getent passwd ${NEWUSER}" ]]; then
    echo "  ${NEWUSER}:x:${OLDUID}:${OLDGID}::${OLDHOME}:${OLDSHELL}"
  else
    print_error "Hint: Query the passwd database for ${NEWUSER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Change the UID (silent)
  echo "  Step 5: Change the numeric UID for ${NEWUSER}."
  read -p "  lab@lab248:~$ " cmd5
  if [[ "$cmd5" == "usermod -u ${NEWUID} ${NEWUSER}" || "$cmd5" == "sudo usermod -u ${NEWUID} ${NEWUSER}" ]]; then
    :
  else
    print_error "Hint: Adjust the UID with usermod."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Move the home directory to the new path (silent)
  echo "  Step 6: Move the home directory to ${NEWHOME}."
  read -p "  lab@lab248:~$ " cmd6
  if [[ "$cmd6" == "usermod -d ${NEWHOME} -m ${NEWUSER}" || "$cmd6" == "sudo usermod -d ${NEWHOME} -m ${NEWUSER}" ]]; then
    :
  else
    print_error "Hint: Provide a new home path and migrate content."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Change the login shell (silent)
  echo "  Step 7: Change the login shell for ${NEWUSER}."
  read -p "  lab@lab248:~$ " cmd7
  if [[ "$cmd7" == "usermod -s ${NEWSHELL} ${NEWUSER}" || "$cmd7" == "sudo usermod -s ${NEWSHELL} ${NEWUSER}" ]]; then
    :
  else
    print_error "Hint: Specify the shell path with usermod."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Verify final account state
  echo "  Step 8: Verify the updated passwd entry for ${NEWUSER}."
  read -p "  lab@lab248:~$ " cmd8a
  if [[ "$cmd8a" == "getent passwd ${NEWUSER}" ]]; then
    echo "  ${NEWUSER}:x:${NEWUID}:${OLDGID}::${NEWHOME}:${NEWSHELL}"
  else
    print_error "Hint: Query the passwd database again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 8 (cont.): Check IDs after changes."
  read -p "  lab@lab248:~$ " cmd8b
  if [[ "$cmd8b" == "id ${NEWUSER}" ]]; then
    echo "  uid=${NEWUID}(${NEWUSER}) gid=${OLDGID}(${OLDUSER}) groups=${OLDGID}(${OLDUSER})"
  else
    print_error "Hint: Use the identity command on ${NEWUSER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 8 (cont.): Confirm new home directory exists."
  read -p "  lab@lab248:~$ " cmd8c
  if [[ "$cmd8c" == "ls -ld ${NEWHOME}" ]]; then
    echo "  drwx------ 2 ${NEWUSER} ${OLDUSER} 4096 ${DATE_STR} ${NEWHOME}"
  else
    print_error "Hint: List the directory metadata for ${NEWHOME}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Optional: note about file ownership reconciliation (bonus)
  echo "  Step 9 (optional): Find files still owned by old UID and fix ownership."
  read -p "  lab@lab248:~$ " cmd9
  if [[ "$cmd9" == "find / -xdev -uid ${OLDUID} -exec chown -h ${NEWUID} {} +" || "$cmd9" == "" ]]; then
    :
  else
    print_error "Hint: You can search by old UID and chown to the new UID (or press Enter to skip)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 10: Remove the account and its home directory (silent)
  echo "  Step 10: Remove ${NEWUSER} and their home directory."
  read -p "  lab@lab248:~$ " cmd10
  if [[ "$cmd10" == "userdel -r ${NEWUSER}" || "$cmd10" == "sudo userdel -r ${NEWUSER}" ]]; then
    :
  else
    print_error "Hint: Use the removal command that also deletes the home directory."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 11: Verify removal
  echo "  Step 11: Verify the account is gone."
  read -p "  lab@lab248:~$ " cmd11
  if [[ "$cmd11" == "id ${NEWUSER}" ]]; then
    echo "  id: ‘${NEWUSER}’: no such user"
  elif [[ "$cmd11" == "getent passwd ${NEWUSER}" ]]; then
    # getent prints nothing when user doesn't exist; simulate no output
    :
  else
    print_error "Hint: Try an identity or passwd database lookup for ${NEWUSER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! You renamed the account, adjusted UID/home/shell, verified changes, and removed it (simulated)."
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
