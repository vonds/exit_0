#!/bin/bash

# Lab 155: groupadd Group Management (Realistic Admin Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 155: groupadd Group Management"
LAB_ID="lab155"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_ROOT="  root@lab155:~# "

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
  center_text "A new project is launching. You need UNIX groups for access control and shared ownership."
  center_text "Ticket requirements:"
  center_text "- Create groups: developers, qa, devops"
  center_text "- Reserved GIDs (from standards): docker=1050, devops=1200"
  center_text "- Verify the groups exist in NSS."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Create the standard groups (one command)
  echo "  Step 1: Create the required groups in one command."
  echo "          Expected groups: developers, qa, devops"
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "groupadd developers && groupadd qa && groupadd -g 1200 devops" ]]; then
    print_error "Incorrect."
    print_info "Build the command from the ticket requirements."
    read -r -p "Press Enter to try again..." _
    continue
  fi

  # STEP 2: Create docker with reserved GID (standards compliance)
  echo "  Step 2: Create the docker group with reserved GID 1050."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "groupadd -g 1050 docker" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi

  # STEP 3: Verify via NSS (not by grepping /etc/group)
  echo "  Step 3: Verify the groups exist using getent (NSS)."
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "getent group developers && getent group qa && getent group docker && getent group devops" ]]; then
    print_error "Incorrect."
    print_info "Use getent group for each required group."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  developers:x:1002:"
  echo "  qa:x:1100:"
  echo "  docker:x:1050:"
  echo "  devops:x:1200:"
  echo

  print_success "Nice work."
  print_info "You created project groups with required GID standards and verified them via NSS."
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
