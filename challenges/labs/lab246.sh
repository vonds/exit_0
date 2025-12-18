#!/bin/bash

# Lab 246: Users & Groups — Alice/Bob/Charles + marketing group, shared dir perms — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/groups or files are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 246: Users + marketing group, shared dir permissions"
LAB_ID="lab246"
LAB_XP=20810
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated metadata (NOT your real system)
GROUP="marketing"
GID_MARKETING=1015
UID_ALICE=1101
UID_BOB=1102
UID_CHARLES=1103
SHARE_DIR="/srv/marketing"
LS_PERMS="drwxrws---"
LS_LINKS=2
LS_OWNER="root"
LS_GROUP="$GROUP"
LS_SIZE=4096
LS_DATE="Jul 22 12:45"

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
  center_text "Goal: Create group '${GROUP}', add users alice/bob/charles to it, create ${SHARE_DIR} shared directory,"
  center_text "apply setgid + group RWX permissions (2770), and verify membership & access (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create the group (silent)
  draw_lab_ui
  echo "  Step 1: Create the '${GROUP}' group."
  read -p "  lab@lab246:~$ " cmd1
  if [[ "$cmd1" == "groupadd ${GROUP}" || "$cmd1" == "sudo groupadd ${GROUP}" ]]; then
    :
  else
    print_error "Hint: Create the group first."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create user alice and add to group (silent)
  echo "  Step 2: Create user 'alice' with home and add to '${GROUP}'."
  read -p "  lab@lab246:~$ " cmd2
  if [[ "$cmd2" == "useradd -m -G ${GROUP} alice" || "$cmd2" == "sudo useradd -m -G ${GROUP} alice" || \
        "$cmd2" == "useradd -m -g ${GROUP} alice" || "$cmd2" == "sudo useradd -m -g ${GROUP} alice" ]]; then
    :
  else
    print_error "Hint: Use useradd with -m and add to the group (either -g primary or -G supplementary)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Create user bob and add to group (silent)
  echo "  Step 3: Create user 'bob' with home and add to '${GROUP}'."
  read -p "  lab@lab246:~$ " cmd3
  if [[ "$cmd3" == "useradd -m -G ${GROUP} bob" || "$cmd3" == "sudo useradd -m -G ${GROUP} bob" || \
        "$cmd3" == "useradd -m -g ${GROUP} bob" || "$cmd3" == "sudo useradd -m -g ${GROUP} bob" ]]; then
    :
  else
    print_error "Hint: Same pattern as alice."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Create user charles and add to group (silent)
  echo "  Step 4: Create user 'charles' with home and add to '${GROUP}'."
  read -p "  lab@lab246:~$ " cmd4
  if [[ "$cmd4" == "useradd -m -G ${GROUP} charles" || "$cmd4" == "sudo useradd -m -G ${GROUP} charles" || \
        "$cmd4" == "useradd -m -g ${GROUP} charles" || "$cmd4" == "sudo useradd -m -g ${GROUP} charles" ]]; then
    :
  else
    print_error "Hint: Same pattern as the previous two users."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Verify group membership list
  echo "  Step 5: Verify that '${GROUP}' lists all three users."
  read -p "  lab@lab246:~$ " cmd5
  if [[ "$cmd5" == "getent group ${GROUP}" ]]; then
    echo "  ${GROUP}:x:${GID_MARKETING}:alice,bob,charles"
  else
    print_error "Hint: Use getent group ${GROUP}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Create the shared directory (silent)
  echo "  Step 6: Create the shared directory ${SHARE_DIR}."
  read -p "  lab@lab246:~$ " cmd6
  if [[ "$cmd6" == "mkdir -p ${SHARE_DIR}" || "$cmd6" == "sudo mkdir -p ${SHARE_DIR}" ]]; then
    :
  else
    print_error "Hint: Create the directory path."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Set group ownership to marketing (silent)
  echo "  Step 7: Set group ownership of ${SHARE_DIR} to '${GROUP}'."
  read -p "  lab@lab246:~$ " cmd7
  if [[ "$cmd7" == "chown root:${GROUP} ${SHARE_DIR}" || "$cmd7" == "sudo chown root:${GROUP} ${SHARE_DIR}" ]]; then
    :
  else
    print_error "Hint: chown root:${GROUP} ${SHARE_DIR}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Apply setgid bit and group rwx (2770) (silent)
  echo "  Step 8: Apply setgid and restrict access: group RWX, no access for others."
  read -p "  lab@lab246:~$ " cmd8
  if [[ "$cmd8" == "chmod 2770 ${SHARE_DIR}" || "$cmd8" == "sudo chmod 2770 ${SHARE_DIR}" ]]; then
    :
  else
    print_error "Hint: Use chmod 2770 on the directory."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Verify directory ownership and permissions
  echo "  Step 9: Verify permissions on ${SHARE_DIR}."
  read -p "  lab@lab246:~$ " cmd9
  if [[ "$cmd9" == "ls -ld ${SHARE_DIR}" ]]; then
    echo "  ${LS_PERMS} ${LS_LINKS} ${LS_OWNER} ${LS_GROUP} ${LS_SIZE} ${LS_DATE} ${SHARE_DIR}"
  else
    print_error "Hint: Use ls -ld to see the mode, owner, and group."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Optional default ACL to guarantee group rwx on new files (silent)
  echo "  Step 10 (optional): Set a default ACL so new files are group-RWX."
  read -p "  lab@lab246:~$ " cmd10
  if [[ "$cmd10" == "setfacl -d -m g::rwx ${SHARE_DIR}" || "$cmd10" == "sudo setfacl -d -m g::rwx ${SHARE_DIR}" || "$cmd10" == "" ]]; then
    # Accept empty input to skip this optional step
    :
  else
    print_error "Hint: setfacl -d -m g::rwx ${SHARE_DIR}   (or press Enter to skip)"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 11: If ACL set, show getfacl (we'll show a canonical view regardless for learning)
  echo "  Step 11: Inspect ACLs on ${SHARE_DIR}."
  read -p "  lab@lab246:~$ " cmd11
  if [[ "$cmd11" == "getfacl ${SHARE_DIR}" ]]; then
    echo "  # file: ${SHARE_DIR}"
    echo "  # owner: ${LS_OWNER}"
    echo "  # group: ${LS_GROUP}"
    echo "  user::rwx"
    echo "  group::rwx"
    echo "  other::---"
    echo "  default:user::rwx"
    echo "  default:group::rwx"
    echo "  default:mask::rwx"
    echo "  default:other::---"
  else
    print_error "Hint: Use getfacl ${SHARE_DIR} to inspect ACLs."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 12: Verify each user's membership via id
  echo "  Step 12: Confirm group membership via 'id' for each user."
  read -p "  lab@lab246:~$ " cmd12a
  if [[ "$cmd12a" == "id alice" ]]; then
    echo "  uid=${UID_ALICE}(alice) gid=${UID_ALICE}(alice) groups=${UID_ALICE}(alice),${GID_MARKETING}(${GROUP})"
  else
    print_error "Hint: id alice"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab246:~$ " cmd12b
  if [[ "$cmd12b" == "id bob" ]]; then
    echo "  uid=${UID_BOB}(bob) gid=${UID_BOB}(bob) groups=${UID_BOB}(bob),${GID_MARKETING}(${GROUP})"
  else
    print_error "Hint: id bob"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab246:~$ " cmd12c
  if [[ "$cmd12c" == "id charles" ]]; then
    echo "  uid=${UID_CHARLES}(charles) gid=${UID_CHARLES}(charles) groups=${UID_CHARLES}(charles),${GID_MARKETING}(${GROUP})"
  else
    print_error "Hint: id charles"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! You created users, configured the '${GROUP}' shared directory with setgid + group RWX, and verified access (simulated)."
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
