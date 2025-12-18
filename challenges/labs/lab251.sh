#!/bin/bash

# Lab 251: Groups with duplicate GIDs + membership — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/groups are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 251: Duplicate GIDs + Membership"
LAB_ID="lab251"
LAB_XP=21060
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated users & IDs (NOT your real system)
ALICE="alice";   UID_ALICE=1101; GID_ALICE=1101; HOME_ALICE="/home/alice"
BOB="bob";       UID_BOB=1102;   GID_BOB=1102;   HOME_BOB="/home/bob"
CHARLES="charles"; UID_CHARLES=1103; GID_CHARLES=1103; HOME_CHARLES="/home/charles"

# Duplicate-GID groups we will create
G1="designers"
G2="graphics"
DUP_GID=2020

# Timestamps for simulated listings
LS_DATE="Jul 22 13:05"

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
  center_text "Goal: Create two groups that intentionally share the same GID (${DUP_GID}),"
  center_text "then assign users to each and verify the results (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify example users exist (simulated lookup)
  draw_lab_ui
  echo "  Step 1: Verify sample users exist."
  read -p "  lab@lab251:~$ " cmd1
  if [[ "$cmd1" == "getent passwd ${ALICE}" ]]; then
    echo "  ${ALICE}:x:${UID_ALICE}:${GID_ALICE}::${HOME_ALICE}:/bin/bash"
  else
    print_error "Hint: Start by checking ${ALICE} (try: getent passwd ${ALICE})."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab251:~$ " cmd1b
  if [[ "$cmd1b" == "getent passwd ${BOB}" ]]; then
    echo "  ${BOB}:x:${UID_BOB}:${GID_BOB}::${HOME_BOB}:/bin/bash"
  else
    print_error "Hint: Now check ${BOB}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab251:~$ " cmd1c
  if [[ "$cmd1c" == "getent passwd ${CHARLES}" ]]; then
    echo "  ${CHARLES}:x:${UID_CHARLES}:${GID_CHARLES}::${HOME_CHARLES}:/bin/bash"
  else
    print_error "Hint: Finally, check ${CHARLES}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create the first group with explicit GID (silent on success)
  echo "  Step 2: Create group '${G1}' with GID ${DUP_GID}."
  read -p "  lab@lab251:~$ " cmd2
  if [[ "$cmd2" == "groupadd -g ${DUP_GID} ${G1}" || "$cmd2" == "sudo groupadd -g ${DUP_GID} ${G1}" ]]; then
    :
  else
    print_error "Hint: Use groupadd with -g ${DUP_GID} for ${G1}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Create the second group reusing the same GID (silent)
  echo "  Step 3: Create group '${G2}' reusing the same GID ${DUP_GID}."
  read -p "  lab@lab251:~$ " cmd3
  if [[ "$cmd3" == "groupadd -g ${DUP_GID} ${G2}" || "$cmd3" == "sudo groupadd -g ${DUP_GID} ${G2}" ]]; then
    :
  else
    print_error "Hint: Use groupadd -g ${DUP_GID} ${G2} (duplicate GID on purpose)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify both group entries exist and share the GID
  echo "  Step 4: Show each group's entry to confirm the shared GID."
  read -p "  lab@lab251:~$ " cmd4a
  if [[ "$cmd4a" == "getent group ${G1}" ]]; then
    echo "  ${G1}:x:${DUP_GID}:"
  else
    print_error "Hint: Use getent group ${G1}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab251:~$ " cmd4b
  if [[ "$cmd4b" == "getent group ${G2}" ]]; then
    echo "  ${G2}:x:${DUP_GID}:"
  else
    print_error "Hint: Use getent group ${G2}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Add alice to designers
  echo "  Step 5: Add ${ALICE} to '${G1}'."
  read -p "  lab@lab251:~$ " cmd5
  if [[ "$cmd5" == "usermod -aG ${G1} ${ALICE}" || "$cmd5" == "sudo usermod -aG ${G1} ${ALICE}" ]]; then
    :
  else
    print_error "Hint: Append ${ALICE} to ${G1} via usermod -aG."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Add bob to graphics
  echo "  Step 6: Add ${BOB} to '${G2}'."
  read -p "  lab@lab251:~$ " cmd6
  if [[ "$cmd6" == "usermod -aG ${G2} ${BOB}" || "$cmd6" == "sudo usermod -aG ${G2} ${BOB}" ]]; then
    :
  else
    print_error "Hint: Append ${BOB} to ${G2} via usermod -aG."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Add charles to BOTH groups (accept comma list)
  echo "  Step 7: Add ${CHARLES} to both '${G1}' and '${G2}'."
  read -p "  lab@lab251:~$ " cmd7
  if [[ "$cmd7" == "usermod -aG ${G1},${G2} ${CHARLES}" || "$cmd7" == "sudo usermod -aG ${G1},${G2} ${CHARLES}" ]]; then
    :
  else
    print_error "Hint: Append ${CHARLES} to both groups in one command with a comma list."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Verify membership in each group
  echo "  Step 8: Verify group member lists."
  read -p "  lab@lab251:~$ " cmd8a
  if [[ "$cmd8a" == "getent group ${G1}" ]]; then
    echo "  ${G1}:x:${DUP_GID}:${ALICE},${CHARLES}"
  else
    print_error "Hint: getent group ${G1}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab251:~$ " cmd8b
  if [[ "$cmd8b" == "getent group ${G2}" ]]; then
    echo "  ${G2}:x:${DUP_GID}:${BOB},${CHARLES}"
  else
    print_error "Hint: getent group ${G2}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Inspect effective groups for charles
  echo "  Step 9: Check effective groups for ${CHARLES}."
  read -p "  lab@lab251:~$ " cmd9
  if [[ "$cmd9" == "id ${CHARLES}" ]]; then
    # NOTE: With duplicate GIDs, many systems display only one name for that numeric GID.
    echo "  uid=${UID_CHARLES}(${CHARLES}) gid=${GID_CHARLES}(${CHARLES}) groups=${GID_CHARLES}(${CHARLES}),${DUP_GID}(${G1})"
  else
    print_error "Hint: Use id ${CHARLES}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 10: (Bonus) Demonstrate that both names map to the same numeric GID
  echo "  Step 10 (bonus): Show both group records again to emphasize the shared GID."
  read -p "  lab@lab251:~$ " cmd10a
  if [[ "$cmd10a" == "getent group ${G1}" ]]; then
    echo "  ${G1}:x:${DUP_GID}:${ALICE},${CHARLES}"
  else
    print_error "Hint: getent group ${G1}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab251:~$ " cmd10b
  if [[ "$cmd10b" == "getent group ${G2}" ]]; then
    echo "  ${G2}:x:${DUP_GID}:${BOB},${CHARLES}"
  else
    print_error "Hint: getent group ${G2}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You created two groups with the same GID, assigned users, and verified the implications (simulated)."
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
