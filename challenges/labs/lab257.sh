#!/bin/bash

# Lab 257: SELinux persistent contexts — semanage fcontext + restorecon — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real files/labels are changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 257: semanage fcontext + restorecon (persistent)"
LAB_ID="lab257"
LAB_XP=21480
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated paths & contexts (NOT your real system)
APP_DIR="/srv/app"
PUB_DIR="${APP_DIR}/public"
FILE1="${PUB_DIR}/index.html"
FILE2="${PUB_DIR}/style.css"

CTX_DEFAULT="unconfined_u:object_r:default_t:s0"
CTX_HTTPD="unconfined_u:object_r:httpd_sys_content_t:s0"

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
  center_text "Goal: Add a persistent SELinux context mapping with semanage fcontext for ${PUB_DIR},"
  center_text "apply it using restorecon, and verify labels (SIMULATED). Optional: remove mapping."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm SELinux is enabled/enforcing
  draw_lab_ui
  echo "  Step 1: Show SELinux mode."
  read -p "  lab@lab257:~$ " cmd1
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

  # Step 2: Create target directory (silent)
  echo "  Step 2: Create ${PUB_DIR} (and parents)."
  read -p "  lab@lab257:~$ " cmd2
  if [[ "$cmd2" == "mkdir -p ${PUB_DIR}" || "$cmd2" == "install -d ${PUB_DIR}" ]]; then
    :
  else
    print_error "Hint: Make sure the directory exists (mkdir -p ${PUB_DIR})."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Create an example file (silent)
  echo "  Step 3: Create ${FILE1}."
  read -p "  lab@lab257:~$ " cmd3
  if [[ "$cmd3" == "touch ${FILE1}" ]]; then
    :
  else
    print_error "Hint: Create a file under ${PUB_DIR} (e.g., touch ${FILE1})."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Show current (pre-policy) contexts
  echo "  Step 4: Inspect current SELinux contexts (before policy)."
  read -p "  lab@lab257:~$ " cmd4a
  if [[ "$cmd4a" == "ls -Zd ${PUB_DIR}" ]]; then
    echo "  ${CTX_DEFAULT} ${PUB_DIR}"
  else
    print_error "Hint: Use ls -Zd ${PUB_DIR}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab257:~$ " cmd4b
  if [[ "$cmd4b" == "ls -Z ${FILE1}" ]]; then
    echo "  ${CTX_DEFAULT} ${FILE1}"
  else
    print_error "Hint: Use ls -Z ${FILE1}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Add persistent mapping with semanage fcontext (silent)
  echo "  Step 5: Add a persistent mapping to label everything under ${PUB_DIR} as httpd_sys_content_t."
  read -p "  lab@lab257:~$ " cmd5
  if [[ "$cmd5" == "semanage fcontext -a -t httpd_sys_content_t '${PUB_DIR}(/.*)?'" || \
        "$cmd5" == "semanage fcontext -a -t httpd_sys_content_t ${PUB_DIR}'(/.*)?'" || \
        "$cmd5" == "semanage fcontext -a -t httpd_sys_content_t ${PUB_DIR}(/.*)?" ]]; then
    :
  else
    print_error "Hint: Use semanage fcontext -a -t httpd_sys_content_t '${PUB_DIR}(/.*)?'"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Verify mapping exists
  echo "  Step 6: Show the mapping you added."
  read -p "  lab@lab257:~$ " cmd6
  if [[ "$cmd6" == "semanage fcontext -l | grep ${PUB_DIR}" ]]; then
    echo "  ${PUB_DIR}(/.*)?                                  all files          system_u:object_r:httpd_sys_content_t:s0"
  else
    print_error "Hint: List fcontext rules and grep for ${PUB_DIR}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Apply the mapping to filesystem labels
  echo "  Step 7: Apply labels according to the mapping."
  read -p "  lab@lab257:~$ " cmd7
  if [[ "$cmd7" == "restorecon -Rv ${PUB_DIR}" || "$cmd7" == "restorecon -Rvv ${PUB_DIR}" ]]; then
    echo "  restorecon reset ${PUB_DIR} context ${CTX_DEFAULT}->${CTX_HTTPD}"
    echo "  restorecon reset ${FILE1} context ${CTX_DEFAULT}->${CTX_HTTPD}"
  else
    print_error "Hint: Use restorecon -Rv ${PUB_DIR} to relabel recursively."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Confirm new contexts
  echo "  Step 8: Verify the new labels."
  read -p "  lab@lab257:~$ " cmd8a
  if [[ "$cmd8a" == "ls -Zd ${PUB_DIR}" ]]; then
    echo "  ${CTX_HTTPD} ${PUB_DIR}"
  else
    print_error "Hint: Use ls -Zd ${PUB_DIR}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab257:~$ " cmd8b
  if [[ "$cmd8b" == "ls -Z ${FILE1}" ]]; then
    echo "  ${CTX_HTTPD} ${FILE1}"
  else
    print_error "Hint: Use ls -Z ${FILE1}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Create a new file and prove it can be labeled via restorecon
  echo "  Step 9: Add another file under ${PUB_DIR}."
  read -p "  lab@lab257:~$ " cmd9a
  if [[ "$cmd9a" == "touch ${FILE2}" ]]; then
    :
  else
    print_error "Hint: Create ${FILE2}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 9 (verify): Check its label before relabeling."
  read -p "  lab@lab257:~$ " cmd9b
  if [[ "$cmd9b" == "ls -Z ${FILE2}" ]]; then
    echo "  ${CTX_DEFAULT} ${FILE2}"
  else
    print_error "Hint: Use ls -Z ${FILE2} to see the current label."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 9 (apply): Relabel the new file using restorecon."
  read -p "  lab@lab257:~$ " cmd9c
  if [[ "$cmd9c" == "restorecon -v ${FILE2}" ]]; then
    echo "  restorecon reset ${FILE2} context ${CTX_DEFAULT}->${CTX_HTTPD}"
  else
    print_error "Hint: Use restorecon -v ${FILE2}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 9 (verify): Confirm the new label."
  read -p "  lab@lab257:~$ " cmd9d
  if [[ "$cmd9d" == "ls -Z ${FILE2}" ]]; then
    echo "  ${CTX_HTTPD} ${FILE2}"
  else
    print_error "Hint: Use ls -Z ${FILE2}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 10 (optional): Remove mapping and revert labels
  echo "  Step 10 (optional): Remove the fcontext rule and revert labels."
  read -p "  lab@lab257:~$ " cmd10a
  if [[ -z "$cmd10a" || "$cmd10a" == "semanage fcontext -d '${PUB_DIR}(/.*)?'" || "$cmd10a" == "semanage fcontext -d ${PUB_DIR}(/.*)?" ]]; then
    if [[ -n "$cmd10a" ]]; then
      # rule removed
      :
    fi
  else
    print_error "Hint: Use semanage fcontext -d '${PUB_DIR}(/.*)?' (or press Enter to skip)."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ -n "$cmd10a" ]]; then
    echo
    read -p "  lab@lab257:~$ " cmd10b
    if [[ "$cmd10b" == "restorecon -Rv ${PUB_DIR}" ]]; then
      echo "  restorecon reset ${FILE2} context ${CTX_HTTPD}->${CTX_DEFAULT}"
      echo "  restorecon reset ${FILE1} context ${CTX_HTTPD}->${CTX_DEFAULT}"
      echo "  restorecon reset ${PUB_DIR} context ${CTX_HTTPD}->${CTX_DEFAULT}"
    else
      print_error "Hint: Apply with restorecon -Rv ${PUB_DIR} (or press Enter earlier to skip)."
      read -p "Press Enter to try again..." _
      continue
    fi
    echo
  fi

  print_success "Nice work! You added a persistent SELinux mapping with semanage fcontext, applied it via restorecon, and verified labels (simulated)."
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
