#!/bin/bash

# Lab 520: Change Passwords and Adjust Password Aging (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 520: Password Changes + Aging Policies (RHCSA)"
LAB_ID="lab520"
LAB_XP=52000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab520:~$ "

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
  center_text "Security policy requires stricter password controls for a local user."
  center_text "You must change a password, inspect shadow aging fields, set and verify"
  center_text "aging rules, force a change at next login, lock/unlock an account, and"
  center_text "set an account expiration date."
  echo
  center_text "Targets:"
  center_text "- passwd (change, expire, lock/unlock)"
  center_text "- /etc/shadow inspection"
  center_text "- chage (min/max/warn/expire date)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create a test user named jdoe (so this lab is self-contained)."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo useradd jdoe" ]]; then
    print_error "Incorrect. Use: sudo useradd jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Set an initial password for jdoe."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo passwd jdoe" ]]; then
    print_error "Incorrect. Use: sudo passwd jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Changing password for user jdoe."
  echo "  New password:"
  echo "  Retype new password:"
  echo "  passwd: all authentication tokens updated successfully."
  echo

  echo "  Step 3: Inspect jdoe's /etc/shadow entry."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo grep '^jdoe:' /etc/shadow" && "$cmd3" != "sudo grep jdoe /etc/shadow" ]]; then
    print_error "Incorrect. Use: sudo grep '^jdoe:' /etc/shadow"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  jdoe:\$6\$pV...REDACTED...:20119:0:99999:7:::"
  echo

  echo "  Step 4: Set maximum password age to 90 days for jdoe."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo chage -M 90 jdoe" ]]; then
    print_error "Incorrect. Use: sudo chage -M 90 jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Set warning period to 7 days for jdoe."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo chage -W 7 jdoe" ]]; then
    print_error "Incorrect. Use: sudo chage -W 7 jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Set minimum days between password changes to 1 day for jdoe."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo chage -m 1 jdoe" ]]; then
    print_error "Incorrect. Use: sudo chage -m 1 jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Verify all aging settings for jdoe."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo chage -l jdoe" && "$cmd7" != "chage -l jdoe" ]]; then
    print_error "Incorrect. Use: sudo chage -l jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last password change                                    : Feb 01, 2026"
  echo "  Password expires                                        : May 02, 2026"
  echo "  Password inactive                                       : never"
  echo "  Account expires                                         : never"
  echo "  Minimum number of days between password change          : 1"
  echo "  Maximum number of days between password change          : 90"
  echo "  Number of days of warning before password expires       : 7"
  echo

  echo "  Step 8: Force jdoe to change their password at next login."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo passwd --expire jdoe" && "$cmd8" != "sudo chage -d 0 jdoe" ]]; then
    print_error "Incorrect. Use: sudo passwd --expire jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Verify jdoe is required to change password."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo chage -l jdoe" && "$cmd9" != "chage -l jdoe" ]]; then
    print_error "Incorrect. Use: sudo chage -l jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last password change                                    : password must be changed"
  echo "  Password expires                                        : password must be changed"
  echo "  Password inactive                                       : never"
  echo "  Account expires                                         : never"
  echo "  Minimum number of days between password change          : 1"
  echo "  Maximum number of days between password change          : 90"
  echo "  Number of days of warning before password expires       : 7"
  echo

  echo "  Step 10: Lock the jdoe account."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo passwd -l jdoe" ]]; then
    print_error "Incorrect. Use: sudo passwd -l jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Locking password for user jdoe."
  echo "  passwd: Success"
  echo

  echo "  Step 11: Verify jdoe is locked in /etc/shadow (look for a leading '!')."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo grep '^jdoe:' /etc/shadow" && "$cmd11" != "sudo grep jdoe /etc/shadow" ]]; then
    print_error "Incorrect. Use: sudo grep '^jdoe:' /etc/shadow"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  jdoe:!\$6\$pV...REDACTED...:0:1:90:7:::"
  echo

  echo "  Step 12: Unlock the jdoe account."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo passwd -u jdoe" ]]; then
    print_error "Incorrect. Use: sudo passwd -u jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Unlocking password for user jdoe."
  echo "  passwd: Success"
  echo

  echo "  Step 13: Set an account expiration date for jdoe (use 2030-12-31)."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo chage -E 2030-12-31 jdoe" ]]; then
    print_error "Incorrect. Use: sudo chage -E 2030-12-31 jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 14: Verify the account expiration date is set."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo chage -l jdoe" && "$cmd14" != "chage -l jdoe" ]]; then
    print_error "Incorrect. Use: sudo chage -l jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last password change                                    : password must be changed"
  echo "  Password expires                                        : password must be changed"
  echo "  Password inactive                                       : never"
  echo "  Account expires                                         : Dec 31, 2030"
  echo "  Minimum number of days between password change          : 1"
  echo "  Maximum number of days between password change          : 90"
  echo "  Number of days of warning before password expires       : 7"
  echo

  echo "  Step 15: Clean up: delete jdoe and remove their home directory."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sudo userdel -r jdoe" ]]; then
    print_error "Incorrect. Use: sudo userdel -r jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- changed passwords with passwd and validated shadow state"
  print_info "- configured password aging (min/max/warn) with chage"
  print_info "- forced password change at next login"
  print_info "- locked and unlocked an account safely"
  print_info "- set and verified an account expiration date"
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
