#!/bin/bash

# Lab 153: getent Database Lookup (Realistic Admin Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 153: getent Database Lookup"
LAB_ID="lab153"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab153:~$ "

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
  center_text "A teammate says: 'This host isn't honoring our directory services.'"
  center_text "You need to prove what NSS is returning for users, groups, hosts, and services."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Prove user + group identity data (NSS)
  echo "  Step 1: Prove NSS identity lookups for user + group."
  read -r -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "getent passwd satoshi && getent group developers" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  satoshi:x:1001:1001:Satoshi Nakamoto:/home/satoshi:/bin/bash"
  echo "  developers:x:1002:satoshi"
  echo

  # STEP 2: Prove hostname resolution path (NSS hosts)
  echo "  Step 2: Prove hostname resolution for localhost via NSS."
  read -r -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "getent hosts localhost" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  127.0.0.1       localhost"
  echo "  ::1             localhost"
  echo

  # STEP 3: Prove service/port mapping (useful for firewall + troubleshooting)
  echo "  Step 3: Prove service/port mapping for ssh via NSS."
  read -r -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "getent services ssh" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  ssh               22/tcp"
  echo

  # STEP 4: Prove protocol number mapping (common in packet/debug tooling)
  echo "  Step 4: Prove protocol mapping for tcp via NSS."
  read -r -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "getent protocols tcp" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  tcp               6 TCP"
  echo

  print_success "Nice work."
  print_info "You used getent to prove what NSS returns for identity, name resolution, services, and protocols."
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
