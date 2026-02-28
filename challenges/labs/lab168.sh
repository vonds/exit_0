#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 168: Host-Based Access Control"
LAB_ID="lab168"
LAB_XP=28800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab168:~$ "

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
  center_text "A legacy, xinetd-managed service must be restricted to a management subnet."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm legacy xinetd service config exists
  echo "  Step 1: Confirm the legacy service definition exists under xinetd."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo ls -l /etc/xinetd.d/telnet" && "$cmd1" != "ls -l /etc/xinetd.d/telnet" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -rw-r--r--. 1 root root  390 Feb 27 10:12 /etc/xinetd.d/telnet"
  echo

  # STEP 2: Back up current access control files
  echo "  Step 2: Back up /etc/hosts.allow and /etc/hosts.deny."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo cp -a /etc/hosts.allow /etc/hosts.allow.bak && sudo cp -a /etc/hosts.deny /etc/hosts.deny.bak" && \
        "$cmd2" != "cp -a /etc/hosts.allow /etc/hosts.allow.bak && cp -a /etc/hosts.deny /etc/hosts.deny.bak" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Backups created:"
  echo "  /etc/hosts.allow.bak"
  echo "  /etc/hosts.deny.bak"
  echo

  # STEP 3: Default deny for TCP-wrappers
  echo "  Step 3: Set a default deny policy in /etc/hosts.deny."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "echo 'ALL: ALL' | sudo tee /etc/hosts.deny" && \
        "$cmd3" != "echo \"ALL: ALL\" | sudo tee /etc/hosts.deny" && \
        "$cmd3" != "sudo sh -c \"echo 'ALL: ALL' > /etc/hosts.deny\"" && \
        "$cmd3" != "sudo sh -c \"echo \\\"ALL: ALL\\\" > /etc/hosts.deny\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ALL: ALL"
  echo

  # STEP 4: Allow only the management subnet for the service
  echo "  Step 4: Allow the telnet service from the management subnet in /etc/hosts.allow."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "echo 'in.telnetd: 192.0.2.0/255.255.255.0' | sudo tee -a /etc/hosts.allow" && \
        "$cmd4" != "echo \"in.telnetd: 192.0.2.0/255.255.255.0\" | sudo tee -a /etc/hosts.allow" && \
        "$cmd4" != "sudo sh -c \"echo 'in.telnetd: 192.0.2.0/255.255.255.0' >> /etc/hosts.allow\"" && \
        "$cmd4" != "sudo sh -c \"echo \\\"in.telnetd: 192.0.2.0/255.255.255.0\\\" >> /etc/hosts.allow\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  in.telnetd: 192.0.2.0/255.255.255.0"
  echo

  # STEP 5: Validate TCP-wrappers syntax
  echo "  Step 5: Validate hosts.allow/hosts.deny with tcpdchk."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo tcpdchk" && "$cmd5" != "tcpdchk" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 6: Ensure xinetd is running with current config
  echo "  Step 6: Restart xinetd to ensure the service is managed and active."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl restart xinetd" && "$cmd6" != "systemctl restart xinetd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  xinetd restarted."
  echo

  # STEP 7: Test an allowed client decision (simulate wrapper decision)
  echo "  Step 7: Simulate an allowed client from the management subnet with tcpdmatch."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "tcpdmatch in.telnetd 192.0.2.55" && "$cmd7" != "sudo tcpdmatch in.telnetd 192.0.2.55" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  client:   address  192.0.2.55"
  echo "  server:   process  in.telnetd"
  echo "  access:   granted"
  echo

  # STEP 8: Restore original policy files
  echo "  Step 8: Restore the original hosts.allow/hosts.deny from your backups."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo mv -f /etc/hosts.allow.bak /etc/hosts.allow && sudo mv -f /etc/hosts.deny.bak /etc/hosts.deny" && \
        "$cmd8" != "mv -f /etc/hosts.allow.bak /etc/hosts.allow && mv -f /etc/hosts.deny.bak /etc/hosts.deny" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Restored:"
  echo "  /etc/hosts.allow"
  echo "  /etc/hosts.deny"
  echo

  print_success "Well done."
  print_info "You restricted a legacy service with TCP-wrappers rules, validate the policy, test access decisions, and restore safely."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done