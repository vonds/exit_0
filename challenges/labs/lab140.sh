#!/bin/bash

# Lab 140: RHCSA User Management — Provisioning, Groups, Aging, Locking

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 140: RHCSA User Provisioning and Account Management"
LAB_ID="lab140"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab140:~$ "

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
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
  center_text "Ticket INC-140: Provision a temporary contractor account."
  center_text "You must create, configure, verify, secure, and later remove the account."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Display the system defaults for user creation."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "useradd -D" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  GROUP=100"
  echo "  HOME=/home"
  echo "  INACTIVE=-1"
  echo "  EXPIRE="
  echo "  SHELL=/bin/bash"
  echo "  SKEL=/etc/skel"
  echo "  CREATE_MAIL_SPOOL=yes"
  echo

  # STEP 2
  echo "  Step 2: Ensure required groups exist (developers, docker)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo groupadd -f developers && sudo groupadd -f docker" && \
        "$cmd2" != "groupadd -f developers && groupadd -f docker" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 3
  echo "  Step 3: Create user 'satoshi' with:"
  echo "          UID 1055, primary group developers,"
  echo "          supplementary groups wheel,docker,"
  echo "          comment 'Satoshi Nakamoto'."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo useradd -m -u 1055 -g developers -G wheel,docker -c 'Satoshi Nakamoto' satoshi" && \
        "$cmd3" != "sudo useradd -m -u 1055 -g developers -G docker,wheel -c 'Satoshi Nakamoto' satoshi" && \
        "$cmd3" != "useradd -m -u 1055 -g developers -G wheel,docker -c 'Satoshi Nakamoto' satoshi" && \
        "$cmd3" != "useradd -m -u 1055 -g developers -G docker,wheel -c 'Satoshi Nakamoto' satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 4
  echo "  Step 4: Set a password for satoshi."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo passwd satoshi" && "$cmd4" != "passwd satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Changing password for user satoshi."
  echo "  New password:"
  echo "  Retype new password:"
  echo "  passwd: all authentication tokens updated successfully."
  echo

  # STEP 5
  echo "  Step 5: Verify the passwd entry using NSS."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "getent passwd satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  satoshi:x:1055:1001:Satoshi Nakamoto:/home/satoshi:/bin/bash"
  echo

  # STEP 6
  echo "  Step 6: Verify group membership."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "id satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  uid=1055(satoshi) gid=1001(developers) groups=1001(developers),10(wheel),993(docker)"
  echo

  # STEP 7
  echo "  Step 7: Set password maximum age to 90 days."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "sudo chage -M 90 satoshi" && "$cmd7" != "chage -M 90 satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 8
  echo "  Step 8: Display password aging information."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "chage -l satoshi" && "$cmd8" != "sudo chage -l satoshi" ]]; then
    print_error "Incorrect."
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

  # STEP 9
  echo "  Step 9: Lock the account."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "sudo usermod -L satoshi" && "$cmd9" != "usermod -L satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 10
  echo "  Step 10: Unlock the account."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "sudo usermod -U satoshi" && "$cmd10" != "usermod -U satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 11
  echo "  Step 11: Verify the user's home directory exists."
  read -p "$PROMPT" cmd11
  echo

  if [[ "$cmd11" != "ls -ld /home/satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  drwx------. 2 satoshi developers 96 Feb 1 08:12 /home/satoshi"
  echo

  # STEP 12
  echo "  Step 12: Remove the contractor account and its home directory."
  read -p "$PROMPT" cmd12
  echo

  if [[ "$cmd12" != "sudo userdel -r satoshi" && "$cmd12" != "userdel -r satoshi" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  userdel: removing user 'satoshi'"
  echo

  print_success "Excellent work."
  print_info "You completed  core RHCSA user administration tasks"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done