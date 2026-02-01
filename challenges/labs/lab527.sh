#!/bin/bash

# Lab 527: List and Identify SELinux File + Process Contexts (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 527: SELinux Contexts (Files + Processes)"
LAB_ID="lab527"
LAB_XP=52700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab527:~$ "

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
  center_text "A web content directory is being prepared for a future Apache deployment."
  center_text "You must inspect SELinux file contexts, inspect process contexts,"
  center_text "add a persistent fcontext rule, apply it with restorecon, and verify."
  echo
  center_text "Targets:"
  center_text "- ls -Z (file contexts)"
  center_text "- ps -eZ (process contexts)"
  center_text "- semanage fcontext (persistent rules)"
  center_text "- restorecon (apply contexts)"
  center_text "- verification with ls -Z and ps -eZ"
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

  echo "  Step 2: Create a web content directory and a test file."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo mkdir -p /var/www/html && sudo touch /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /var/www/html && sudo touch /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: List SELinux contexts for the directory and file."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ls -Zd /var/www/html && ls -Z /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -Zd /var/www/html && ls -Z /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:object_r:httpd_sys_content_t:s0 /var/www/html"
  echo "  system_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html"
  echo

  echo "  Step 4: Show SELinux context fields for a system file (use /etc/passwd)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls -Z /etc/passwd" ]]; then
    print_error "Incorrect. Use: ls -Z /etc/passwd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:object_r:etc_t:s0 /etc/passwd"
  echo

  echo "  Step 5: List SELinux process contexts and find the sshd entries."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ps -eZ | grep sshd" ]]; then
    print_error "Incorrect. Use: ps -eZ | grep sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:system_r:sshd_t:s0    1040 ?        00:00:00 sshd"
  echo

  echo "  Step 6: Install the tools that provide semanage if needed."
  echo "          (On RHEL, semanage is provided by policycoreutils-python-utils.)"
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo dnf install -y policycoreutils-python-utils" ]]; then
    print_error "Incorrect. Use: sudo dnf install -y policycoreutils-python-utils"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Add a persistent SELinux file context rule for web content."
  echo "          Apply the rule to /var/www/html and everything under it."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo semanage fcontext -a -t httpd_sys_content_t '/var/www/html(/.*)?'" ]]; then
    print_error "Incorrect. Use: sudo semanage fcontext -a -t httpd_sys_content_t '/var/www/html(/.*)?'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Apply the saved fcontext rule to the directory recursively."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo restorecon -Rv /var/www/html" ]]; then
    print_error "Incorrect. Use: sudo restorecon -Rv /var/www/html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  restorecon reset /var/www/html context system_u:object_r:httpd_sys_content_t:s0"
  echo "  restorecon reset /var/www/html/index.html context system_u:object_r:httpd_sys_content_t:s0"
  echo

  echo "  Step 9: Verify the contexts again after restorecon."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "ls -Zd /var/www/html && ls -Z /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -Zd /var/www/html && ls -Z /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:object_r:httpd_sys_content_t:s0 /var/www/html"
  echo "  system_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html"
  echo

  echo "  Step 10: List the local custom SELinux file context rules you added."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo semanage fcontext -l | grep '/var/www/html'" ]]; then
    print_error "Incorrect. Use: sudo semanage fcontext -l | grep '/var/www/html'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /var/www/html(/.*)?    all files    system_u:object_r:httpd_sys_content_t:s0"
  echo

  echo "  Step 11: Clean up: remove the custom fcontext rule."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo semanage fcontext -d '/var/www/html(/.*)?'" ]]; then
    print_error "Incorrect. Use: sudo semanage fcontext -d '/var/www/html(/.*)?'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 12: Clean up: remove the test directory."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo rm -rf /var/www/html" ]]; then
    print_error "Incorrect. Use: sudo rm -rf /var/www/html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- identified SELinux file contexts with ls -Z"
  print_info "- identified SELinux process contexts with ps -eZ"
  print_info "- created a persistent fcontext rule with semanage"
  print_info "- applied and verified contexts with restorecon"
  print_info "- verified custom rules and cleaned up safely"
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
