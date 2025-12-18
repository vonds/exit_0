#!/bin/bash

# Lab 252: Rename groups, change GID, and reassign users — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/groups/files are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 252: Rename groups + change GID + reassign"
LAB_ID="lab252"
LAB_XP=21120
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated users & groups (NOT your real system)
ALICE="alice";     UID_ALICE=1101; GID_ALICE=1101
BOB="bob";         UID_BOB=1102;   GID_BOB=1102
CHARLES="charles"; UID_CHARLES=1103; GID_CHARLES=1103
DEREK="derek";     UID_DEREK=1001; GID_DEREK=1001

G_OLD="marketing"
G_NEW="growth"
GID_OLD=2400
GID_NEW=2450

DATE_STR="Jul 22 13:20"

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
  center_text "Goal: Rename the group '${G_OLD}' to '${G_NEW}', change its GID from ${GID_OLD} to ${GID_NEW},"
  center_text "and adjust user memberships accordingly — with realistic simulated outputs."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify the original group exists (with members)
  draw_lab_ui
  echo "  Step 1: Verify the original group record."
  read -p "  lab@lab252:~$ " cmd1
  if [[ "$cmd1" == "getent group ${G_OLD}" ]]; then
    echo "  ${G_OLD}:x:${GID_OLD}:${ALICE},${BOB}"
  else
    print_error "Hint: Query the group database for ${G_OLD}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Rename the group (silent on success)
  echo "  Step 2: Rename the group to '${G_NEW}'."
  read -p "  lab@lab252:~$ " cmd2
  if [[ "$cmd2" == "groupmod -n ${G_NEW} ${G_OLD}" || "$cmd2" == "sudo groupmod -n ${G_NEW} ${G_OLD}" ]]; then
    :
  else
    print_error "Hint: Use the group rename option in the modification command."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Verify the new name is in place (GID unchanged yet)
  echo "  Step 3: Confirm the renamed group entry."
  read -p "  lab@lab252:~$ " cmd3
  if [[ "$cmd3" == "getent group ${G_NEW}" ]]; then
    echo "  ${G_NEW}:x:${GID_OLD}:${ALICE},${BOB}"
  else
    print_error "Hint: Query the group database for ${G_NEW}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Change the group's numeric GID (silent)
  echo "  Step 4: Change the group's numeric ID."
  read -p "  lab@lab252:~$ " cmd4
  if [[ "$cmd4" == "groupmod -g ${GID_NEW} ${G_NEW}" || "$cmd4" == "sudo groupmod -g ${GID_NEW} ${G_NEW}" ]]; then
    :
  else
    print_error "Hint: Modify the group to set a new GID."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Verify the GID change
  echo "  Step 5: Show the updated group record with the new GID."
  read -p "  lab@lab252:~$ " cmd5
  if [[ "$cmd5" == "getent group ${G_NEW}" ]]; then
    echo "  ${G_NEW}:x:${GID_NEW}:${ALICE},${BOB}"
  else
    print_error "Hint: Query the group database for ${G_NEW} again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Make ${G_NEW} the PRIMARY group for bob (silent)
  echo "  Step 6: Switch ${BOB}'s primary group to '${G_NEW}'."
  read -p "  lab@lab252:~$ " cmd6
  if [[ "$cmd6" == "usermod -g ${G_NEW} ${BOB}" || "$cmd6" == "sudo usermod -g ${G_NEW} ${BOB}" ]]; then
    :
  else
    print_error "Hint: Change the user's primary group."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Add derek and charles as SUPPLEMENTARY members (silent)
  echo "  Step 7: Add ${DEREK} and ${CHARLES} as supplementary members."
  read -p "  lab@lab252:~$ " cmd7a
  if [[ "$cmd7a" == "usermod -aG ${G_NEW} ${DEREK}" || "$cmd7a" == "sudo usermod -aG ${G_NEW} ${DEREK}" ]]; then
    :
  else
    print_error "Hint: Append ${DEREK} to the group with the append option."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab252:~$ " cmd7b
  if [[ "$cmd7b" == "usermod -aG ${G_NEW} ${CHARLES}" || "$cmd7b" == "sudo usermod -aG ${G_NEW} ${CHARLES}" ]]; then
    :
  else
    print_error "Hint: Append ${CHARLES} to the group with the append option."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Verify membership via getent group
  echo "  Step 8: Verify membership list in the group record."
  read -p "  lab@lab252:~$ " cmd8
  if [[ "$cmd8" == "getent group ${G_NEW}" ]]; then
    echo "  ${G_NEW}:x:${GID_NEW}:${ALICE},${BOB},${DEREK},${CHARLES}"
  else
    print_error "Hint: Use the group database lookup for ${G_NEW}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Verify per-user views
  echo "  Step 9: Check identities for affected users."
  read -p "  lab@lab252:~$ " cmd9a
  if [[ "$cmd9a" == "id ${BOB}" ]]; then
    echo "  uid=${UID_BOB}(${BOB}) gid=${GID_NEW}(${G_NEW}) groups=${GID_NEW}(${G_NEW}),${GID_BOB}(${BOB})"
  else
    print_error "Hint: Inspect ${BOB}'s identity after the primary group change."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab252:~$ " cmd9b
  if [[ "$cmd9b" == "id ${DEREK}" ]]; then
    echo "  uid=${UID_DEREK}(${DEREK}) gid=${GID_DEREK}(${DEREK}) groups=${GID_DEREK}(${DEREK}),${GID_NEW}(${G_NEW})"
  else
    print_error "Hint: Inspect ${DEREK}'s identity to confirm supplementary membership."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab252:~$ " cmd9c
  if [[ "$cmd9c" == "id ${CHARLES}" ]]; then
    echo "  uid=${UID_CHARLES}(${CHARLES}) gid=${GID_CHARLES}(${CHARLES}) groups=${GID_CHARLES}(${CHARLES}),${GID_NEW}(${G_NEW})"
  else
    print_error "Hint: Inspect ${CHARLES}'s identity to confirm supplementary membership."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 10 (optional): Show a quick grep for the numeric GID in /etc/group
  echo "  Step 10 (optional): Show the record matching the new numeric GID."
  read -p "  lab@lab252:~$ " cmd10
  if [[ "$cmd10" == "grep 'x:${GID_NEW}:' /etc/group" || "$cmd10" == "getent group | grep ':${GID_NEW}:'" || "$cmd10" == "" ]]; then
    [[ -n "$cmd10" ]] && echo "  ${G_NEW}:x:${GID_NEW}:${ALICE},${BOB},${DEREK},${CHARLES}"
  else
    print_error "Hint: Grep for :${GID_NEW}: in the group database (or press Enter to skip)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 11 (bonus): Note about updating filesystem group IDs
  echo "  Step 11 (bonus): Fix legacy files still owned by the old GID (no output on success)."
  read -p "  lab@lab252:~$ " cmd11
  if [[ "$cmd11" == "find / -xdev -gid ${GID_OLD} -exec chgrp -h ${GID_NEW} {} +" || "$cmd11" == "" ]]; then
    :
  else
    print_error "Hint: You can search by old numeric GID and chgrp to the new one (or press Enter to skip)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You renamed a group, changed its GID, adjusted memberships, and verified the results (simulated)."
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
