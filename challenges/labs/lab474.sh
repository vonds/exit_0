#!/bin/bash

# Lab 474: Rocky Linux 10 — SSH Port Migration + firewalld + SELinux (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 474: SSH + firewalld + SELinux (Rocky 10 / RHCSA)"
LAB_ID="lab474"
LAB_XP=47400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab474:~$ "

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

require_exact_cmd() {
  local user_input="$1"
  shift
  local ok=0
  local expected
  for expected in "$@"; do
    if [[ "$user_input" == "$expected" ]]; then
      ok=1
      break
    fi
  done
  [[ "$ok" -eq 1 ]]
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "You are administering a Rocky Linux 10 server and must secure SSH access."
  center_text "You will migrate SSH to port 2222, open it in firewalld, and permit it in SELinux."
  echo
  center_text "Requirements (type commands and file entries EXACTLY):"
  center_text "- Update sshd_config (Port, PermitRootLogin, AllowUsers)"
  center_text "- Validate sshd config syntax"
  center_text "- Restart and verify sshd"
  center_text "- Open port 2222/tcp in firewalld permanently"
  center_text "- Allow SSH to bind to 2222 with SELinux semanage"
  center_text "- Verify effective config + firewall + SELinux + listener"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Open /etc/ssh/sshd_config using vim."
  read -p "$PROMPT" cmd1
  echo
  if ! require_exact_cmd "$cmd1" "sudo vim /etc/ssh/sshd_config" "sudo vi /etc/ssh/sshd_config"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 2: Configure SSH to listen on TCP port 2222 instead of the default port."
  read -p "  > " ssh1
  if [[ "$ssh1" != "Port 2222" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Prevent the root user from logging in over SSH."
  read -p "  > " ssh2
  if [[ "$ssh2" != "PermitRootLogin no" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 4: Allow SSH access only for the user named 'student'."
  read -p "  > " ssh3
  if [[ "$ssh3" != "AllowUsers student" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Step 5: Validate the SSH daemon configuration syntax."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo sshd -t" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (no output)"
  echo

  echo "  Step 6: Restart the sshd service."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl restart sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (sshd restarted)"
  echo

  echo "  Step 7: Verify sshd is active."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl status sshd --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "● sshd.service - OpenSSH server daemon"
  echo "   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)"
  echo "   Active: active (running)"
  echo

  echo "  Step 8: Verify effective SSH settings (port/root/allowusers)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo sshd -T | grep -E 'port|permitrootlogin|allowusers'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "port 2222"
  echo "permitrootlogin no"
  echo "allowusers student"
  echo

  echo "  Step 9: Open TCP port 2222 permanently using firewalld."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo firewall-cmd --add-port=2222/tcp --permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "success"
  echo

  echo "  Step 10: Reload firewalld."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "success"
  echo

  echo "  Step 11: Verify the firewall port list includes 2222/tcp."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo firewall-cmd --list-ports" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "2222/tcp"
  echo

  echo "  Step 12: Add SELinux port label for SSH on 2222/tcp."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo semanage port -a -t ssh_port_t -p tcp 2222" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (policy updated)"
  echo

  echo "  Step 13: Verify SELinux port labeling includes 2222."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo semanage port -l | grep ssh_port_t" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "ssh_port_t                    tcp      2222"
  echo

  echo "  Step 14: Verify sshd is listening on 2222."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo ss -tlnp | grep 2222" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "LISTEN 0 128 0.0.0.0:2222 0.0.0.0:* users:((\"sshd\",pid=1234,fd=3))"
  echo

  print_success "Excellent work."
  print_info "You completed a high-value RHCSA service + security workflow on Rocky Linux 10:"
  print_info "- sshd_config change + syntax validation"
  print_info "- systemd restart + service status verification"
  print_info "- firewalld permanent rule + reload + verification"
  print_info "- SELinux ssh_port_t labeling via semanage"
  print_info "- listener verification with ss"
  print_info "You earned $LAB_XP XP."
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

  [[ "$choice" == "2" ]] && exit 0
done
