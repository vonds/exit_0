#!/bin/bash

# Lab 258: Add non-standard HTTP port to SELinux policy (httpd) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real SELinux/ports/services are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 258: SELinux — allow httpd on a non-standard port"
LAB_ID="lab258"
LAB_XP=21520
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Non-default port to allow for httpd (chosen to be absent by default on many systems)
NEW_PORT=8081
TYPE=http_port_t
PROTO=tcp

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
  center_text "Goal: Inspect allowed ${TYPE} ports, add ${NEW_PORT}/${PROTO} for httpd,"
  center_text "and verify it appears in the SELinux port mapping (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm SELinux mode
  draw_lab_ui
  echo "  Step 1: Check SELinux status/mode."
  read -p "  lab@lab258:~$ " cmd1
  if [[ "$cmd1" == "getenforce" ]]; then
    echo "  Enforcing"
  elif [[ "$cmd1" == "sestatus" ]]; then
    echo "  SELinux status:                 enabled"
    echo "  Current mode:                   enforcing"
    echo "  Policy from config:             targeted"
  else
    print_error "Hint: Use getenforce or sestatus."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Show current http_port_t mapping (NEW_PORT should not be present yet)
  echo "  Step 2: List ports currently labeled ${TYPE}."
  read -p "  lab@lab258:~$ " cmd2
  if [[ "$cmd2" == "semanage port -l | grep ${TYPE}" ]]; then
    echo "  ${TYPE}                    ${PROTO}      80, 443, 488, 8008, 8009, 8443"
  else
    print_error "Hint: List SELinux ports and filter for ${TYPE}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Add NEW_PORT to http_port_t mapping (silent on success)
  echo "  Step 3: Allow httpd to bind on ${NEW_PORT}/${PROTO} at the policy level."
  read -p "  lab@lab258:~$ " cmd3
  if [[ "$cmd3" == "semanage port -a -t ${TYPE} -p ${PROTO} ${NEW_PORT}" || \
        "$cmd3" == "sudo semanage port -a -t ${TYPE} -p ${PROTO} ${NEW_PORT}" ]]; then
    :
  else
    print_error "Hint: Add a port mapping with: semanage port -a -t <type> -p <proto> <port>"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify NEW_PORT appears under http_port_t
  echo "  Step 4: Verify that ${NEW_PORT}/${PROTO} is now mapped to ${TYPE}."
  read -p "  lab@lab258:~$ " cmd4
  if [[ "$cmd4" == "semanage port -l | grep ${TYPE}" ]]; then
    echo "  ${TYPE}                    ${PROTO}      80, 443, 488, 8008, 8009, 8443, ${NEW_PORT}"
  elif [[ "$cmd4" == "semanage port -l | grep -w ${NEW_PORT}" ]]; then
    echo "  ${TYPE}                    ${PROTO}      ${NEW_PORT}"
  else
    print_error "Hint: Re-list the mapping (grep ${TYPE}) or grep for the exact port."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5 (optional): Demonstrate modify/delete flows
  echo "  Step 5 (optional): Adjust or remove the mapping (press Enter to skip)."
  read -p "  lab@lab258:~$ " cmd5
  if [[ -z "$cmd5" ]]; then
    :
  elif [[ "$cmd5" == "semanage port -m -t ${TYPE} -p ${PROTO} ${NEW_PORT}" || \
          "$cmd5" == "sudo semanage port -m -t ${TYPE} -p ${PROTO} ${NEW_PORT}" ]]; then
    # modify is typically silent
    :
  elif [[ "$cmd5" == "semanage port -d -t ${TYPE} -p ${PROTO} ${NEW_PORT}" || \
          "$cmd5" == "sudo semanage port -d -t ${TYPE} -p ${PROTO} ${NEW_PORT}" ]]; then
    # deletion is silent; verify it disappeared
    echo
    echo "  Step 5 (verify): Confirm ${NEW_PORT} is no longer listed."
    read -p "  lab@lab258:~$ " cmd5v
    if [[ "$cmd5v" == "semanage port -l | grep ${TYPE}" ]]; then
      echo "  ${TYPE}                    ${PROTO}      80, 443, 488, 8008, 8009, 8443"
    else
      print_error "Hint: Re-list the mapping to verify removal."
      read -p "Press Enter to try again..." _
      continue
    fi
  else
    print_error "Hint: Use semanage port -m ... to modify or -d ... to delete (or press Enter to skip)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You inspected ${TYPE} ports, added ${NEW_PORT}/${PROTO} for httpd, and verified the SELinux mapping (simulated)."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
