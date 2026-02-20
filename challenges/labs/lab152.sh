#!/bin/bash

# Lab 152: userdel User Account Deletion (Realistic Admin Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 152: userdel User Account Deletion"
LAB_ID="lab152"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab152:~$ "

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
  center_text "Amina has left the company."
  center_text "You have been tasked with removing" 
  center_text "her access immediately and cleaning up the account."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Verify the account exists (avoid deleting the wrong user)
  echo "  Step 1: Verify the account exists and capture UID/home for the ticket."
  read -r -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "getent passwd amina" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  amina:x:1055:1055:Amina Hassan:/home/amina:/bin/bash"
  echo

  # STEP 2: Confirm user is not currently logged in (or you’re about to force-kill sessions)
  echo "  Step 2: Confirm whether amina has an active session."
  read -r -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "who | grep amina" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi

  # STEP 3: Delete the account like a real offboarding (remove home + mail spool)
  echo "  Step 3: Delete the account and remove the home directory."
  read -r -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo userdel -r amina" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi


  # STEP 4: Verify removal (account + home)
  echo "  Step 4: Verify the account no longer exists and the home directory is gone."
  read -r -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "getent passwd amina" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi

  echo "  Step 5: Confirm /home/amina is removed."
  read -r -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls -ld /home/amina" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  ls: cannot access '/home/amina': No such file or directory"
  echo

  print_success "Nice work."
  print_info "You verified the target, confirmed no active sessions, performed a clean offboarding delete, and validated removal."
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
