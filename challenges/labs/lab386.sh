#!/bin/bash

# Lab 386: SELinux File Contexts — Restore Default Contexts from a Nonstandard Path (4–8 prompts)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 386: SELinux File Contexts — Restore Defaults from Nonstandard Path"
LAB_ID="lab386"
LAB_XP=38600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab386:~$ "

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
  center_text "A sysadmin moved a web root to a nonstandard path: /srv/www/site"
  center_text "Now the site returns errors, and SELinux is suspected."
  center_text "You must apply the DEFAULT httpd content labeling to the new path"
  center_text "and restore contexts so the files match policy."
  echo
  center_text "Nonstandard path: /srv/www/site"
  center_text "Verification target: http://localhost"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm SELinux is enforcing
  echo "  Step 1: Confirm SELinux mode."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "getenforce" && \
        "$cmd1" != "sestatus" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd1" == "getenforce" ]]; then
    echo "  Enforcing"
  else
    echo "  SELinux status:                 enabled"
    echo "  Current mode:                   enforcing"
    echo "  Mode from config file:          enforcing"
  fi
  echo

  # STEP 2: Inspect current contexts on the nonstandard path
  echo "  Step 2: Check the current SELinux labels on the new document root."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ls -Zd /srv/www/site" && \
        "$cmd2" != "ls -Z /srv/www/site" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd2" == "ls -Zd /srv/www/site" ]]; then
    echo "  unconfined_u:object_r:default_t:s0 /srv/www/site"
  else
    echo "  unconfined_u:object_r:default_t:s0 /srv/www/site/index.html"
  fi
  echo

  # STEP 3: Add a persistent file context rule for the nonstandard path
  echo "  Step 3: Add a persistent SELinux file context rule for /srv/www/site."
  echo "          (Label it like normal web content.)"
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo semanage fcontext -a -t httpd_sys_content_t \"/srv/www/site(/.*)?\"" && \
        "$cmd3" != "semanage fcontext -a -t httpd_sys_content_t \"/srv/www/site(/.*)?\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (fcontext rule added)"
  echo

  # STEP 4: Restore default contexts based on policy + your new rule
  echo "  Step 4: Restore SELinux contexts on /srv/www/site using restorecon."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo restorecon -Rv /srv/www/site" && \
        "$cmd4" != "restorecon -Rv /srv/www/site" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /srv/www/site context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0"
  echo "  restorecon reset /srv/www/site/index.html context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0"
  echo

  # STEP 5: Confirm contexts now match expected httpd content type
  echo "  Step 5: Verify the new context label is applied."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls -Z /srv/www/site/index.html" && \
        "$cmd5" != "ls -Zd /srv/www/site" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd5" == "ls -Z /srv/www/site/index.html" ]]; then
    echo "  system_u:object_r:httpd_sys_content_t:s0 /srv/www/site/index.html"
  else
    echo "  system_u:object_r:httpd_sys_content_t:s0 /srv/www/site"
  fi
  echo

  # STEP 6: Verify site responds
  echo "  Step 6: Verify the site is reachable."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "curl -I http://localhost" && \
        "$cmd6" != "curl -I http://localhost/" && \
        "$cmd6" != "curl -sS http://localhost | head" && \
        "$cmd6" != "curl -sS http://localhost/ | head" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd6" == "curl -I"* ]]; then
    echo "  HTTP/1.1 200 OK"
    echo "  Content-Type: text/html; charset=UTF-8"
    echo "  Server: httpd"
  else
    echo "  <html>"
    echo "  <head><title>Site</title></head>"
    echo "  <body>OK</body>"
    echo "  </html>"
  fi
  echo

  print_success "Nice work."
  print_info "You restored default SELinux contexts for a nonstandard path by:"
  print_info "- verifying incorrect labeling (default_t)"
  print_info "- creating a persistent fcontext mapping with semanage"
  print_info "- applying labels with restorecon"
  print_info "- validating httpd_sys_content_t is in place"
  print_info "- confirming the service works"
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
