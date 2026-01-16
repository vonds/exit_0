#!/bin/bash

# Lab 474: Rocky Linux 10 — SSH & Squid Configuration Hardening (RHCSA Focus)
# Focus: securing SSH daemon behavior and managing Squid proxy access controls.
# Key skills: editing sshd_config, restarting sshd, editing squid.conf,
# ACL ordering, allow/deny logic, and precise vi-based configuration.


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 474: SSH & Squid Configuration Hardening (Rocky 10)"
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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "You are hardening remote access and proxy behavior on a Rocky Linux 10 server."
  center_text "You must update SSH daemon security settings and enforce Squid ACL rules."
  echo
  center_text "Requirements (type commands and file entries EXACTLY):"
  center_text "- Modify SSH authentication and connection limits"
  center_text "- Restrict SSH root login behavior"
  center_text "- Restart sshd to apply changes"
  center_text "- Adjust Squid http_access rules"
  center_text "- Create and apply ACLs with correct ordering"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # ---------- SSH SECTION ----------

  # STEP 1: edit sshd_config
  echo "  Step 1: Open /etc/ssh/sshd_config using vim."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo vim /etc/ssh/sshd_config" && "$cmd1" != "sudo vi /etc/ssh/sshd_config" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  # STEP 2: PasswordAuthentication yes
  echo "  Step 2: Ensure the following line exists EXACTLY:"
  read -p "  > " ssh1
  if [[ "$ssh1" != "PasswordAuthentication yes" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 3: ForwardX11 yes
  echo "  Step 3: Ensure the following line exists EXACTLY:"
  read -p "  > " ssh2
  if [[ "$ssh2" != "ForwardX11 yes" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 4: AddressFamily inet
  echo "  Step 4: Ensure the following line exists EXACTLY:"
  read -p "  > " ssh3
  if [[ "$ssh3" != "AddressFamily inet" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 5: PermitRootLogin no
  echo "  Step 5: Ensure the following line exists EXACTLY:"
  read -p "  > " ssh4
  if [[ "$ssh4" != "PermitRootLogin no" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 6: MaxAuthTries 4
  echo "  Step 6: Ensure the following line exists EXACTLY:"
  read -p "  > " ssh5
  if [[ "$ssh5" != "MaxAuthTries 4" ]]; then
    print_error "Incorrect SSH configuration line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  # STEP 7: restart sshd
  echo "  Step 7: Restart the sshd service."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl restart sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ---------- SQUID SECTION ----------

  # STEP 8: edit squid.conf
  echo "  Step 8: Open /etc/squid/squid.conf using vim."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo vim /etc/squid/squid.conf" && "$cmd8" != "sudo vi /etc/squid/squid.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  # STEP 9: change localnet rule
  echo "  Step 9: Change the localnet rule to EXACTLY:"
  read -p "  > " squid1
  if [[ "$squid1" != "http_access deny localnet" ]]; then
    print_error "Incorrect Squid rule."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 10: add vpn ACL
  echo "  Step 10: Add the following ACL line EXACTLY:"
  read -p "  > " squid2
  if [[ "$squid2" != "acl vpn src 203.0.110.5" ]]; then
    print_error "Incorrect ACL line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 11: allow external
  echo "  Step 11: Add the following line AFTER 'http_access allow localhost':"
  read -p "  > " squid3
  if [[ "$squid3" != "http_access allow external" ]]; then
    print_error "Incorrect Squid rule."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 12: allow vpn
  echo "  Step 12: Add the following line BEFORE 'http_access deny all':"
  read -p "  > " squid4
  if [[ "$squid4" != "http_access allow vpn" ]]; then
    print_error "Incorrect Squid rule."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 13: facebook ACL
  echo "  Step 13: Add the following ACL line EXACTLY:"
  read -p "  > " squid5
  if [[ "$squid5" != "acl facebook dstdomain .facebook.com" ]]; then
    print_error "Incorrect ACL line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 14: deny facebook
  echo "  Step 14: Add the following line AFTER 'http_access allow localhost':"
  read -p "  > " squid6
  if [[ "$squid6" != "http_access deny facebook" ]]; then
    print_error "Incorrect Squid rule."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  print_success "Excellent work."
  print_info "You completed RHCSA-relevant service hardening on Rocky Linux 10:"
  print_info "- secured SSH authentication and access limits"
  print_info "- enforced IPv4-only SSH connections"
  print_info "- configured Squid ACLs with correct ordering"
  print_info "- practiced precise vi-based configuration"
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
