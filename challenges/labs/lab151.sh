#!/bin/bash

# Lab 151: usermod User Account Modification (Realistic Admin Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 151: usermod User Account Modification"
LAB_ID="lab151"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab151:~$ "

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
  center_text "User Satoshi has moved teams. Update access and account settings."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Baseline evidence
  echo "  Step 1: Capture baseline state for user satoshi (uid/gid/groups/home/shell)."
  read -r -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "id satoshi" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  uid=1003(satoshi) gid=1003(satoshi) groups=1003(satoshi)"
  echo

  # STEP 2: Apply *most* changes in one command (real admin move)
  echo "  Step 2: Apply the requested changes in one usermod command."
  echo "  Requested changes:"
  echo "    - Primary group: developers"
  echo "    - Add to groups: docker, wheel"
  echo "    - Shell: /bin/zsh"
  echo "    - Home: /srv/satoshi (move contents)"
  echo "    - Expire: 2025-12-31"
  echo "    - UID: 1055"
  echo "    - Comment: Satoshi Nakamoto"
  echo "    - Rename login: satoshi -> satoshi-renamed"
  read -r -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != 'sudo usermod -g developers -aG docker,wheel -s /bin/zsh -d /srv/satoshi -m -e 2025-12-31 -u 1055 -c "Satoshi Nakamoto" satoshi' ]]; then
    print_error "Incorrect."
    print_info "Expected one usermod with: -g -aG -s -d -m -e -u -c"
    read -r -p "Press Enter to try again..." _
    continue
  fi

  # STEP 3: Rename login (separate operation)
  echo "  Step 3: Rename the login from satoshi to satoshi-renamed."
  read -r -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo usermod -l satoshi-renamed satoshi" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi


  # STEP 4: Verify end state (real admin proof)
  echo "  Step 4: Verify final account state (uid/gid/groups/home/shell)."
  read -r -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "getent passwd satoshi-renamed" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  satoshi-renamed:x:1055:2001:Satoshi Nakamoto:/srv/satoshi:/bin/zsh"
  echo

  # STEP 5: Quick validation that move happened + ownership looks sane
  echo "  Step 5: Confirm the home directory exists and is owned by satoshi-renamed."
  read -r -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls -ld /srv/satoshi" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwx------ 4 satoshi-renamed developers 4096 Feb  8 07:11 /srv/satoshi"
  echo

  print_success "Nice work."
  print_info "You collected baseline evidence, applied changes efficiently, then verified the final state."
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
