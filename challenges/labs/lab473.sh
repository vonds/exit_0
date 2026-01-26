#!/bin/bash

# Lab 473: Rocky Linux 10 — Root Account Control & PAM su Hardening (RHCSA Focus)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 473: Root Password & PAM su Hardening (Rocky 10)"
LAB_ID="lab473"
LAB_XP=47300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab473:~$ "

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
  center_text "You are hardening privilege escalation controls on a Rocky Linux 10 system."
  center_text "You must manage the root account state and restrict su access using PAM."
  echo
  center_text "Requirements (type commands and file entries EXACTLY):"
  center_text "- Unlock and lock the root account"
  center_text "- Set a root password"
  center_text "- Restrict su access to wheel members"
  center_text "- Trust wheel group via PAM"
  center_text "- Deny specific users using pam_listfile"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: unlock root
  echo "  Step 1: Unlock the root account."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo passwd -u root" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Unlocking password for user root."
  echo "  passwd: Success"
  echo

  # STEP 2: set root password
  echo "  Step 2: Set a password for the root user."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo passwd root" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Changing password for user root."
  echo "  New password:"
  echo "  Retype new password:"
  echo "  passwd: all authentication tokens updated successfully."
  echo

  # STEP 3: lock root
  echo "  Step 3: Lock the root account."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo passwd --lock root" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Locking password for user root."
  echo "  passwd: Success"
  echo

  # STEP 4: edit /etc/pam.d/su
  echo "  Step 4: Open /etc/pam.d/su using vim."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo vim /etc/pam.d/su" && "$cmd4" != "sudo vi /etc/pam.d/su" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  # STEP 5: uncomment pam_wheel required
  echo "  Step 5: In the file, uncomment and ensure this line EXACTLY:"
  read -p "  > " pam1
  if [[ "$pam1" != "auth           required        pam_wheel.so use_uid" ]]; then
    print_error "Incorrect PAM line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 6: uncomment pam_wheel sufficient
  echo "  Step 6: Also uncomment and ensure this line EXACTLY:"
  read -p "  > " pam2
  if [[ "$pam2" != "auth           sufficient      pam_wheel.so trust use_uid" ]]; then
    print_error "Incorrect PAM line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 7: add pam_listfile line
  echo "  Step 7: Add the following line at the END of the file:"
  read -p "  > " pam3
  if [[ "$pam3" != "auth    required       pam_listfile.so onerr=succeed  item=user  sense=deny  file=/etc/ssh/deniedusers" ]]; then
    print_error "Incorrect PAM listfile line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  # STEP 8: create deniedusers file
  echo "  Step 8: Create /etc/ssh/deniedusers with vim."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo vim /etc/ssh/deniedusers" && "$cmd8" != "sudo vi /etc/ssh/deniedusers" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  # STEP 9: add root to deniedusers
  echo "  Step 9: In the file, add the following content EXACTLY:"
  read -p "  > " deny1
  if [[ "$deny1" != "root" ]]; then
    print_error "Incorrect file content."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  print_success "Excellent work."
  print_info "You completed RHCSA-level security hardening on Rocky Linux 10:"
  print_info "- managed root password state (unlock, set, lock)"
  print_info "- restricted su access using pam_wheel"
  print_info "- enforced user denial using pam_listfile"
  print_info "- practiced precise PAM file editing"
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
