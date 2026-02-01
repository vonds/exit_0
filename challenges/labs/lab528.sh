#!/bin/bash

# Lab 528: Restore Default SELinux File Contexts (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 528: Restore Default SELinux File Contexts"
LAB_ID="lab528"
LAB_XP=52800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab528:~$ "

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
  center_text "Scenario:"
  center_text "A service is failing because some files have incorrect SELinux contexts."
  center_text "You must identify the expected default context, confirm the actual context,"
  center_text "intentionally break a context, then restore defaults with restorecon."
  echo
  center_text "Targets:"
  center_text "- ls -Z (actual SELinux context)"
  center_text "- matchpathcon (expected default SELinux context)"
  center_text "- chcon (temporary context change, simulates a mistake)"
  center_text "- restorecon (restore default contexts from policy)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Confirm SELinux is enabled and note the current mode."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sestatus" ]]; then
    print_error "Incorrect. Use: sestatus"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  SELinux status:                 enabled"
  echo "  Current mode:                   enforcing"
  echo

  echo "  Step 2: Create a test file under /var/www/html to work with."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo mkdir -p /var/www/html && sudo touch /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /var/www/html && sudo touch /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Show the expected default SELinux context for the file (policy view)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "matchpathcon /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: matchpathcon /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /var/www/html/index.html system_u:object_r:httpd_sys_content_t:s0"
  echo

  echo "  Step 4: Show the file's current SELinux context (actual on-disk label)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls -Z /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -Z /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html"
  echo

  echo "  Step 5: Simulate a bad context change on the file (temporary label change)."
  echo "          Change it to a clearly wrong type for web content."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo chcon -t etc_t /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: sudo chcon -t etc_t /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Verify the file is now mislabeled (actual context should show etc_t)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls -Z /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -Z /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:object_r:etc_t:s0 /var/www/html/index.html"
  echo

  echo "  Step 7: Restore the default context for the file using restorecon."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo restorecon -v /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: sudo restorecon -v /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  restorecon reset /var/www/html/index.html context system_u:object_r:httpd_sys_content_t:s0"
  echo

  echo "  Step 8: Verify the file label matches the policy again (ls -Z)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "ls -Z /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -Z /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html"
  echo

  echo "  Step 9: Restore defaults for the whole directory recursively (common RHCSA move)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo restorecon -Rv /var/www/html" ]]; then
    print_error "Incorrect. Use: sudo restorecon -Rv /var/www/html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  restorecon reset /var/www/html context system_u:object_r:httpd_sys_content_t:s0"
  echo "  restorecon reset /var/www/html/index.html context system_u:object_r:httpd_sys_content_t:s0"
  echo

  echo "  Step 10: Compare expected vs actual one more time (matchpathcon then ls -Z)."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "matchpathcon /var/www/html/index.html && ls -Z /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: matchpathcon /var/www/html/index.html && ls -Z /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /var/www/html/index.html system_u:object_r:httpd_sys_content_t:s0"
  echo "  system_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html"
  echo

  echo "  Step 11: Clean up: remove the test directory."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo rm -rf /var/www/html" ]]; then
    print_error "Incorrect. Use: sudo rm -rf /var/www/html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- checked expected default contexts with matchpathcon"
  print_info "- checked actual labels with ls -Z"
  print_info "- simulated a mislabeled file with chcon"
  print_info "- restored defaults with restorecon (file + recursive directory)"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done
