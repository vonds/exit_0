#!/bin/bash

# Lab 250: Configure password aging with passwd (-x/-n/-w) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/files are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 250: passwd -x/-n/-w password aging"
LAB_ID="lab250"
LAB_XP=21040
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated (NOT your real system)
USER="userX"
UID_USER=1350
GID_USER=1350
HOME_USER="/home/${USER}"
SHELL_USER="/bin/bash"

# Target policy for this lab
MIN_DAYS=1
MAX_DAYS=90
WARN_DAYS=7

LAST_CHANGE_MMDDYYYY="07/22/2025"   # simulated for display only
ALG_NOTE="(Password set, SHA512 crypt.)"

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
  center_text "Goal: Using passwd flags, set ${USER}'s password policy to:"
  center_text " - Minimum days: ${MIN_DAYS}    Maximum days: ${MAX_DAYS}    Warning: ${WARN_DAYS}"
  center_text "Then verify the result with a status command."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify the account exists
  draw_lab_ui
  echo "  Step 1: Verify the account exists."
  read -p "  lab@lab250:~$ " cmd1
  if [[ "$cmd1" == "getent passwd ${USER}" || "$cmd1" == "grep '^${USER}:' /etc/passwd" ]]; then
    echo "  ${USER}:x:${UID_USER}:${GID_USER}::${HOME_USER}:${SHELL_USER}"
  elif [[ "$cmd1" == "id ${USER}" ]]; then
    echo "  uid=${UID_USER}(${USER}) gid=${GID_USER}(${USER}) groups=${GID_USER}(${USER})"
  else
    print_error "Hint: Try a standard system database lookup for ${USER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Show current password-aging status via passwd
  echo "  Step 2: Show current password-aging status."
  read -p "  lab@lab250:~$ " cmd2
  if [[ "$cmd2" == "passwd -S ${USER}" || "$cmd2" == "sudo passwd -S ${USER}" ]]; then
    echo "  ${USER} P ${LAST_CHANGE_MMDDYYYY} 0 99999 7 -1 ${ALG_NOTE}"
  else
    print_error "Hint: Use the passwd command that prints a concise status line."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Set minimum days with passwd -n
  echo "  Step 3: Require a minimum interval between password changes."
  read -p "  lab@lab250:~$ " cmd3
  if [[ "$cmd3" == "passwd -n ${MIN_DAYS} ${USER}" || "$cmd3" == "sudo passwd -n ${MIN_DAYS} ${USER}" ]]; then
    :
  else
    print_error "Hint: passwd -n <minDays> ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Set maximum days with passwd -x
  echo "  Step 4: Set the maximum password age."
  read -p "  lab@lab250:~$ " cmd4
  if [[ "$cmd4" == "passwd -x ${MAX_DAYS} ${USER}" || "$cmd4" == "sudo passwd -x ${MAX_DAYS} ${USER}" ]]; then
    :
  else
    print_error "Hint: passwd -x <maxDays> ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Set warning period with passwd -w
  echo "  Step 5: Configure the warning period before expiry."
  read -p "  lab@lab250:~$ " cmd5
  if [[ "$cmd5" == "passwd -w ${WARN_DAYS} ${USER}" || "$cmd5" == "sudo passwd -w ${WARN_DAYS} ${USER}" ]]; then
    :
  else
    print_error "Hint: passwd -w <warnDays> ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Verify with passwd -S (reflects new min/max/warn values)
  echo "  Step 6: Verify the updated aging policy."
  read -p "  lab@lab250:~$ " cmd6
  if [[ "$cmd6" == "passwd -S ${USER}" || "$cmd6" == "sudo passwd -S ${USER}" ]]; then
    echo "  ${USER} P ${LAST_CHANGE_MMDDYYYY} ${MIN_DAYS} ${MAX_DAYS} ${WARN_DAYS} -1 ${ALG_NOTE}"
  elif [[ "$cmd6" == "chage -l ${USER}" || "$cmd6" == "sudo chage -l ${USER}" ]]; then
    echo "  Last password change                                    : Jul 22, 2025"
    echo "  Password expires                                        : after ${MAX_DAYS} days"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : never"
    echo "  Minimum number of days between password change          : ${MIN_DAYS}"
    echo "  Maximum number of days between password change          : ${MAX_DAYS}"
    echo "  Number of days of warning before password expires       : ${WARN_DAYS}"
  else
    print_error "Hint: Verify using either passwd -S ${USER} or chage -l ${USER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7 (optional): Expire immediately to force change at next login
  echo "  Step 7 (optional): Force a password change at the next login."
  read -p "  lab@lab250:~$ " cmd7
  if [[ "$cmd7" == "passwd -e ${USER}" || "$cmd7" == "sudo passwd -e ${USER}" ]]; then
    echo "  passwd: password expiry information changed."
  elif [[ "$cmd7" == "chage -d 0 ${USER}" || "$cmd7" == "sudo chage -d 0 ${USER}" || "$cmd7" == "" ]]; then
    # chage -d 0 produces no output on success; empty input skips
    :
  else
    print_error "Hint: Use passwd -e ${USER}, or chage -d 0 ${USER} (or press Enter to skip)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You set ${USER}'s password aging using passwd flags and verified the policy (simulated)."
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
