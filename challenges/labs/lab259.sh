#!/bin/bash

# Lab 259: SELinux context inheritance — copy to /etc/default and verify — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real files/labels are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 259: SELinux context inheritance (copy & check)"
LAB_ID="lab259"
LAB_XP=21560
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated paths (NOT your real system)
WEB_ROOT="/var/www/html"
SRC_FILE="${WEB_ROOT}/config.sample"
ETC_DIR="/etc/default"
DST_NORM="${ETC_DIR}/config.np"
DST_KEEP="${ETC_DIR}/config.preserved"

# Simulated SELinux contexts
CTX_WEB="unconfined_u:object_r:httpd_sys_content_t:s0"
CTX_ETC="unconfined_u:object_r:etc_t:s0"

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
  center_text "Goal: Observe SELinux label inheritance when copying a file into ${ETC_DIR}."
  center_text "Copy once normally (inherit target-dir label), once preserving context (keeps source label),"
  center_text "then repair with restorecon. Verify labels at each step (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm SELinux mode
  draw_lab_ui
  echo "  Step 1: Display the current SELinux mode."
  read -p "  lab@lab259:~$ " cmd1
  if [[ "$cmd1" == "getenforce" ]]; then
    echo "  Enforcing"
  elif [[ "$cmd1" == "sestatus" ]]; then
    echo "  SELinux status:                 enabled"
    echo "  Current mode:                   enforcing"
    echo "  Policy from config:             targeted"
  else
    print_error "Hint: Use getenforce or sestatus to check SELinux state."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Ensure source and destination directories exist (silent)
  echo "  Step 2: Prepare the source and destination locations."
  read -p "  lab@lab259:~$ " cmd2a
  if [[ "$cmd2a" == "mkdir -p ${WEB_ROOT}" || "$cmd2a" == "install -d ${WEB_ROOT}" ]]; then :; else
    print_error "Hint: Create ${WEB_ROOT} (e.g., mkdir -p ${WEB_ROOT})."; read -p "Press Enter to try again..." _; continue; fi
  echo
  read -p "  lab@lab259:~$ " cmd2b
  if [[ "$cmd2b" == "mkdir -p ${ETC_DIR}" || "$cmd2b" == "install -d ${ETC_DIR}" ]]; then :; else
    print_error "Hint: Ensure ${ETC_DIR} exists."; read -p "Press Enter to try again..." _; continue; fi
  echo

  # Step 3: Create a source file under the web root (silent)
  echo "  Step 3: Create a sample config file under ${WEB_ROOT}."
  read -p "  lab@lab259:~$ " cmd3
  if [[ "$cmd3" == "touch ${SRC_FILE}" || "$cmd3" == "install -D /dev/null ${SRC_FILE}" ]]; then :; else
    print_error "Hint: Create ${SRC_FILE} (e.g., touch ${SRC_FILE})."; read -p "Press Enter to try again..." _; continue; fi
  echo

  # Step 4: Show the source file's label (should be httpd_sys_content_t)
  echo "  Step 4: Inspect the SELinux label of the source file."
  read -p "  lab@lab259:~$ " cmd4
  if [[ "$cmd4" == "ls -Z ${SRC_FILE}" ]]; then
    echo "  ${CTX_WEB} ${SRC_FILE}"
  else
    print_error "Hint: Use ls -Z ${SRC_FILE}."; read -p "Press Enter to try again..." _; continue
  fi
  echo

  # Step 5: Copy normally into /etc/default (inherit target-dir label)
  echo "  Step 5: Copy the file into ${ETC_DIR} with default behavior."
  read -p "  lab@lab259:~$ " cmd5
  if [[ "$cmd5" == "cp ${SRC_FILE} ${DST_NORM}" ]]; then :; else
    print_error "Hint: A standard copy into ${ETC_DIR} should suffice."; read -p "Press Enter to try again..." _; continue; fi
  echo
  echo "  Step 5 (verify): Check the label of ${DST_NORM}."
  read -p "  lab@lab259:~$ " cmd5v
  if [[ "$cmd5v" == "ls -Z ${DST_NORM}" ]]; then
    echo "  ${CTX_ETC} ${DST_NORM}"
  else
    print_error "Hint: Use ls -Z ${DST_NORM}."; read -p "Press Enter to try again..." _; continue
  fi
  echo

  # Step 6: Copy while preserving context (keeps source label — wrong for /etc)
  echo "  Step 6: Copy again but preserve the source context."
  read -p "  lab@lab259:~$ " cmd6
  if [[ "$cmd6" == "cp -a ${SRC_FILE} ${DST_KEEP}" || "$cmd6" == "cp --preserve=context ${SRC_FILE} ${DST_KEEP}" ]]; then :; else
    print_error "Hint: Use cp -a or cp --preserve=context to retain labels."; read -p "Press Enter to try again..." _; continue; fi
  echo
  echo "  Step 6 (verify): Inspect the preserved-context file's label."
  read -p "  lab@lab259:~$ " cmd6v
  if [[ "$cmd6v" == "ls -Z ${DST_KEEP}" ]]; then
    echo "  ${CTX_WEB} ${DST_KEEP}"
  else
    print_error "Hint: Use ls -Z ${DST_KEEP}."; read -p "Press Enter to try again..." _; continue
  fi
  echo

  # Step 7: Repair the preserved label using restorecon
  echo "  Step 7: Relabel the preserved file to the directory default."
  read -p "  lab@lab259:~$ " cmd7
  if [[ "$cmd7" == "restorecon -v ${DST_KEEP}" ]]; then
    echo "  restorecon reset ${DST_KEEP} context ${CTX_WEB}->${CTX_ETC}"
  else
    print_error "Hint: Use restorecon -v on ${DST_KEEP}."; read -p "Press Enter to try again..." _; continue
  fi
  echo
  echo "  Step 7 (verify): Confirm the corrected label."
  read -p "  lab@lab259:~$ " cmd7v
  if [[ "$cmd7v" == "ls -Z ${DST_KEEP}" ]]; then
    echo "  ${CTX_ETC} ${DST_KEEP}"
  else
    print_error "Hint: Use ls -Z ${DST_KEEP}."; read -p "Press Enter to try again..." _; continue
  fi
  echo

  print_success "Nice work! You demonstrated SELinux label inheritance, preserved-context pitfalls, and how to fix labels with restorecon (simulated)."
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
