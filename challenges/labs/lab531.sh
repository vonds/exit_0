#!/bin/bash

# Lab 531: Diagnose and Address Routine SELinux Policy Violations (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 531: Diagnose SELinux AVC Denials (RHCSA)"
LAB_ID="lab531"
LAB_XP=53100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab531:~$ "

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
  center_text "A web service is failing due to SELinux policy violations."
  center_text "You must identify AVC denials, interpret key fields, and apply"
  center_text "the correct fix (restore contexts, adjust booleans, verify)."
  echo
  center_text "Targets:"
  center_text "- Find AVC denials in /var/log/audit/audit.log"
  center_text "- Use ausearch to filter SELinux denials"
  center_text "- Use sealert for recommendations (if available)"
  center_text "- Fix mislabeled files with restorecon"
  center_text "- Fix recurring behavior with persistent booleans (-P)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Confirm SELinux is enabled and enforcing."
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

  echo "  Step 2: View recent AVC denials in the audit log (filter for AVC)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo grep AVC /var/log/audit/audit.log | tail" ]]; then
    print_error "Incorrect. Use: sudo grep AVC /var/log/audit/audit.log | tail"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  type=AVC msg=audit(1700000000.111:101): avc:  denied  { read } for  pid=2222 comm='httpd' name='index.html' dev='sda1' ino=12345 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0"
  echo

  echo "  Step 3: Use ausearch to show today's AVC denials."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo ausearch -m avc -ts today" ]]; then
    print_error "Incorrect. Use: sudo ausearch -m avc -ts today"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  type=AVC msg=audit(1700000000.111:101): avc:  denied  { read } for  pid=2222 comm='httpd' name='index.html' scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0"
  echo

  echo "  Step 4: Identify the SELinux context on the file that httpd is trying to access."
  echo "          Check the context of /var/www/html/index.html."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls -Z /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -Z /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  unconfined_u:object_r:default_t:s0 /var/www/html/index.html"
  echo

  echo "  Step 5: Restore the default context on /var/www/html recursively (persistent fix for mislabeling)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo restorecon -Rv /var/www/html" ]]; then
    print_error "Incorrect. Use: sudo restorecon -Rv /var/www/html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  restorecon reset /var/www/html/index.html context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0"
  echo

  echo "  Step 6: Verify the file now has the expected context."
  read -p "$PROMPT" cmd6
  echo
  if
