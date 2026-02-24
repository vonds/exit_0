#!/bin/bash

# Lab 164: SELinux Basics (Status, Contexts, Booleans, Restorecon)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 164: SELinux Basics"
LAB_ID="lab164"
LAB_XP=8600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  root@lab164:~# "

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

fail_step() {
  print_error "$1"
  read -p "Press Enter to try again..." _
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Verify SELinux state, inspect contexts, toggle a boolean, and restore labels."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  echo "  Step 1: Check SELinux status."
  read -p "$PROMPT" cmd1
  echo
  [[ "$cmd1" == "sestatus" ]] || { fail_step "Use: sestatus"; continue; }

  echo "  SELinux status:                 enabled"
  echo "  Loaded policy name:             targeted"
  echo "  Current mode:                   Enforcing"
  echo "  Mode from config file:          Enforcing"
  echo

  echo "  Step 2: Display current enforcing mode."
  read -p "$PROMPT" cmd2
  echo
  [[ "$cmd2" == "getenforce" ]] || { fail_step "Use: getenforce"; continue; }
  echo "  Enforcing"
  echo

  echo "  Step 3: Show SELinux context for /var/www/html."
  read -p "$PROMPT" cmd3
  echo
  [[ "$cmd3" == "ls -Z /var/www/html" ]] || { fail_step "Use: ls -Z /var/www/html"; continue; }

  echo "  drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 /var/www/html"
  echo

  echo "  Step 4: Create a test file in web root."
  read -p "$PROMPT" cmd4
  echo
  [[ "$cmd4" == "touch /var/www/html/selinux_test.txt" ]] || { fail_step "Use: touch /var/www/html/selinux_test.txt"; continue; }
  echo "  File created."
  echo

  echo "  Step 5: Change its SELinux type to user_home_t."
  read -p "$PROMPT" cmd5
  echo
  [[ "$cmd5" == "chcon -t user_home_t /var/www/html/selinux_test.txt" ]] || {
    fail_step "Use: chcon -t user_home_t /var/www/html/selinux_test.txt"
    continue
  }
  echo "  Context modified."
  echo

  echo "  Step 6: Verify new label."
  read -p "$PROMPT" cmd6
  echo
  [[ "$cmd6" == "ls -Z /var/www/html/selinux_test.txt" ]] || {
    fail_step "Use: ls -Z /var/www/html/selinux_test.txt"
    continue
  }

  echo "  -rw-r--r--. root root system_u:object_r:user_home_t:s0 selinux_test.txt"
  echo

  echo "  Step 7: Restore default context."
  read -p "$PROMPT" cmd7
  echo
  [[ "$cmd7" == "restorecon -v /var/www/html/selinux_test.txt" ]] || {
    fail_step "Use: restorecon -v /var/www/html/selinux_test.txt"
    continue
  }

  echo "  restorecon reset /var/www/html/selinux_test.txt context to httpd_sys_content_t"
  echo

  echo "  Step 8: Check boolean httpd_can_network_connect."
  read -p "$PROMPT" cmd8
  echo
  [[ "$cmd8" == "getsebool httpd_can_network_connect" ]] || {
    fail_step "Use: getsebool httpd_can_network_connect"
    continue
  }
  echo "  httpd_can_network_connect --> off"
  echo

  echo "  Step 9: Enable that boolean persistently."
  read -p "$PROMPT" cmd9
  echo
  [[ "$cmd9" == "setsebool -P httpd_can_network_connect on" ]] || {
    fail_step "Use: setsebool -P httpd_can_network_connect on"
    continue
  }
  echo "  Boolean updated."
  echo

  echo "  Step 10: Cleanup: disable boolean and remove file."
  read -p "$PROMPT" cleanup1
  echo
  [[ "$cleanup1" == "setsebool -P httpd_can_network_connect off" ]] || {
    fail_step "Use: setsebool -P httpd_can_network_connect off"
    continue
  }

  read -p "$PROMPT" cleanup2
  echo
  [[ "$cleanup2" == "rm -f /var/www/html/selinux_test.txt" ]] || {
    fail_step "Use: rm -f /var/www/html/selinux_test.txt"
    continue
  }

  print_success "Nice work!"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "1) Retry"
  center_text "2) Return to Menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done