#!/bin/bash

# Lab 284: Mastering the 'find' Command (time, type, size, and actions)
# - Cover file type filtering
# - Search by time (mtime, atime, ctime, minutes)
# - Search by size (+, -, exact)
# - Act on matched sets (-delete, -exec, -print, etc.)
# Output policy: Only real-world terminal outputs where appropriate.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 284: Find Command Mastery"
LAB_ID="lab284"
LAB_XP=35000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
  center_text "Goal: Practice exhaustive use of 'find' with time, type, size, and actions."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Find by file type
  draw_lab_ui
  echo "  Step 1: Find all directories under /etc."
  read -p "  lab@lab284:~$ " s1
  [[ "$s1" != "find /etc -type d" ]] && { print_error "Use: find /etc -type d"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  /etc"
  echo "  /etc/ssh"
  echo "  /etc/pki"
  echo

  # Step 2: Find by file type (regular files)
  echo "  Step 2: Find all regular files under /etc/ssh."
  read -p "  lab@lab284:~$ " s2
  [[ "$s2" != "find /etc/ssh -type f" ]] && { print_error "Use: find /etc/ssh -type f"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  /etc/ssh/ssh_config"
  echo "  /etc/ssh/sshd_config"
  echo

  # Step 3: Find by modification time
  echo "  Step 3: Find files modified in the last 24 hours under /var/log."
  read -p "  lab@lab284:~$ " s3
  [[ "$s3" != "find /var/log -mtime -1" ]] && { print_error "Use: find /var/log -mtime -1"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  /var/log/messages"
  echo "  /var/log/secure"
  echo

  # Step 4: Find by access time
  echo "  Step 4: Find files accessed more than 7 days ago in /home."
  read -p "  lab@lab284:~$ " s4
  [[ "$s4" != "find /home -atime +7" ]] && { print_error "Use: find /home -atime +7"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  /home/alice/.bash_history"
  echo "  /home/bob/old_notes.txt"
  echo

  # Step 5: Find by file size
  echo "  Step 5: Find files larger than 100MB under /var."
  read -p "  lab@lab284:~$ " s5
  [[ "$s5" != "find /var -size +100M" ]] && { print_error "Use: find /var -size +100M"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  /var/lib/largefile.iso"
  echo

  # Step 6: Find by exact file size
  echo "  Step 6: Find files exactly 1M in size under /tmp."
  read -p "  lab@lab284:~$ " s6
  [[ "$s6" != "find /tmp -size 1M" ]] && { print_error "Use: find /tmp -size 1M"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  /tmp/testfile"
  echo

  # Step 7: Execute command on matches
  echo "  Step 7: Find all .conf files under /etc and list detailed info with ls -l."
  read -r -p "  lab@lab284:~$ " s7
  [[ "$s7" != "find /etc -name '*.conf' -exec ls -l {} \\;" ]] && { print_error "Use: find /etc -name '*.conf' -exec ls -l {} \\;"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  -rw-r--r--. 1 root root 1586 Sep 21 09:00 /etc/ssh/sshd_config"
  echo "  -rw-r--r--. 1 root root  450 Sep 21 09:00 /etc/ssh/ssh_config"
  echo

  # Step 8: Delete with find
  echo "  Step 8: Find and delete all .tmp files under /tmp."
  read -p "  lab@lab284:~$ " s8
  [[ "$s8" != "find /tmp -name '*.tmp' -delete" ]] && { print_error "Use: find /tmp -name '*.tmp' -delete"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 9: Use multiple tests
  echo "  Step 9: Find all world-writable files larger than 10M under /var."
  read -p "  lab@lab284:~$ " s9
  [[ "$s9" != "find /var -type f -size +10M -perm -002" ]] && { print_error "Use: find /var -type f -size +10M -perm -002"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  /var/tmp/big_unsecure.log"
  echo

  # Step 10: Combine actions
  echo "  Step 10: Find files owned by root in /var/www and copy them to /root/backups."
  read -r -p "  lab@lab284:~$ " s10
  [[ "$s10" != "find /var/www -user root -exec cp {} /root/backups/ \\;" ]] && { print_error "Use: find /var/www -user root -exec cp {} /root/backups/ \\;"; read -p "Press Enter to try again..." _; continue; }
  echo

  print_success "Excellent! You've mastered 'find' with time, type, size, and actions."
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
