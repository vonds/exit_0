#!/bin/bash

# Lab 154: passwd Password Management (Realistic Admin Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 154: passwd Password Management"
LAB_ID="lab154"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_USER="  lab@lab154:~$ "
PROMPT_ROOT="  root@lab154:~# "

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
  center_text "'Satoshi forgot their password. Force a reset and enforce policy.'"
  center_text "You must reset the password, force change at next login, set aging, and verify status."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Baseline status (evidence first)
  echo "  Step 1: Check current password status for satoshi."
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "passwd -S satoshi" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  satoshi P 05/20/2025 0 99999 7 -1 (Password set, SHA512 crypt.)"
  echo

  # STEP 2: Reset password (admin action)
  echo "  Step 2: Reset satoshi's password."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "passwd satoshi" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Enter new UNIX password: "
  echo "  Retype new UNIX password: "
  echo "  passwd: password updated successfully"
  echo

  # STEP 3: Apply policy in one command
  echo "  Step 3: Apply the password policy for 'satoshi' in one command."
  echo "          Policy from the ticket:"
  echo "          - Force password change at next login"
  echo "          - Minimum days between changes: 7"
  echo "          - Maximum days before expiration: 90"
  echo "          - Warning period: 14 days"
  echo "          - Inactive lock after expiration: 30 days"
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "passwd -e -n 7 -x 90 -w 14 -i 30 satoshi" ]]; then
    print_error "Incorrect."
    print_info "Review the policy values and build the passwd command accordingly."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  passwd: password expiry information changed."
  echo

  # STEP 4: Verify end state (proof for the ticket)
  echo "  Step 4: Verify the final password status reflects policy."
  read -r -p "$PROMPT_ROOT" cmd4
  echo
  if [[ "$cmd4" != "passwd -S satoshi" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  satoshi P 05/20/2025 7 90 14 30 (Password set, SHA512 crypt.)"
  echo

  print_success "Nice work."
  print_info "You reset the password, enforced aging policy, forced a change at next login, and verified status."
  print_info "You earned $LAB_XP XP for completing this lab."
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
  read -r -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
