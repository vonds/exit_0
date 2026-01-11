#!/bin/bash

# Lab 128: Networking Troubleshooting — Fix "Service Port Closed" (Firewall Blocking SSH)
# Focus: diagnose and fix a real outage where the host is reachable by IP, but a service port is blocked.
# Key skills: ss, firewall-cmd, and verification workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 128: Fix Blocked Service Port (Firewall)"
LAB_ID="lab128"
LAB_XP=12800
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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "A teammate says, 'The box is up, but nobody can SSH into it anymore.'"
  center_text "You have console access and need to restore inbound SSH quickly."
  echo
  center_text "Notes:"
  center_text "- Assume the SSH service should be running and listening on port 22"
  center_text "- The problem is not the network cable or interface state"
  center_text "- Use sudo where required."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm sshd is listening on port 22."
  read -r -p "  lab@net-ops-128:~$ " cmd1
  echo
  if [[ "$cmd1" != "ss -lntp | grep ':22'" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:((\"sshd\",pid=1024,fd=3))"
  echo "  LISTEN 0      128             [::]:22           [::]:*    users:((\"sshd\",pid=1024,fd=4))"
  echo

  # STEP 2
  echo "  Step 2: Check whether firewalld is running."
  read -r -p "  lab@net-ops-128:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo firewall-cmd --state" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  running"
  echo

  # STEP 3
  echo "  Step 3: List allowed services in the active firewall zone."
  read -r -p "  lab@net-ops-128:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo firewall-cmd --list-services" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  dhcpv6-client"
  echo

  # STEP 4
  echo "  Step 4: Add the ssh service to the firewall permanently."
  read -r -p "  lab@net-ops-128:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo firewall-cmd --permanent --add-service=ssh" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 5
  echo "  Step 5: Reload the firewall to apply changes."
  read -r -p "  lab@net-ops-128:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 6
  echo "  Step 6: Confirm ssh is now allowed."
  read -r -p "  lab@net-ops-128:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo firewall-cmd --list-services" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  dhcpv6-client ssh"
  echo

  print_success "Nice work."
  print_info "You confirmed sshd was listening, then fixed the outage by allowing SSH through the firewall."
  print_info "You earned $LAB_XP XP for completing this lab."
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
  read -r -p "  > " post_choice

  [[ "$post_choice" == "2" ]] && exit 0
done
