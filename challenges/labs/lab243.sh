#!/bin/bash

# Lab 243: Firewalld — remove rules and switch zones back to public — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real firewall changes occur.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 243: Firewalld cleanup + zone reset (public)"
LAB_ID="lab243"
LAB_XP=20675
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated initial state
IFACE="eth0"
OLDZONE="work"
NEWZONE="public"

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
  center_text "Goal: Remove HTTP/HTTPS/VNC services from runtime & permanent config, move ${IFACE} back to '${NEWZONE}',"
  center_text "set default zone to '${NEWZONE}', reload, and verify (SIMULATED). Current active zone: '${OLDZONE}'."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Show current default zone (simulated OLDZONE)
  draw_lab_ui
  echo "  Step 1: Display the current default zone."
  read -p "  lab@lab243:~$ " cmd1
  if [[ "$cmd1" == "firewall-cmd --get-default-zone" ]]; then
    echo "  ${OLDZONE}"
  else
    print_error "Hint: Ask firewalld for the default zone."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Show active zones and interfaces
  echo "  Step 2: List active zones and their interfaces."
  read -p "  lab@lab243:~$ " cmd2
  if [[ "$cmd2" == "firewall-cmd --get-active-zones" ]]; then
    echo "  ${OLDZONE}"
    echo "    interfaces: ${IFACE}"
  else
    print_error "Hint: Use the subcommand that prints active zones."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Show runtime services in the active zone (assume were added previously)
  echo "  Step 3: List currently allowed services (runtime) in the active zone."
  read -p "  lab@lab243:~$ " cmd3
  if [[ "$cmd3" == "firewall-cmd --list-services" ]]; then
    echo "  dhcpv6-client http https ssh vnc-server"
  else
    print_error "Hint: List the services allowed in the active zone."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Remove runtime services: http, https, vnc-server
  echo "  Step 4: Remove HTTP (runtime)."
  read -p "  lab@lab243:~$ " cmd4a
  [[ "$cmd4a" != "firewall-cmd --remove-service=http" ]] && {
    print_error "Hint: Remove the HTTP service from the runtime config."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo
  echo "  Step 4 (cont.): Remove HTTPS (runtime)."
  read -p "  lab@lab243:~$ " cmd4b
  [[ "$cmd4b" != "firewall-cmd --remove-service=https" ]] && {
    print_error "Hint: Remove the HTTPS service from the runtime config."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo
  echo "  Step 4 (cont.): Remove VNC (runtime)."
  read -p "  lab@lab243:~$ " cmd4c
  [[ "$cmd4c" != "firewall-cmd --remove-service=vnc-server" ]] && {
    print_error "Hint: Remove VNC from the runtime config."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo

  # Step 5: Verify runtime services after removals
  echo "  Step 5: Re-list runtime services."
  read -p "  lab@lab243:~$ " cmd5
  if [[ "$cmd5" == "firewall-cmd --list-services" ]]; then
    echo "  dhcpv6-client ssh"
  else
    print_error "Hint: List services again to confirm removal."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Remove the same services from the PERMANENT config
  echo "  Step 6: Remove services from the permanent configuration."
  read -p "  lab@lab243:~$ " cmd6a
  [[ "$cmd6a" != "firewall-cmd --permanent --remove-service=http" ]] && {
    print_error "Hint: Use --permanent to remove HTTP permanently."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  read -p "  lab@lab243:~$ " cmd6b
  [[ "$cmd6b" != "firewall-cmd --permanent --remove-service=https" ]] && {
    print_error "Hint: Use --permanent to remove HTTPS permanently."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  read -p "  lab@lab243:~$ " cmd6c
  [[ "$cmd6c" != "firewall-cmd --permanent --remove-service=vnc-server" ]] && {
    print_error "Hint: Use --permanent to remove VNC permanently."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo

  # Step 7: Move interface back to public (runtime) and set default zone to public
  echo "  Step 7: Attach ${IFACE} to '${NEWZONE}' (runtime)."
  read -p "  lab@lab243:~$ " cmd7a
  if [[ "$cmd7a" == "firewall-cmd --zone=${NEWZONE} --change-interface=${IFACE}" || "$cmd7a" == "firewall-cmd --zone=${NEWZONE} --add-interface=${IFACE}" ]]; then
    echo "  success"
  else
    print_error "Hint: Change/add the interface to the ${NEWZONE} zone (runtime)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 7 (cont.): Set the default zone to '${NEWZONE}'."
  read -p "  lab@lab243:~$ " cmd7b
  if [[ "$cmd7b" == "firewall-cmd --set-default-zone=${NEWZONE}" ]]; then
    echo "  success"
  else
    print_error "Hint: Set the default zone appropriately."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Persist the interface-to-zone mapping (permanent) and reload
  echo "  Step 8: Make the ${IFACE} → ${NEWZONE} mapping permanent and reload."
  read -p "  lab@lab243:~$ " cmd8a
  if [[ "$cmd8a" == "firewall-cmd --permanent --zone=${NEWZONE} --add-interface=${IFACE}" ]]; then
    echo "  success"
  else
    print_error "Hint: Add the interface to the ${NEWZONE} zone with --permanent."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab243:~$ " cmd8b
  if [[ "$cmd8b" == "firewall-cmd --reload" ]]; then
    echo "  success"
  else
    print_error "Hint: Reload firewalld to apply permanent configuration."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Verify permanent + runtime alignment, active zones, and services
  echo "  Step 9: Verify permanent services (should not include http/https/vnc-server)."
  read -p "  lab@lab243:~$ " cmd9a
  if [[ "$cmd9a" == "firewall-cmd --permanent --list-services" ]]; then
    echo "  dhcpv6-client ssh"
  else
    print_error "Hint: List permanent services."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 9 (cont.): Verify runtime services."
  read -p "  lab@lab243:~$ " cmd9b
  if [[ "$cmd9b" == "firewall-cmd --list-services" ]]; then
    echo "  dhcpv6-client ssh"
  else
    print_error "Hint: List runtime services."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 9 (cont.): Confirm active zone and interface."
  read -p "  lab@lab243:~$ " cmd9c
  if [[ "$cmd9c" == "firewall-cmd --get-active-zones" ]]; then
    echo "  ${NEWZONE}"
    echo "    interfaces: ${IFACE}"
  else
    print_error "Hint: Re-check active zones."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 9 (cont.): Confirm default zone."
  read -p "  lab@lab243:~$ " cmd9d
  if [[ "$cmd9d" == "firewall-cmd --get-default-zone" ]]; then
    echo "  ${NEWZONE}"
  else
    print_error "Hint: Re-check the default zone."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! You removed runtime & permanent rules, moved ${IFACE} back to '${NEWZONE}', set the default zone, reloaded, and verified (simulated)."
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
