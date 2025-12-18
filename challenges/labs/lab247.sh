#!/bin/bash

# Lab 247: Create user300, verify login.defs & /etc entries — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/files are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 247: user300 + defaults verification"
LAB_ID="lab247"
LAB_XP=20860
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# SIMULATED defaults (do NOT reflect your real system)
UID_MIN=1000
UID_MAX=60000
PASS_MAX_DAYS=99999
PASS_MIN_DAYS=0
PASS_WARN_AGE=7
UMASK_DEF=022

# Simulated /etc/default/useradd values
UA_GROUP=100
UA_HOME="/home"
UA_INACTIVE=-1
UA_EXPIRE=""
UA_SHELL="/bin/bash"
UA_SKEL="/etc/skel"
UA_CREATE_HOME="yes"
UA_CREATE_MAIL_SPOOL="no"

# Simulated new account details
USER="user300"
UID_USER=1300
GID_USER=1300
HOME_USER="/home/${USER}"
SHELL_USER="/bin/bash"
SHADOW_LASTCHANGE="19725"  # days since epoch (simulated)

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
  center_text "Goal: Review default account policies, create '${USER}', and verify entries in /etc/passwd, /etc/shadow,"
  center_text "/etc/login.defs, and /etc/default/useradd — with realistic simulated outputs."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Inspect key defaults in /etc/login.defs
  draw_lab_ui
  echo "  Step 1: Show key defaults from /etc/login.defs."
  read -p "  lab@lab247:~$ " cmd1
  if [[ "$cmd1" == "grep -E '^(UID_MIN|UID_MAX|UMASK|PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE)' /etc/login.defs" ]]; then
    echo "  UID_MIN                ${UID_MIN}"
    echo "  UID_MAX                ${UID_MAX}"
    echo "  PASS_MAX_DAYS          ${PASS_MAX_DAYS}"
    echo "  PASS_MIN_DAYS          ${PASS_MIN_DAYS}"
    echo "  PASS_WARN_AGE          ${PASS_WARN_AGE}"
    echo "  UMASK                  ${UMASK_DEF}"
  else
    print_error "Hint: grep -E '^(UID_MIN|UID_MAX|UMASK|PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE)' /etc/login.defs"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Inspect useradd defaults
  echo "  Step 2: Display default settings for new users."
  read -p "  lab@lab247:~$ " cmd2
  if [[ "$cmd2" == "useradd -D" || "$cmd2" == "sudo useradd -D" ]]; then
    echo "  GROUP=${UA_GROUP}"
    echo "  HOME=${UA_HOME}"
    echo "  INACTIVE=${UA_INACTIVE}"
    echo "  EXPIRE=${UA_EXPIRE}"
    echo "  SHELL=${UA_SHELL}"
    echo "  SKEL=${UA_SKEL}"
    echo "  CREATE_HOME ${UA_CREATE_HOME}"
    echo "  CREATE_MAIL_SPOOL ${UA_CREATE_MAIL_SPOOL}"
  else
    print_error "Hint: Use useradd -D to print default useradd settings."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Create user300 (silent on success)
  echo "  Step 3: Create '${USER}' with a home directory."
  read -p "  lab@lab247:~$ " cmd3
  if [[ "$cmd3" == "useradd -m ${USER}" || "$cmd3" == "sudo useradd -m ${USER}" ]]; then
    :
  else
    print_error "Hint: useradd -m ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify /etc/passwd entry
  echo "  Step 4: Verify the passwd entry for '${USER}'."
  read -p "  lab@lab247:~$ " cmd4
  if [[ "$cmd4" == "getent passwd ${USER}" || "$cmd4" == "grep '^${USER}:' /etc/passwd" ]]; then
    echo "  ${USER}:x:${UID_USER}:${GID_USER}::${HOME_USER}:${SHELL_USER}"
  else
    print_error "Hint: Try getent passwd ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Verify /etc/shadow entry (requires root; still simulated)
  echo "  Step 5: Check the shadow entry for '${USER}'."
  read -p "  lab@lab247:~$ " cmd5
  if [[ "$cmd5" == "sudo getent shadow ${USER}" || "$cmd5" == "sudo grep '^${USER}:' /etc/shadow" ]]; then
    echo "  ${USER}:!:${SHADOW_LASTCHANGE}:${PASS_MIN_DAYS}:${PASS_MAX_DAYS}:${PASS_WARN_AGE}:::"
  else
    print_error "Hint: Use sudo getent shadow ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Confirm home directory & skeleton files were created
  echo "  Step 6: Inspect the new home directory contents."
  read -p "  lab@lab247:~$ " cmd6
  if [[ "$cmd6" == "ls -la ${HOME_USER}" ]]; then
    echo "  total 24"
    echo "  drwxr-xr-x  3 ${USER} ${USER} 4096 Jul 22 12:40 ."
    echo "  drwxr-xr-x  3 root  root  4096 Jul 22 12:40 .."
    echo "  -rw-r--r--  1 ${USER} ${USER}  220 Jul 22 12:40 .bash_logout"
    echo "  -rw-r--r--  1 ${USER} ${USER} 3771 Jul 22 12:40 .bashrc"
    echo "  -rw-r--r--  1 ${USER} ${USER}  807 Jul 22 12:40 .profile"
  else
    print_error "Hint: ls -la ${HOME_USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Confirm the default shell recorded for the user
  echo "  Step 7: Show the login shell for '${USER}'."
  read -p "  lab@lab247:~$ " cmd7
  if [[ "$cmd7" == "getent passwd ${USER} | cut -d: -f7" ]]; then
    echo "  ${SHELL_USER}"
  else
    print_error "Hint: getent passwd ${USER} | cut -d: -f7"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Confirm default aging policy as seen by chage
  echo "  Step 8: Review password aging for '${USER}'."
  read -p "  lab@lab247:~$ " cmd8
  if [[ "$cmd8" == "sudo chage -l ${USER}" || "$cmd8" == "chage -l ${USER}" ]]; then
    echo "  Last password change                                    : Jul 22, 2025"
    echo "  Password expires                                        : never"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : never"
    echo "  Minimum number of days between password change          : ${PASS_MIN_DAYS}"
    echo "  Maximum number of days between password change          : ${PASS_MAX_DAYS}"
    echo "  Number of days of warning before password expires       : ${PASS_WARN_AGE}"
  else
    print_error "Hint: chage -l ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Cross-check /etc/default/useradd for UMASK/SHELL/HOME/SKEL
  echo "  Step 9: Cross-check /etc/default/useradd for key defaults."
  read -p "  lab@lab247:~$ " cmd9
  if [[ "$cmd9" == "grep -E '^(UMASK|SHELL|HOME|SKEL)=' /etc/default/useradd" ]]; then
    echo "  UMASK=${UMASK_DEF}"
    echo "  HOME=${UA_HOME}"
    echo "  SHELL=${UA_SHELL}"
    echo "  SKEL=${UA_SKEL}"
  else
    print_error "Hint: grep -E '^(UMASK|SHELL|HOME|SKEL)=' /etc/default/useradd"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You reviewed defaults, created ${USER}, and verified passwd/shadow/home/shell + policy (simulated)."
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
