#!/bin/bash

# Lab 194: Script + Cron — Backup /etc nightly at 23:00, except Sundays (Shell Scripting)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 194: Nightly /etc Backup (No Sundays)"
LAB_ID="lab194"
LAB_XP=26000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SCRIPT_PATH="/root/bin/backup_etc.sh"
CRON_FILE="/etc/cron.d/backup_etc"
LOG_FILE="/var/log/backup_etc.log"

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
  center_text "Goal: Create /root/bin/backup_etc.sh to tar.gz /etc into /root/backup/etc-YYYYMMDD.tgz."
  center_text "Schedule it at 23:00 (Mon–Sat) via /etc/cron.d (no Sundays)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Ensure /root/bin (silent)
  draw_lab_ui
  echo "  Step 1: Ensure /root/bin exists."
  echo "          Expected: mkdir -p /root/bin"
  read -p "  lab@lab194:~$ " s1
  [[ "$s1" != "mkdir -p /root/bin" ]] && { print_error "Use: mkdir -p /root/bin"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Write the backup script (silent)
  echo "  Step 2: Create the script at $SCRIPT_PATH (use: cat > $SCRIPT_PATH) with lines:"
  echo "#!/bin/bash"
  echo 'set -e'
  echo 'OUTDIR="/root/backup"'
  echo 'mkdir -p "$OUTDIR"'
  echo 'STAMP=$(date +%Y%m%d)'
  echo 'ARCHIVE="$OUTDIR/etc-$STAMP.tgz"'
  echo 'tar -czf "$ARCHIVE" /etc'
  echo 'echo "Backup created: $ARCHIVE"'
  read -p "  lab@lab194:~$ " s2
  [[ "$s2" != "cat > /root/bin/backup_etc.sh" ]] && { print_error "Use exactly: cat > /root/bin/backup_etc.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Make executable (silent)
  echo "  Step 3: Make it executable."
  echo "          Expected: chmod +x $SCRIPT_PATH"
  read -p "  lab@lab194:~$ " s3
  [[ "$s3" != "chmod +x /root/bin/backup_etc.sh" ]] && { print_error "Use: chmod +x /root/bin/backup_etc.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Show script (prints file)
  echo "  Step 4: Display the script content."
  echo "          Expected: cat $SCRIPT_PATH"
  read -p "  lab@lab194:~$ " s4
  [[ "$s4" != "cat /root/bin/backup_etc.sh" ]] && { print_error "Use: cat /root/bin/backup_etc.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "#!/bin/bash"
  echo "set -e"
  echo 'OUTDIR="/root/backup"'
  echo 'mkdir -p "$OUTDIR"'
  echo 'STAMP=$(date +%Y%m%d)'
  echo 'ARCHIVE="$OUTDIR/etc-$STAMP.tgz"'
  echo 'tar -czf "$ARCHIVE" /etc'
  echo 'echo "Backup created: $ARCHIVE"'
  echo

  # Step 5: Test-run the script once (shows its own echo output)
  echo "  Step 5: Execute the script once."
  echo "          Expected: /root/bin/backup_etc.sh"
  read -p "  lab@lab194:~$ " s5
  [[ "$s5" != "/root/bin/backup_etc.sh" ]] && { print_error "Use: /root/bin/backup_etc.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "Backup created: /root/backup/etc-$(date +%Y%m%d).tgz"
  echo

  # Step 6: Create cron.d entry (silent). Note: cron.d requires a user field.
  echo "  Step 6: Create a cron.d file to run at 23:00 Mon–Sat (1-6)."
  echo "          Use: echo '0 23 * * 1-6 root /root/bin/backup_etc.sh >$LOG_FILE 2>&1' > $CRON_FILE"
  read -p "  lab@lab194:~$ " s6
  [[ "$s6" != "echo '0 23 * * 1-6 root /root/bin/backup_etc.sh >/var/log/backup_etc.log 2>&1' > /etc/cron.d/backup_etc" ]] && {
    print_error "Use exactly: echo '0 23 * * 1-6 root /root/bin/backup_etc.sh >/var/log/backup_etc.log 2>&1' > /etc/cron.d/backup_etc";
    read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 7: Show cron file content (outputs the line)
  echo "  Step 7: Display the cron.d file."
  echo "          Expected: cat $CRON_FILE"
  read -p "  lab@lab194:~$ " s7
  [[ "$s7" != "cat /etc/cron.d/backup_etc" ]] && { print_error "Use: cat /etc/cron.d/backup_etc"; read -p "Press Enter to try again..." _; continue; }
  echo "0 23 * * 1-6 root /root/bin/backup_etc.sh >/var/log/backup_etc.log 2>&1"
  echo

  # Step 8: Confirm file exists in cron.d (list shows the file)
  echo "  Step 8: List the cron.d entry."
  echo "          Expected: ls -l $CRON_FILE"
  read -p "  lab@lab194:~$ " s8
  [[ "$s8" != "ls -l /etc/cron.d/backup_etc" ]] && { print_error "Use: ls -l /etc/cron.d/backup_etc"; read -p "Press Enter to try again..." _; continue; }
  echo "-rw-r--r-- 1 root root 84 $(date +%b' '%e' '%H:%M) /etc/cron.d/backup_etc"
  echo

  print_success "Nice work!"
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
