#!/bin/bash

# Lab 358: RHEL Troubleshooting — user gets "Permission denied" but permissions look correct (SELinux context issue)
# RHCSA focus: diagnosing access failures beyond rwx (SELinux), checking contexts (ls -Z),
# inspecting denials (ausearch/journalctl), restoring correct contexts (restorecon),
# and verifying access works for the user.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 358"
LAB_ID="lab358"
LAB_XP=35800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
}

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

PROMPT="student@lab358:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — user 'devstudent' reports: Permission denied accessing /srv/share/report.txt"
  center_text "Permissions look correct. Diagnose the real cause and restore access safely."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm the permissions look correct on the file and its directory."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "ls -ld /srv/share && ls -l /srv/share/report.txt" ]]; then
    print_error "Incorrect. Use: ls -ld /srv/share && ls -l /srv/share/report.txt"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  drwxrwxr-x. 2 root root 24 Dec 21 12:05 /srv/share"
  echo "  -rw-rw-r--. 1 root root 18 Dec 21 12:05 /srv/share/report.txt"

  # STEP 2
  echo
  echo "  Step 2: Reproduce the failure as the user."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "sudo -u devstudent cat /srv/share/report.txt" ]]; then
    print_error "Incorrect. Use: sudo -u devstudent cat /srv/share/report.txt"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  cat: /srv/share/report.txt: Permission denied"

  # STEP 3
  echo
  echo "  Step 3: Check SELinux mode."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "getenforce" && "$cmd3" != "sudo getenforce" ]]; then
    print_error "Incorrect. Use: getenforce"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Enforcing"

  # STEP 4
  echo
  echo "  Step 4: Check SELinux contexts on the directory and file."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "ls -Zd /srv/share && ls -Z /srv/share/report.txt" ]]; then
    print_error "Incorrect. Use: ls -Zd /srv/share && ls -Z /srv/share/report.txt"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  unconfined_u:object_r:admin_home_t:s0 /srv/share"
  echo "  unconfined_u:object_r:admin_home_t:s0 root root /srv/share/report.txt"

  # STEP 5
  echo
  echo "  Step 5: Search for recent SELinux denials related to this path."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo ausearch -m AVC -ts recent | tail -n 5" ]]; then
    print_error "Incorrect. Use: sudo ausearch -m AVC -ts recent | tail -n 5"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ----"
  echo "  time->Sun Dec 21 12:06:10 2025"
  echo "  type=AVC msg=audit(1766331970.414:210): avc:  denied  { read } for  pid=2214 comm=\"cat\" name=\"report.txt\""
  echo "  dev=\"sda2\" ino=104981 scontext=system_u:system_r:unconfined_service_t:s0 tcontext=unconfined_u:object_r:admin_home_t:s0 tclass=file permissive=0"

  # STEP 6
  echo
  echo "  Step 6: Restore default SELinux contexts for /srv/share."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo restorecon -Rv /srv/share" ]]; then
    print_error "Incorrect. Use: sudo restorecon -Rv /srv/share"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Relabeled /srv/share from unconfined_u:object_r:admin_home_t:s0 to unconfined_u:object_r:var_t:s0"
  echo "  Relabeled /srv/share/report.txt from unconfined_u:object_r:admin_home_t:s0 to unconfined_u:object_r:var_t:s0"

  # STEP 7
  echo
  echo "  Step 7: Verify contexts changed."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "ls -Zd /srv/share && ls -Z /srv/share/report.txt" ]]; then
    print_error "Incorrect. Use: ls -Zd /srv/share && ls -Z /srv/share/report.txt"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  unconfined_u:object_r:var_t:s0 /srv/share"
  echo "  unconfined_u:object_r:var_t:s0 root root /srv/share/report.txt"

  # STEP 8
  echo
  echo "  Step 8: Re-test access as the user."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo -u devstudent cat /srv/share/report.txt" ]]; then
    print_error "Incorrect. Use: sudo -u devstudent cat /srv/share/report.txt"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  quarterly report: OK"

  # STEP 9
  echo
  echo "  Step 9: Verify no new SELinux denials appear for this action."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "sudo ausearch -m AVC -ts recent | tail -n 3" ]]; then
    print_error "Incorrect. Use: sudo ausearch -m AVC -ts recent | tail -n 3"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  <no new AVC denials>"

  print_success "Excellent work!"
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done
