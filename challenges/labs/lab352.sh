#!/bin/bash

# Lab 352: RHEL Troubleshooting — Apache is up, but clients get "403 Forbidden" due to SELinux context
# RHEL focus: httpd service verification, error log review, SELinux enforcement checks,
# file context inspection (ls -Z), restoring correct contexts (restorecon), and SELinux boolean (setsebool).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 352"
LAB_ID="lab352"
LAB_XP=35200
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

PROMPT="student@lab352:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — httpd is running, but browsing the site returns: 403 Forbidden."
  center_text "Interactive: confirm service health, read logs, identify SELinux denial, and fix contexts/booleans."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm the web server service is running."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl status httpd" && "$cmd1" != "sudo systemctl status httpd" ]]; then
    print_error "Incorrect. Use: systemctl status httpd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "● httpd.service - The Apache HTTP Server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)"
  echo "     Active: active (running) since Fri 2025-12-19 15:41:18 EST; 28s ago"
  echo "       Docs: man:httpd.service(8)"
  echo "   Main PID: 3097 (httpd)"
  echo "     Status: \"Running\""
  echo "      Tasks: 82 (limit: 11423)"
  echo "     Memory: 19.6M"
  echo "        CPU: 248ms"
  echo "     CGroup: /system.slice/httpd.service"
  echo "             ├─3097 /usr/sbin/httpd -DFOREGROUND"
  echo "             ├─3099 /usr/sbin/httpd -DFOREGROUND"
  echo "             ├─3100 /usr/sbin/httpd -DFOREGROUND"
  echo "             └─3101 /usr/sbin/httpd -DFOREGROUND"

  # STEP 2
  echo
  echo "  Step 2: Simulate checking the local HTTP response code."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "curl -I http://localhost" && "$cmd2" != "curl -I http://127.0.0.1" && "$cmd2" != "curl -I http://localhost/" && "$cmd2" != "curl -I http://127.0.0.1/" ]]; then
    print_error "Incorrect. Use: curl -I http://localhost"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "HTTP/1.1 403 Forbidden"
  echo "Date: Fri, 19 Dec 2025 20:41:53 GMT"
  echo "Server: Apache/2.4.57 (Red Hat Enterprise Linux)"
  echo "Content-Type: text/html; charset=iso-8859-1"

  # STEP 3
  echo
  echo "  Step 3: Check the Apache error log for clues."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "sudo tail -n 20 /var/log/httpd/error_log" && "$cmd3" != "tail -n 20 /var/log/httpd/error_log" ]]; then
    print_error "Incorrect. Use: sudo tail -n 20 /var/log/httpd/error_log"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "[Fri Dec 19 15:41:18.604312 2025] [suexec:notice] [pid 3097] AH01232: suEXEC mechanism enabled (wrapper: /usr/sbin/suexec)"
  echo "[Fri Dec 19 15:41:18.604901 2025] [mpm_event:notice] [pid 3097] AH00489: Apache/2.4.57 (Red Hat Enterprise Linux) configured -- resuming normal operations"
  echo "[Fri Dec 19 15:41:18.604919 2025] [core:notice] [pid 3097] AH00094: Command line: '/usr/sbin/httpd -DFOREGROUND'"
  echo "[Fri Dec 19 15:41:53.812008 2025] [authz_core:error] [pid 3099] [client 127.0.0.1:58622] AH01630: client denied by server configuration: /var/www/html/index.html"
  echo "[Fri Dec 19 15:41:53.812542 2025] [core:error] [pid 3099] (13)Permission denied: [client 127.0.0.1:58622] AH00035: access to / denied (filesystem path '/var/www/html') because search permissions are missing on a component of the path"

  # STEP 4
  echo
  echo "  Step 4: Verify SELinux mode."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "getenforce" && "$cmd4" != "sudo getenforce" ]]; then
    print_error "Incorrect. Use: getenforce"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "Enforcing"

  # STEP 5
  echo
  echo "  Step 5: Check SELinux context labels on the web root and the index file."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "ls -ldZ /var/www/html /var/www/html/index.html" && "$cmd5" != "sudo ls -ldZ /var/www/html /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -ldZ /var/www/html /var/www/html/index.html"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "drwxr-xr-x. 2 root root unconfined_u:object_r:default_t:s0      23 Dec 19 15:39 /var/www/html"
  echo "-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0     42 Dec 19 15:39 /var/www/html/index.html"

  # STEP 6
  echo
  echo "  Step 6: Restore the default SELinux contexts for the web root."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo restorecon -Rv /var/www/html" && "$cmd6" != "restorecon -Rv /var/www/html" ]]; then
    print_error "Incorrect. Use: sudo restorecon -Rv /var/www/html"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "Relabeled /var/www/html from unconfined_u:object_r:default_t:s0 to system_u:object_r:httpd_sys_content_t:s0"
  echo "Relabeled /var/www/html/index.html from unconfined_u:object_r:default_t:s0 to system_u:object_r:httpd_sys_content_t:s0"

  # STEP 7
  echo
  echo "  Step 7: Re-check SELinux labels to confirm the fix."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "ls -ldZ /var/www/html /var/www/html/index.html" && "$cmd7" != "sudo ls -ldZ /var/www/html /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -ldZ /var/www/html /var/www/html/index.html"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_content_t:s0      23 Dec 19 15:39 /var/www/html"
  echo "-rw-r--r--. 1 root root system_u:object_r:httpd_sys_content_t:s0     42 Dec 19 15:39 /var/www/html/index.html"

  # STEP 8
  echo
  echo "  Step 8: The app team also wants httpd to read user home directories from ~/public_html."
  echo "          Enable the SELinux boolean to allow that."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo setsebool -P httpd_enable_homedirs on" && "$cmd8" != "setsebool -P httpd_enable_homedirs on" ]]; then
    print_error "Incorrect. Use: sudo setsebool -P httpd_enable_homedirs on"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo ""

  # STEP 9
  echo
  echo "  Step 9: Confirm the boolean is enabled."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "getsebool httpd_enable_homedirs" && "$cmd9" != "sudo getsebool httpd_enable_homedirs" ]]; then
    print_error "Incorrect. Use: getsebool httpd_enable_homedirs"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "httpd_enable_homedirs --> on"

  # STEP 10
  echo
  echo "  Step 10: Verify the site now returns HTTP 200."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "curl -I http://localhost" && "$cmd10" != "curl -I http://127.0.0.1" && "$cmd10" != "curl -I http://localhost/" && "$cmd10" != "curl -I http://127.0.0.1/" ]]; then
    print_error "Incorrect. Use: curl -I http://localhost"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "HTTP/1.1 200 OK"
  echo "Date: Fri, 19 Dec 2025 20:42:37 GMT"
  echo "Server: Apache/2.4.57 (Red Hat Enterprise Linux)"
  echo "Last-Modified: Fri, 19 Dec 2025 20:39:12 GMT"
  echo "ETag: \"2a-5c1f3b9c5f000\""
  echo "Accept-Ranges: bytes"
  echo "Content-Length: 42"
  echo "Content-Type: text/html; charset=UTF-8"

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
