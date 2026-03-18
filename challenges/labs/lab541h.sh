#!/bin/bash

# Lab 541H: Deploy a Basic Apache Web Server (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541H: Deploy a Basic Apache Web Server"
LAB_ID="lab541h"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "ServerA must provide a basic web page using Apache."
  center_text "Install httpd, configure the default page content, ensure"
  center_text "the service starts at boot, and permit HTTP through the firewall."
  echo

  center_text "Requirements:"
  center_text "- Package: httpd"
  center_text "- Page content: Welcome to RHEL 10"
  center_text "- Service enabled at boot"
  center_text "- HTTP allowed permanently in the firewall"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Check whether the httpd package is already installed."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "rpm -q httpd" ]]; then
    print_error "Incorrect. Use: rpm -q httpd"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  package httpd is not installed"
  echo


  echo "  Step 2: Install the Apache HTTP server."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo dnf install -y httpd" ]]; then
    print_error "Incorrect. Use: sudo dnf install -y httpd"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Installed:"
  echo "    httpd"
  echo


  echo "  Step 3: Verify the default web document root directory exists."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "ls /var/www/html" ]]; then
    print_error "Incorrect. Use: ls /var/www/html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 4: Configure the default web page to display Welcome to RHEL 10."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "echo 'Welcome to RHEL 10' | sudo tee /var/www/html/index.html > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'Welcome to RHEL 10' | sudo tee /var/www/html/index.html > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 5: Verify the contents of the default web page."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "cat /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: cat /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Welcome to RHEL 10"
  echo


  echo "  Step 6: Enable and start the Apache service."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo systemctl enable --now httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable --now httpd"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service."
  echo


  echo "  Step 7: Verify the Apache service is active."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "systemctl status httpd --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status httpd --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  ● httpd.service - The Apache HTTP Server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)"
  echo "     Active: active (running)"
  echo


  echo "  Step 8: Permanently allow HTTP through the firewall and reload the rules."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  success"
  echo "  success"
  echo


  echo "  Step 9: Verify that HTTP is allowed in the firewall."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "firewall-cmd --list-services" && "$cmd9" != "sudo firewall-cmd --list-services" ]]; then
    print_error "Incorrect. Use: firewall-cmd --list-services"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  cockpit dhcpv6-client http ssh"
  echo


  echo "  Step 10: Verify the web server responds locally."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "curl http://localhost" ]]; then
    print_error "Incorrect. Use: curl http://localhost"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Welcome to RHEL 10"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- checked for the httpd package"
  print_info "- installed Apache"
  print_info "- configured the default page content"
  print_info "- enabled and started the httpd service"
  print_info "- opened HTTP in the firewall permanently"
  print_info "- verified both firewall access and local web response"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo

  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo

  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done