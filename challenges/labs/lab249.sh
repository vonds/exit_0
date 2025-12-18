#!/bin/bash

# Lab 249: Configure password aging (chage) for derek — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real users/files are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 249: Password Aging with chage (derek)"
LAB_ID="lab249"
LAB_XP=20980
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated constants (NOT your real system)
USER="derek"
UID_USER=1001
GID_USER=1001
HOME_USER="/home/${USER}"
SHELL_USER="/bin/bash"

# Target policy to configure
MIN_DAYS=1
MAX_DAYS=90
WARN_DAYS=7
INACTIVE_DAYS=14
EXPIRE_ISO="2025-12-31"
EXPIRE_HUMAN="Dec 31, 2025"

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
  center_text "Goal: Inspect ${USER}'s current password/aging policy, then configure:"
  center_text " - Minimum days: ${MIN_DAYS} | Maximum days: ${MAX_DAYS} | Warning: ${WARN_DAYS} days"
  center_text " - Inactive lock after: ${INACTIVE_DAYS} days | Account expiry date: ${EXPIRE_HUMAN}"
  center_text " - (Optional) Force password change at next login"
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Ensure the account exists
  draw_lab_ui
  echo "  Step 1: Verify that '${USER}' exists on the system."
  read -p "  lab@lab249:~$ " cmd1
  if [[ "$cmd1" == "getent passwd ${USER}" || "$cmd1" == "grep '^${USER}:' /etc/passwd" ]]; then
    echo "  ${USER}:x:${UID_USER}:${GID_USER}::${HOME_USER}:${SHELL_USER}"
  else
    print_error "Hint: Query the passwd database for ${USER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: View current aging policy
  echo "  Step 2: Show ${USER}'s current password aging policy."
  read -p "  lab@lab249:~$ " cmd2
  if [[ "$cmd2" == "chage -l ${USER}" || "$cmd2" == "sudo chage -l ${USER}" ]]; then
    echo "  Last password change                                    : never"
    echo "  Password expires                                        : never"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : never"
    echo "  Minimum number of days between password change          : 0"
    echo "  Maximum number of days between password change          : 99999"
    echo "  Number of days of warning before password expires       : 7"
  else
    print_error "Hint: Use chage -l ${USER} to list policy."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Set minimum days
  echo "  Step 3: Require at least ${MIN_DAYS} day(s) between password changes."
  read -p "  lab@lab249:~$ " cmd3
  if [[ "$cmd3" == "chage -m ${MIN_DAYS} ${USER}" || "$cmd3" == "sudo chage -m ${MIN_DAYS} ${USER}" ]]; then
    :
  else
    print_error "Hint: chage -m ${MIN_DAYS} ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Set maximum days
  echo "  Step 4: Set the maximum password age to ${MAX_DAYS} days."
  read -p "  lab@lab249:~$ " cmd4
  if [[ "$cmd4" == "chage -M ${MAX_DAYS} ${USER}" || "$cmd4" == "sudo chage -M ${MAX_DAYS} ${USER}" ]]; then
    :
  else
    print_error "Hint: chage -M ${MAX_DAYS} ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Set warning period
  echo "  Step 5: Configure a ${WARN_DAYS}-day warning before expiry."
  read -p "  lab@lab249:~$ " cmd5
  if [[ "$cmd5" == "chage -W ${WARN_DAYS} ${USER}" || "$cmd5" == "sudo chage -W ${WARN_DAYS} ${USER}" ]]; then
    :
  else
    print_error "Hint: chage -W ${WARN_DAYS} ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Set inactive lock
  echo "  Step 6: Lock the account ${INACTIVE_DAYS} days after the password expires."
  read -p "  lab@lab249:~$ " cmd6
  if [[ "$cmd6" == "chage -I ${INACTIVE_DAYS} ${USER}" || "$cmd6" == "sudo chage -I ${INACTIVE_DAYS} ${USER}" ]]; then
    :
  else
    print_error "Hint: chage -I ${INACTIVE_DAYS} ${USER}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Set hard account expiry date
  echo "  Step 7: Set the account expiry date to ${EXPIRE_ISO}."
  read -p "  lab@lab249:~$ " cmd7
  if [[ "$cmd7" == "chage -E ${EXPIRE_ISO} ${USER}" || "$cmd7" == "sudo chage -E ${EXPIRE_ISO} ${USER}" || \
        "$cmd7" == "usermod -e ${EXPIRE_ISO} ${USER}" || "$cmd7" == "sudo usermod -e ${EXPIRE_ISO} ${USER}" ]]; then
    :
  else
    print_error "Hint: chage -E YYYY-MM-DD ${USER}  (or usermod -e YYYY-MM-DD ${USER})"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8 (optional): Force password change at next login
  echo "  Step 8 (optional): Require ${USER} to change password at next login."
  read -p "  lab@lab249:~$ " cmd8
  if [[ "$cmd8" == "chage -d 0 ${USER}" || "$cmd8" == "sudo chage -d 0 ${USER}" || "$cmd8" == "" ]]; then
    :
  else
    print_error "Hint: chage -d 0 ${USER}   (or press Enter to skip)"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Verify final policy
  echo "  Step 9: Verify the updated password aging policy."
  read -p "  lab@lab249:~$ " cmd9
  if [[ "$cmd9" == "chage -l ${USER}" || "$cmd9" == "sudo chage -l ${USER}" ]]; then
    # If Step 8 forced a reset, show the "must be changed" string; otherwise show a normal date.
    if [[ "$cmd8" == "chage -d 0 ${USER}" || "$cmd8" == "sudo chage -d 0 ${USER}" ]]; then
      echo "  Last password change                                    : password must be changed"
    else
      echo "  Last password change                                    : Jul 22, 2025"
    fi
    echo "  Password expires                                        : after ${MAX_DAYS} days"
    echo "  Password inactive                                       : after ${INACTIVE_DAYS} days"
    echo "  Account expires                                         : ${EXPIRE_HUMAN}"
    echo "  Minimum number of days between password change          : ${MIN_DAYS}"
    echo "  Maximum number of days between password change          : ${MAX_DAYS}"
    echo "  Number of days of warning before password expires       : ${WARN_DAYS}"
  else
    print_error "Hint: Re-run chage -l ${USER}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You configured password aging for ${USER} (simulated) with chage and verified the policy."
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
