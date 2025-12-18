#!/bin/bash

# Lab 202: Apache errors via syslog (local1) -> /var/log/httpd-error.log (Operate Running Systems)
# Output policy: Only show real command output. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 202: Apache → rsyslog (local1)"
LAB_ID="lab202"
LAB_XP=26000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

HTTPD_SYSLOG_CONF="/etc/httpd/conf.d/99-syslog.conf"
RSYS_CONF="/etc/rsyslog.d/30-httpd-local1.conf"
DEST_LOG="/var/log/httpd-error.log"

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
  center_text "Goal: Configure httpd to log errors to syslog facility local1, route local1.* to /var/log/httpd-error.log, verify with a 404."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Install httpd (shows dnf output)
  draw_lab_ui
  echo "  Step 1: Install Apache HTTP Server."
  echo "          Expected: dnf install -y httpd"
  read -p "  lab@lab202:~$ " s1
  [[ "$s1" != "dnf install -y httpd" ]] && { print_error "Use: dnf install -y httpd"; read -p "Press Enter to try again..." _; continue; }
  echo "Last metadata expiration check: 0:02:14 ago on $(date +'%a %b %d %Y %H:%M:%S')."
  echo "Dependencies resolved."
  echo "================================================================================"
  echo " Package  Arch   Version                   Repository                       Size"
  echo "================================================================================"
  echo "Installing:"
  echo " httpd    x86_64 2.4.57-18.el9            appstream                       1.7 M"
  echo
  echo "Installed:"
  echo "  httpd-2.4.57-18.el9.x86_64"
  echo

  # Step 2: Enable and start httpd (systemctl usually prints the symlink on first enable)
  echo "  Step 2: Enable and start httpd."
  echo "          Expected: systemctl enable --now httpd"
  read -p "  lab@lab202:~$ " s2
  [[ "$s2" != "systemctl enable --now httpd" ]] && { print_error "Use: systemctl enable --now httpd"; read -p "Press Enter to try again..." _; continue; }
  echo "Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service."
  echo

  # Step 3: Configure Apache to send ErrorLog to syslog local1 (silent)
  echo "  Step 3: Point Apache ErrorLog to syslog local1."
  echo "          Expected: echo 'ErrorLog syslog:local1' > $HTTPD_SYSLOG_CONF"
  read -p "  lab@lab202:~$ " s3
  [[ "$s3" != "echo 'ErrorLog syslog:local1' > /etc/httpd/conf.d/99-syslog.conf" ]] && {
    print_error "Use exactly: echo 'ErrorLog syslog:local1' > /etc/httpd/conf.d/99-syslog.conf";
    read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Show Apache conf snippet (prints the line)
  echo "  Step 4: Display the httpd syslog config."
  echo "          Expected: cat $HTTPD_SYSLOG_CONF"
  read -p "  lab@lab202:~$ " s4
  [[ "$s4" != "cat /etc/httpd/conf.d/99-syslog.conf" ]] && { print_error "Use: cat /etc/httpd/conf.d/99-syslog.conf"; read -p "Press Enter to try again..." _; continue; }
  echo "ErrorLog syslog:local1"
  echo

  # Step 5: Create rsyslog rule to route local1.* to the file (silent)
  echo "  Step 5: Route local1.* to $DEST_LOG."
  echo "          Expected: echo 'local1.*  $DEST_LOG' > $RSYS_CONF"
  read -p "  lab@lab202:~$ " s5
  [[ "$s5" != "echo 'local1.*  /var/log/httpd-error.log' > /etc/rsyslog.d/30-httpd-local1.conf" ]] && {
    print_error "Use exactly: echo 'local1.*  /var/log/httpd-error.log' > /etc/rsyslog.d/30-httpd-local1.conf";
    read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 6: Show rsyslog rule (prints the line)
  echo "  Step 6: Display the rsyslog rule."
  echo "          Expected: cat $RSYS_CONF"
  read -p "  lab@lab202:~$ " s6
  [[ "$s6" != "cat /etc/rsyslog.d/30-httpd-local1.conf" ]] && { print_error "Use: cat /etc/rsyslog.d/30-httpd-local1.conf"; read -p "Press Enter to try again..." _; continue; }
  echo "local1.*  /var/log/httpd-error.log"
  echo

  # Step 7: Restart rsyslog and httpd (silent)
  echo "  Step 7: Restart rsyslog then httpd."
  echo "          Expected: systemctl restart rsyslog && systemctl restart httpd"
  read -p "  lab@lab202:~$ " s7
  [[ "$s7" != "systemctl restart rsyslog && systemctl restart httpd" ]] && {
    print_error "Use: systemctl restart rsyslog && systemctl restart httpd";
    read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 8: Generate a 404 to create an error message
  echo "  Step 8: Request a non-existent page to trigger an error."
  echo "          Expected: curl -s -o /dev/null -w '%{http_code}\n' http://localhost/doesnotexist"
  read -p "  lab@lab202:~$ " s8
  [[ "$s8" != "curl -s -o /dev/null -w '%{http_code}\n' http://localhost/doesnotexist" ]] && {
    print_error "Use exactly: curl -s -o /dev/null -w '%{http_code}\\n' http://localhost/doesnotexist";
    read -p "Press Enter to try again..." _; continue; }
  echo "404"
  echo

  # Step 9: Verify last line in /var/log/httpd-error.log (prints a realistic syslog line)
  echo "  Step 9: Tail the custom error log."
  echo "          Expected: tail -n 1 $DEST_LOG"
  read -p "  lab@lab202:~$ " s9
  [[ "$s9" != "tail -n 1 /var/log/httpd-error.log" ]] && { print_error "Use: tail -n 1 /var/log/httpd-error.log"; read -p "Press Enter to try again..." _; continue; }
  echo "$(date +'%b %e %H:%M:%S') server1 httpd[12345]: [client 127.0.0.1:54321] AH00128: File does not exist: /var/www/html/doesnotexist"
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
