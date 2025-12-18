#!/bin/bash

# Lab 245: Users & Groups — Create users in a group, expire one user, set no-shell — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/groups are created.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 245: Users in 'instructors' + expire tom in 10 days (no shell)"
LAB_ID="lab245"
LAB_XP=20750
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated metadata (do NOT reflect your real system)
GROUP="instructors"
GID_INSTRUCTORS=1010
UID_DEREK=1001
UID_TOM=1002
UID_KENNY=1003
EXPIRE_ISO="2025-08-01"        # 10 days after an assumed reference date (simulated)
EXPIRE_HUMAN="Aug 01, 2025"
REF_CHANGE="Jul 22, 2025"

# Will adapt to whichever nologin path the user chooses
NOLOGIN_SHELL="/sbin/nologin"

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
  center_text "Goal: Create users derek, tom, and kenny in group '${GROUP}'."
  center_text "Set tom's account to expire in 10 days and give tom no interactive shell."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create the 'instructors' group (silent on success)
  draw_lab_ui
  echo "  Step 1: Create a group named '${GROUP}'."
  read -p "  lab@lab245:~$ " cmd1
  if [[ "$cmd1" == "groupadd ${GROUP}" || "$cmd1" == "sudo groupadd ${GROUP}" ]]; then
    :
  else
    print_error "Hint: Create the '${GROUP}' group before adding users to it."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create 'derek' as a local user with home and add to 'instructors' (silent)
  echo "  Step 2: Create user 'derek' with a home directory and add to '${GROUP}'."
  read -p "  lab@lab245:~$ " cmd2
  if [[ "$cmd2" == "useradd -m -G ${GROUP} derek" || "$cmd2" == "sudo useradd -m -G ${GROUP} derek" || \
        "$cmd2" == "useradd -m -g ${GROUP} derek" || "$cmd2" == "sudo useradd -m -g ${GROUP} derek" ]]; then
    :
  else
    print_error "Hint: Use useradd with -m and add 'derek' to '${GROUP}' (either as primary -g or supplementary -G)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Create 'tom' with home, add to group, and set NO-LOGIN shell
  echo "  Step 3: Create user 'tom' with a home directory, in '${GROUP}', and no interactive shell."
  read -p "  lab@lab245:~$ " cmd3
  if [[ "$cmd3" == "useradd -m -G ${GROUP} -s /sbin/nologin tom" || "$cmd3" == "sudo useradd -m -G ${GROUP} -s /sbin/nologin tom" || \
        "$cmd3" == "useradd -m -g ${GROUP} -s /sbin/nologin tom" || "$cmd3" == "sudo useradd -m -g ${GROUP} -s /sbin/nologin tom" || \
        "$cmd3" == "useradd -m -G ${GROUP} -s /usr/sbin/nologin tom" || "$cmd3" == "sudo useradd -m -G ${GROUP} -s /usr/sbin/nologin tom" || \
        "$cmd3" == "useradd -m -g ${GROUP} -s /usr/sbin/nologin tom" || "$cmd3" == "sudo useradd -m -g ${GROUP} -s /usr/sbin/nologin tom" ]]; then
    [[ "$cmd3" == *"/usr/sbin/nologin"* ]] && NOLOGIN_SHELL="/usr/sbin/nologin"
  else
    print_error "Hint: Specify -s /sbin/nologin (or /usr/sbin/nologin) when creating 'tom'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Create 'kenny' with home and add to 'instructors' (silent)
  echo "  Step 4: Create user 'kenny' with a home directory and add to '${GROUP}'."
  read -p "  lab@lab245:~$ " cmd4
  if [[ "$cmd4" == "useradd -m -G ${GROUP} kenny" || "$cmd4" == "sudo useradd -m -G ${GROUP} kenny" || \
        "$cmd4" == "useradd -m -g ${GROUP} kenny" || "$cmd4" == "sudo useradd -m -g ${GROUP} kenny" ]]; then
    :
  else
    print_error "Hint: Use useradd with -m and add 'kenny' to '${GROUP}'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Set 'tom' account expiration 10 days from the reference (silent)
  echo "  Step 5: Set 'tom' to expire in 10 days."
  read -p "  lab@lab245:~$ " cmd5
  if [[ "$cmd5" == "chage -E ${EXPIRE_ISO} tom" || "$cmd5" == "sudo chage -E ${EXPIRE_ISO} tom" || \
        "$cmd5" == "usermod -e ${EXPIRE_ISO} tom" || "$cmd5" == "sudo usermod -e ${EXPIRE_ISO} tom" ]]; then
    :
  else
    print_error "Hint: Use chage -E YYYY-MM-DD tom (or usermod -e YYYY-MM-DD tom)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Verify group entry contains all three users
  echo "  Step 6: Verify that '${GROUP}' lists derek, tom, and kenny."
  read -p "  lab@lab245:~$ " cmd6
  if [[ "$cmd6" == "getent group ${GROUP}" ]]; then
    echo "  ${GROUP}:x:${GID_INSTRUCTORS}:derek,tom,kenny"
  else
    print_error "Hint: Use getent group ${GROUP} to check membership."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Verify 'tom' expiration and no-login shell
  echo "  Step 7: Inspect 'tom' account policy and shell."
  read -p "  lab@lab245:~$ " cmd7a
  if [[ "$cmd7a" == "chage -l tom" || "$cmd7a" == "sudo chage -l tom" ]]; then
    echo "  Last password change                                    : ${REF_CHANGE}"
    echo "  Password expires                                        : never"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : ${EXPIRE_HUMAN}"
    echo "  Minimum number of days between password change          : 0"
    echo "  Maximum number of days between password change          : 99999"
    echo "  Number of days of warning before password expires       : 7"
  else
    print_error "Hint: Use chage -l tom to view the account policy."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab245:~$ " cmd7b
  if [[ "$cmd7b" == "getent passwd tom" ]]; then
    echo "  tom:x:${UID_TOM}:${UID_TOM}::/home/tom:${NOLOGIN_SHELL}"
  else
    print_error "Hint: Use getent passwd tom to verify the login shell."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Verify group membership via 'id' for each user
  echo "  Step 8: Confirm group membership with 'id'."
  read -p "  lab@lab245:~$ " cmd8a
  if [[ "$cmd8a" == "id derek" ]]; then
    echo "  uid=${UID_DEREK}(derek) gid=${UID_DEREK}(derek) groups=${UID_DEREK}(derek),${GID_INSTRUCTORS}(${GROUP})"
  else
    print_error "Hint: id derek"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab245:~$ " cmd8b
  if [[ "$cmd8b" == "id tom" ]]; then
    echo "  uid=${UID_TOM}(tom) gid=${UID_TOM}(tom) groups=${UID_TOM}(tom),${GID_INSTRUCTORS}(${GROUP})"
  else
    print_error "Hint: id tom"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab245:~$ " cmd8c
  if [[ "$cmd8c" == "id kenny" ]]; then
    echo "  uid=${UID_KENNY}(kenny) gid=${UID_KENNY}(kenny) groups=${UID_KENNY}(kenny),${GID_INSTRUCTORS}(${GROUP})"
  else
    print_error "Hint: id kenny"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You created users in '${GROUP}', set tom's expiration, and enforced a no-login shell (simulated)."
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
