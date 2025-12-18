#!/bin/bash

# Lab 255: Remove sshd firewalld rule, test access denied — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real firewall/SSH changes occur.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 255: Firewalld SSH rule removal + test"
LAB_ID="lab255"
LAB_XP=21380
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated environment (NOT your real system)
ZONE="public"
IFACE="eth0"
SERVER_HOST="server1"
REMOTE_USER="student"

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
  center_text "Goal: Confirm firewalld is running, show SSH is allowed, remove the SSH service,"
  center_text "reload rules, verify SSH is blocked, then (optionally) restore the rule (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm firewalld is active
  draw_lab_ui
  echo "  Step 1: Check firewalld status."
  read -p "  lab@lab255:~$ " cmd1
  if [[ "$cmd1" == "systemctl is-active firewalld" || "$cmd1" == "firewall-cmd --state" ]]; then
    echo "  active"
  else
    print_error "Hint: Use 'systemctl is-active firewalld' or 'firewall-cmd --state'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Show active zone and interface
  echo "  Step 2: Show the active zone."
  read -p "  lab@lab255:~$ " cmd2
  if [[ "$cmd2" == "firewall-cmd --get-active-zones" ]]; then
    echo "  ${ZONE}"
    echo "    interfaces: ${IFACE}"
  else
    print_error "Hint: Use 'firewall-cmd --get-active-zones'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: List services in the zone (ssh should be present)
  echo "  Step 3: List allowed services for the active zone."
  read -p "  lab@lab255:~$ " cmd3
  if [[ "$cmd3" == "firewall-cmd --list-services" || "$cmd3" == "firewall-cmd --zone=${ZONE} --list-services" ]]; then
    echo "  ssh dhcpv6-client"
  else
    print_error "Hint: Try 'firewall-cmd --list-services' (or with --zone=${ZONE})."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Remove SSH service permanently
  echo "  Step 4: Remove SSH from the firewall (permanent)."
  read -p "  lab@lab255:~$ " cmd4
  if [[ "$cmd4" == "firewall-cmd --permanent --remove-service=ssh" || "$cmd4" == "firewall-cmd --permanent --zone=${ZONE} --remove-service=ssh" ]]; then
    echo "  success"
  else
    print_error "Hint: Use '--permanent --remove-service=ssh' (optionally with --zone=${ZONE})."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Reload firewall to apply
  echo "  Step 5: Reload the firewall rules."
  read -p "  lab@lab255:~$ " cmd5
  if [[ "$cmd5" == "firewall-cmd --reload" ]]; then
    echo "  success"
  else
    print_error "Hint: Apply changes with 'firewall-cmd --reload'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Confirm SSH service is gone
  echo "  Step 6: Verify SSH is no longer listed."
  read -p "  lab@lab255:~$ " cmd6
  if [[ "$cmd6" == "firewall-cmd --list-services" || "$cmd6" == "firewall-cmd --zone=${ZONE} --list-services" ]]; then
    echo "  dhcpv6-client"
  else
    print_error "Hint: List services again for the active zone."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Simulate remote SSH test failing
  echo "  Step 7: From a client, attempt to SSH to ${SERVER_HOST}."
  read -p "  client$ ssh> " cmd7
  if [[ "$cmd7" == "ssh ${REMOTE_USER}@${SERVER_HOST} -o ConnectTimeout=5" || \
        "$cmd7" == "ssh -o ConnectTimeout=5 ${REMOTE_USER}@${SERVER_HOST}" || \
        "$cmd7" == "ssh ${REMOTE_USER}@${SERVER_HOST}" ]]; then
    echo "  ssh: connect to host ${SERVER_HOST} port 22: Connection timed out"
  else
    print_error "Hint: Try an SSH command to ${REMOTE_USER}@${SERVER_HOST} (optionally with -o ConnectTimeout=5)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8 (optional): Restore SSH service
  echo "  Step 8 (optional): Re-allow SSH service and reload."
  read -p "  lab@lab255:~$ " cmd8a
  if [[ "$cmd8a" == "firewall-cmd --permanent --add-service=ssh" || "$cmd8a" == "firewall-cmd --permanent --zone=${ZONE} --add-service=ssh" || "$cmd8a" == "" ]]; then
    if [[ -n "$cmd8a" ]]; then
      echo "  success"
      read -p "  lab@lab255:~$ " cmd8b
      if [[ "$cmd8b" == "firewall-cmd --reload" ]]; then
        echo "  success"
      else
        print_error "Hint: Apply with 'firewall-cmd --reload' (or press Enter in Step 8 to skip restore)."
        read -p "Press Enter to try again..." _
        continue
      fi
    fi
  else
    print_error "Hint: Use '--permanent --add-service=ssh' (or press Enter to skip restoration)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You verified SSH allowance, removed the SSH rule, confirmed access was denied, and (optionally) restored it — all simulated."
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
