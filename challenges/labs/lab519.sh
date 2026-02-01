#!/bin/bash

# Lab 519: Create, Delete, and Modify Local User Accounts (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 519: Manage Local User Accounts (RHCSA)"
LAB_ID="lab519"
LAB_XP=51900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab519:~$ "

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
  center_text "You are onboarding and maintaining local accounts on a RHEL-like system."
  center_text "You must create users with correct defaults, customize accounts,"
  center_text "modify attributes safely, verify results via system databases, and clean up."
  echo
  center_text "Targets:"
  center_text "- useradd / passwd"
  center_text "- /etc/passwd verification"
  center_text "- usermod (home move + shell)"
  center_text "- chage password aging"
  center_text "- userdel -r cleanup"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create a new user account named jdoe (defaults)."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo useradd jdoe" ]]; then
    print_error "Incorrect. Use: sudo useradd jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Set a password for user jdoe."
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

  echo "  Step 3: Verify jdoe exists in /etc/passwd."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "grep '^jdoe:' /etc/passwd" && "$cmd3" != "grep jdoe /etc/passwd" ]]; then
    print_error "Incorrect. Use: grep '^jdoe:' /etc/passwd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  jdoe:x:1001:1001::/home/jdoe:/bin/bash"
  echo

  echo "  Step 4: Create user webadmin with home directory /webadmin and shell /bin/sh."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo useradd -m -d /webadmin -s /bin/sh webadmin" ]]; then
    print_error "Incorrect. Use: sudo useradd -m -d /webadmin -s /bin/sh webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Set a password for user webadmin."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo passwd webadmin" ]]; then
    print_error "Incorrect. Use: sudo passwd webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Changing password for user webadmin."
  echo "  New password:"
  echo "  Retype new password:"
  echo "  passwd: all authentication tokens updated successfully."
  echo

  echo "  Step 6: Verify webadmin details in /etc/passwd."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "grep '^webadmin:' /etc/passwd" && "$cmd6" != "grep webadmin /etc/passwd" ]]; then
    print_error "Incorrect. Use: grep '^webadmin:' /etc/passwd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  webadmin:x:1002:1002::/webadmin:/bin/sh"
  echo

  echo "  Step 7: Modify jdoe: move home to /home/dev/jdoe and set shell to /bin/zsh."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo usermod -d /home/dev/jdoe -m -s /bin/zsh jdoe" ]]; then
    print_error "Incorrect. Use: sudo usermod -d /home/dev/jdoe -m -s /bin/zsh jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Verify jdoe updates in /etc/passwd."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "grep '^jdoe:' /etc/passwd" && "$cmd8" != "grep jdoe /etc/passwd" ]]; then
    print_error "Incorrect. Use: grep '^jdoe:' /etc/passwd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  jdoe:x:1001:1001::/home/dev/jdoe:/bin/zsh"
  echo

  echo "  Step 9: Set webadmin password max age to 90 days."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo chage -M 90 webadmin" ]]; then
    print_error "Incorrect. Use: sudo chage -M 90 webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Verify password aging settings for webadmin."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo chage -l webadmin" && "$cmd10" != "chage -l webadmin" ]]; then
    print_error "Incorrect. Use: sudo chage -l webadmin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last password change                                    : Feb 01, 2026"
  echo "  Password expires                                        : May 02, 2026"
  echo "  Password inactive                                       : never"
  echo "  Account expires                                         : never"
  echo "  Minimum number of days between password change          : 0"
  echo "  Maximum number of days between password change          : 90"
  echo "  Number of days of warning before password expires       : 7"
  echo

  echo "  Step 11: Delete user jdoe and remove their home directory."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo userdel -r jdoe" ]]; then
    print_error "Incorrect. Use: sudo userdel -r jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 12: Verify jdoe no longer exists in /etc/passwd."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "grep '^jdoe:' /etc/passwd" && "$cmd12" != "getent passwd jdoe" ]]; then
    print_error "Incorrect. Use: getent passwd jdoe"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (no output)"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created local users with defaults and custom options"
  print_info "- set passwords safely using passwd"
  print_info "- verified account state via /etc/passwd"
  print_info "- modified home directories and shells with usermod -m"
  print_info "- enforced password aging with chage"
  print_info "- deleted users cleanly with userdel -r"
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
