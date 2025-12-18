#!/bin/bash

# Lab 200: Journald persistence, rsyslog info rule, logrotate retention (Operate Running Systems)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 200: Journald + rsyslog + logrotate"
LAB_ID="lab200"
LAB_XP=26000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

RSYS_FILE="/etc/rsyslog.d/10-info.conf"
LOG_FILE="/var/log/messages.info"
ROTATE_FILE="/etc/logrotate.d/messages-info"

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
  center_text "Goal: Make journald persistent, log *.info to /var/log/messages.info via rsyslog, keep 10 rotated copies."
  echo
  center_text "Press Enter to begin..."
  read _

  # === Part 1: journald persistent ===
  draw_lab_ui
  echo "  Part 1 — Journald persistence"
  echo "  Step 1: Set Storage=persistent in /etc/systemd/journald.conf."
  echo "          Expected: vi /etc/systemd/journald.conf"
  read -p "  lab@lab200:~$ " s1
  [[ "$s1" != "vi /etc/systemd/journald.conf" ]] && { print_error "Use: vi /etc/systemd/journald.conf"; read -p "Press Enter to try again..." _; continue; }
  echo

  echo "  Step 2: Verify Storage is set to persistent."
  echo "          Expected: grep ^Storage= /etc/systemd/journald.conf"
  read -p "  lab@lab200:~$ " s2
  [[ "$s2" != "grep ^Storage= /etc/systemd/journald.conf" ]] && { print_error "Use: grep ^Storage= /etc/systemd/journald.conf"; read -p "Press Enter to try again..." _; continue; }
  echo "Storage=persistent"
  echo

  echo "  Step 3: Restart systemd-journald (no output expected)."
  echo "          Expected: systemctl restart systemd-journald"
  read -p "  lab@lab200:~$ " s3
  [[ "$s3" != "systemctl restart systemd-journald" ]] && { print_error "Use: systemctl restart systemd-journald"; read -p "Press Enter to try again..." _; continue; }
  echo

  echo "  Step 4: Confirm on-disk journal exists."
  echo "          Expected: ls -d /var/log/journal"
  read -p "  lab@lab200:~$ " s4
  [[ "$s4" != "ls -d /var/log/journal" ]] && { print_error "Use: ls -d /var/log/journal"; read -p "Press Enter to try again..." _; continue; }
  echo "/var/log/journal"
  echo

  echo "  Step 5: Show current journal disk usage."
  echo "          Expected: journalctl --disk-usage"
  read -p "  lab@lab200:~$ " s5
  [[ "$s5" != "journalctl --disk-usage" ]] && { print_error "Use: journalctl --disk-usage"; read -p "Press Enter to try again..." _; continue; }
  echo "Archived and active journals take up 8.0M in the file system."
  echo

  # === Part 2: rsyslog rule for *.info ===
  echo "  Part 2 — rsyslog rule (*.info → $LOG_FILE)"
  echo "  Step 6: Create rsyslog rule file (silent)."
  echo "          Expected: echo '*.info $LOG_FILE' > $RSYS_FILE"
  read -p "  lab@lab200:~$ " s6
  [[ "$s6" != "echo '*.info /var/log/messages.info' > /etc/rsyslog.d/10-info.conf" ]] && {
    print_error "Use exactly: echo '*.info /var/log/messages.info' > /etc/rsyslog.d/10-info.conf";
    read -p "Press Enter to try again..." _; continue; }
  echo

  echo "  Step 7: Show the rsyslog rule file."
  echo "          Expected: cat $RSYS_FILE"
  read -p "  lab@lab200:~$ " s7
  [[ "$s7" != "cat /etc/rsyslog.d/10-info.conf" ]] && { print_error "Use: cat /etc/rsyslog.d/10-info.conf"; read -p "Press Enter to try again..." _; continue; }
  echo "*.info /var/log/messages.info"
  echo

  echo "  Step 8: Restart rsyslog (no output expected)."
  echo "          Expected: systemctl restart rsyslog"
  read -p "  lab@lab200:~$ " s8
  [[ "$s8" != "systemctl restart rsyslog" ]] && { print_error "Use: systemctl restart rsyslog"; read -p "Press Enter to try again..." _; continue; }
  echo

  echo "  Step 9: Generate a test info message and view last line."
  echo "          Expected: logger -p user.info 'info test' && tail -n 1 $LOG_FILE"
  read -p "  lab@lab200:~$ " s9
  [[ "$s9" != "logger -p user.info 'info test' && tail -n 1 /var/log/messages.info" ]] && {
    print_error "Use: logger -p user.info 'info test' && tail -n 1 /var/log/messages.info";
    read -p "Press Enter to try again..." _; continue; }
  # Typical rsyslog format (simulate timestamp/host/program)
  echo "$(date +'%b %e %H:%M:%S') server1 user: info test"
  echo

  # === Part 3: logrotate retention ===
  echo "  Part 3 — logrotate: keep 10 old versions"
  echo "  Step 10: Create logrotate policy for $LOG_FILE (silent)."
  echo "           Expected: printf '...block...' > $ROTATE_FILE"
  read -p "  lab@lab200:~$ " s10
  [[ "$s10" != "cat > /etc/logrotate.d/messages-info" ]] && { print_error "Use: cat > /etc/logrotate.d/messages-info"; read -p "Press Enter to try again..." _; continue; }
  echo

  echo "  Step 11: Show the logrotate policy."
  echo "           Expected: cat $ROTATE_FILE"
  read -p "  lab@lab200:~$ " s11
  [[ "$s11" != "cat /etc/logrotate.d/messages-info" ]] && { print_error "Use: cat /etc/logrotate.d/messages-info"; read -p "Press Enter to try again..." _; continue; }
  echo "/var/log/messages.info {"
  echo "    weekly"
  echo "    rotate 10"
  echo "    missingok"
  echo "    notifempty"
  echo "    compress"
  echo "    delaycompress"
  echo "    create 0640 root root"
  echo "    sharedscripts"
  echo "    postrotate"
  echo "        /bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true"
  echo "    endscript"
  echo "}"
  echo

  echo "  Step 12: Force a rotation with verbose output."
  echo "           Expected: logrotate -v -f /etc/logrotate.d/messages-info"
  read -p "  lab@lab200:~$ " s12
  [[ "$s12" != "logrotate -v -f /etc/logrotate.d/messages-info" ]] && { print_error "Use: logrotate -v -f /etc/logrotate.d/messages-info"; read -p "Press Enter to try again..." _; continue; }
  echo "reading config file /etc/logrotate.d/messages-info"
  echo "Allocating hash table for state file, size 15360 B"
  echo "Handling 1 logs"
  echo "rotating pattern: /var/log/messages.info  forced from command line (10 rotations)"
  echo "empty log files are not rotated, old logs are removed"
  echo "considering log /var/log/messages.info"
  echo "  log needs rotating"
  echo "rotating log /var/log/messages.info, log->rotateCount is 10"
  echo "dateext suffix '-$(date +%Y%m%d)'"
  echo "compressing log with: /bin/gzip"
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
