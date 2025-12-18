#!/bin/bash

# Lab 256: SELinux contexts with chcon (user_u + public_content_t) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real files/labels are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 256: chcon — user_u + public_content_t"
LAB_ID="lab256"
LAB_XP=21420
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated paths (NOT your real system)
DOC_ROOT="/var/www/html"
FILE_PATH="${DOC_ROOT}/demo.html"

# Plausible SELinux contexts for this exercise
CTX_DEFAULT="unconfined_u:object_r:httpd_sys_content_t:s0"
CTX_PUBLIC_TYPE="unconfined_u:object_r:public_content_t:s0"
CTX_PUBLIC_USER="user_u:object_r:public_content_t:s0"

DATE_STR="Jul 22 14:30"   # simulated timestamp for any listings

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
  center_text "Goal: Create ${FILE_PATH}, inspect its SELinux context, then use chcon to set"
  center_text "the type to public_content_t and the SELinux user to user_u. Verify after each step."
  center_text "(Optional) Observe how restorecon reverts to the default."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm SELinux is enforcing (show status)
  draw_lab_ui
  echo "  Step 1: Check SELinux status."
  read -p "  lab@lab256:~$ " cmd1
  if [[ "$cmd1" == "getenforce" ]]; then
    echo "  Enforcing"
  elif [[ "$cmd1" == "sestatus" ]]; then
    echo "  SELinux status:                 enabled"
    echo "  Current mode:                   enforcing"
    echo "  Policy from config:             targeted"
  else
    print_error "Hint: Try a standard SELinux status command."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create the file under the web root (silent on success)
  echo "  Step 2: Create ${FILE_PATH} in the document root."
  read -p "  lab@lab256:~$ " cmd2
  if [[ "$cmd2" == "touch ${FILE_PATH}" || "$cmd2" == "install -D /dev/null ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Create the file at ${FILE_PATH}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Show current SELinux context (should be default httpd_sys_content_t)
  echo "  Step 3: Show the file's SELinux context."
  read -p "  lab@lab256:~$ " cmd3
  if [[ "$cmd3" == "ls -Z ${FILE_PATH}" || "$cmd3" == "ls -Z ${DOC_ROOT}" ]]; then
    echo "  ${CTX_DEFAULT} ${FILE_PATH}"
  else
    print_error "Hint: Use ls -Z with the file path."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Change the type to public_content_t (no output on success), then verify
  echo "  Step 4: Change the SELinux type to public_content_t."
  read -p "  lab@lab256:~$ " cmd4
  if [[ "$cmd4" == "chcon -t public_content_t ${FILE_PATH}" || "$cmd4" == "sudo chcon -t public_content_t ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Use chcon with -t to set the type."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 4 (verify): Re-check the file's context."
  read -p "  lab@lab256:~$ " cmd4v
  if [[ "$cmd4v" == "ls -Z ${FILE_PATH}" ]]; then
    echo "  ${CTX_PUBLIC_TYPE} ${FILE_PATH}"
  else
    print_error "Hint: Verify with ls -Z ${FILE_PATH}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Change the SELinux user to user_u (no output), then verify
  echo "  Step 5: Change the SELinux user field to user_u."
  read -p "  lab@lab256:~$ " cmd5
  if [[ "$cmd5" == "chcon -u user_u ${FILE_PATH}" || "$cmd5" == "sudo chcon -u user_u ${FILE_PATH}" ]]; then
    :
  else
    print_error "Hint: Use chcon with -u to set the SELinux user."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 5 (verify): Confirm both user and type are set."
  read -p "  lab@lab256:~$ " cmd5v
  if [[ "$cmd5v" == "ls -Z ${FILE_PATH}" ]]; then
    echo "  ${CTX_PUBLIC_USER} ${FILE_PATH}"
  else
    print_error "Hint: Verify with ls -Z ${FILE_PATH}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6 (optional): Show how restorecon resets to default (demonstration only)
  echo "  Step 6 (optional): Reset the file's context back to the default."
  read -p "  lab@lab256:~$ " cmd6
  if [[ "$cmd6" == "" ]]; then
    # user chose to skip
    :
  elif [[ "$cmd6" == "restorecon -v ${FILE_PATH}" || "$cmd6" == "sudo restorecon -v ${FILE_PATH}" ]]; then
    echo "  restorecon reset ${FILE_PATH} context ${CTX_PUBLIC_USER}->${CTX_DEFAULT}"
    echo
    echo "  Step 6 (verify): Show the default context again."
    read -p "  lab@lab256:~$ " cmd6v
    if [[ "$cmd6v" == "ls -Z ${FILE_PATH}" ]]; then
      echo "  ${CTX_DEFAULT} ${FILE_PATH}"
    else
      print_error "Hint: Verify with ls -Z ${FILE_PATH}."
      read -p "Press Enter to try again..." _
      continue
    fi
  else
    print_error "Hint: Press Enter to skip, or use restorecon -v ${FILE_PATH} to reset."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You inspected SELinux context, used chcon to set type (public_content_t) and user (user_u), and verified the changes (simulated)."
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
