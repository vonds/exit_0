#!/bin/bash

# Lab 472: Rocky Linux 10 — User & Group Administration (RHCSA Focus)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 472: User and Group Administration (Rocky 10)"
LAB_ID="lab472"
LAB_XP=47200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab472:~$ "

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
  center_text "You're performing user and group maintenance on a Rocky Linux 10 system."
  center_text "Accounts must be aged, locked, grouped, renamed, and cleaned up"
  center_text "according to security and policy requirements."
  echo
  center_text "Requirements (type commands exactly):"
  center_text "- Set and remove account expiration"
  center_text "- Create system and regular users"
  center_text "- Assign login shells"
  center_text "- Delete users with home directories"
  center_text "- Force password change on next login"
  center_text "- Manage supplementary and primary groups"
  center_text "- Create, rename, and delete groups"
  center_text "- Lock user accounts"
  center_text "- Configure password warning days"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: set expiration date
  echo "  Step 1: Set account expiration for user jane to March 1, 2030."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo usermod -e 2030-03-01 jane" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 2: add system user
  echo "  Step 2: Create a system user named apachedev."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo useradd --system apachedev" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 3: remove expiration
  echo "  Step 3: Remove account expiration for user jane."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo usermod -e '' jane" && "$cmd3" != "sudo usermod -e '' jane" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 4: create user with shell
  echo "  Step 4: Create user jack with login shell /bin/csh."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo useradd -s /bin/csh jack" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 5: delete user and home
  echo "  Step 5: Delete user jack and remove their home directory."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo userdel -r jack" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 6: force password change
  echo "  Step 6: Force user jane to change password at next login."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo chage --lastday 0 jane" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 7: add supplementary group
  echo "  Step 7: Add user jane to supplementary group developers."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo usermod -aG developers jane" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 8: create group with GID
  echo "  Step 8: Create group cricket with GID 9875."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo groupadd -g 9875 cricket" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 9: rename group
  echo "  Step 9: Rename group cricket to soccer."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo groupmod -n soccer cricket" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 10: create user with group and UID
  echo "  Step 10: Create user sam with UID 5322 and supplementary group soccer."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo useradd -G soccer sam --uid 5322" && \
        "$cmd10" != "sudo useradd --uid 5322 -G soccer sam" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 11: change primary group
  echo "  Step 11: Change sam's primary group to rugby."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo usermod -g rugby sam" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 12: lock user
  echo "  Step 12: Lock user sam's account."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo usermod -L sam" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 13: delete group
  echo "  Step 13: Delete group appdevs."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo groupdel appdevs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 14: set password warning days
  echo "  Step 14: Set password expiry warning to 2 days for user jane."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo chage -W 2 jane" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  print_success "Excellent work."
  print_info "You completed RHCSA user and group administration tasks on Rocky Linux 10:"
  print_info "- managed account expiration and password aging"
  print_info "- created and removed users (system and regular)"
  print_info "- assigned shells, UIDs, and groups"
  print_info "- renamed and deleted groups"
  print_info "- locked accounts for security"
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
