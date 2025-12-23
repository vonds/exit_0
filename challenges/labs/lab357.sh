#!/bin/bash

# Lab 357: RHEL Troubleshooting — root filesystem is full; reclaim space without deleting user data
# RHCSA focus: identifying disk usage (df/du), locating large files/directories, cleaning safe caches/logs,
# vacuuming journald, truncating logs safely, removing unused packages safely, and verifying recovered space.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 357"
LAB_ID="lab357"
LAB_XP=35700
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

PROMPT="student@lab357:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — root filesystem (/) is full and the system is unstable."
  center_text "Interactive: identify what's consuming space and reclaim it without deleting user data."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm root filesystem usage."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "df -h /" && "$cmd1" != "df -h" ]]; then
    print_error "Incorrect. Use: df -h /   (or: df -h)"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Filesystem      Size  Used Avail Use% Mounted on"
  echo "  /dev/sda2        30G   30G   80M 100% /"

  # STEP 2
  echo
  echo "  Step 2: Identify the largest directories on / (quick high-level scan)."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "sudo du -xhd1 / | sort -h" ]]; then
    print_error "Incorrect. Use: sudo du -xhd1 / | sort -h"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  0       /dev"
  echo "  1.1G    /boot"
  echo "  1.4G    /etc"
  echo "  2.0G    /home"
  echo "  2.6G    /usr"
  echo "  3.8G    /var"
  echo "  18G     /var/log"
  echo "  29G     /"

  # STEP 3
  echo
  echo "  Step 3: Confirm what's consuming space under /var/log."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "sudo du -h /var/log | sort -h | tail -n 10" ]]; then
    print_error "Incorrect. Use: sudo du -h /var/log | sort -h | tail -n 10"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  120M    /var/log/audit"
  echo "  240M    /var/log/cron"
  echo "  510M    /var/log/messages"
  echo "  1.2G    /var/log/secure"
  echo "  3.0G    /var/log/journal"
  echo "  12G     /var/log/httpd/access_log"
  echo "  18G     /var/log"

  # STEP 4
  echo
  echo "  Step 4: Check journald disk usage (journal files)."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "journalctl --disk-usage" && "$cmd4" != "sudo journalctl --disk-usage" ]]; then
    print_error "Incorrect. Use: journalctl --disk-usage"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Archived and active journals take up 3.0G in the file system."

  # STEP 5
  echo
  echo "  Step 5: Vacuum journald to reclaim space safely (keep only 200M)."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo journalctl --vacuum-size=200M" ]]; then
    print_error "Incorrect. Use: sudo journalctl --vacuum-size=200M"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Vacuuming done, freed 2.8G of archived journals from /var/log/journal."

  # STEP 6
  echo
  echo "  Step 6: Identify the huge web access log file."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo ls -lh /var/log/httpd/access_log" ]]; then
    print_error "Incorrect. Use: sudo ls -lh /var/log/httpd/access_log"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  -rw-r--r--. 1 root root 12G Dec 21 11:40 /var/log/httpd/access_log"

  # STEP 7
  echo
  echo "  Step 7: Truncate the giant log file without deleting it (preserve file and permissions)."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo truncate -s 0 /var/log/httpd/access_log" ]]; then
    print_error "Incorrect. Use: sudo truncate -s 0 /var/log/httpd/access_log"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 8
  echo
  echo "  Step 8: Clean package manager caches to reclaim additional space."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo dnf clean all" ]]; then
    print_error "Incorrect. Use: sudo dnf clean all"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  35 files removed"
  echo "  2.1G freed"

  # STEP 9
  echo
  echo "  Step 9: Verify root filesystem free space recovered."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "df -h /" && "$cmd9" != "df -h" ]]; then
    print_error "Incorrect. Use: df -h /   (or: df -h)"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Filesystem      Size  Used Avail Use% Mounted on"
  echo "  /dev/sda2        30G   24G   6.1G  80% /"

  # STEP 10
  echo
  echo "  Step 10: Prove user data was not deleted (check /home exists)."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "ls -ld /home" && "$cmd10" != "sudo ls -ld /home" ]]; then
    print_error "Incorrect. Use: ls -ld /home"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  drwxr-xr-x. 3 root root 19 Dec 20 09:12 /home"

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
