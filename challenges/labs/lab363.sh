#!/bin/bash

# Lab 363: RHEL Troubleshooting — hostname reverted after reboot (NetworkManager sets transient hostname)
# RHCSA focus: checking current hostname state (hostnamectl), identifying static vs transient hostname,
# inspecting NetworkManager configuration and connection profiles, fixing hostname persistence,
# restarting services, and verifying hostname remains correct after reboot.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 363"
LAB_ID="lab363"
LAB_XP=36300
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

PROMPT="student@lab363:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — you set the hostname, but after reboot it reverts to 'localhost.localdomain'."
  center_text "Interactive: find what is overriding the hostname and make it persistent."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Check hostname status (note static vs transient)."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "hostnamectl status" && "$cmd1" != "sudo hostnamectl status" ]]; then
    print_error "Incorrect. Use: hostnamectl status"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Static hostname: web01"
  echo "Transient hostname: localhost.localdomain"
  echo "         Icon name: computer-vm"
  echo "           Chassis: vm"
  echo "        Machine ID: 7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a"
  echo "           Boot ID: 2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b"
  echo "  Operating System: Red Hat Enterprise Linux 9.4 (Plow)"
  echo "            Kernel: Linux 5.14.0-427.13.1.el9_4.x86_64"
  echo "      Architecture: x86-64"

  # STEP 2
  echo
  echo "  Step 2: Confirm what the current runtime hostname command returns."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "hostname" && "$cmd2" != "hostname -f" ]]; then
    print_error "Incorrect. Use: hostname  (or: hostname -f)"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd2" == "hostname" ]]; then
    echo "  localhost.localdomain"
  else
    echo "  localhost.localdomain"
  fi

  # STEP 3
  echo
  echo "  Step 3: Inspect NetworkManager hostname settings."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "sudo grep -n '^hostname=' /etc/NetworkManager/NetworkManager.conf" ]]; then
    print_error "Incorrect. Use: sudo grep -n '^hostname=' /etc/NetworkManager/NetworkManager.conf"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  6:hostname=localhost.localdomain"

  # STEP 4
  echo
  echo "  Step 4: Confirm NetworkManager is applying a hostname at runtime (nmcli general)."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "nmcli general hostname" && "$cmd4" != "sudo nmcli general hostname" ]]; then
    print_error "Incorrect. Use: nmcli general hostname"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  localhost.localdomain"

  # STEP 5
  echo
  echo "  Step 5: Set the persistent static hostname correctly."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo hostnamectl set-hostname web01" ]]; then
    print_error "Incorrect. Use: sudo hostnamectl set-hostname web01"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 6
  echo
  echo "  Step 6: Remove the NetworkManager override that forces the transient hostname."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo sed -i 's/^hostname=localhost.localdomain/#hostname=localhost.localdomain/' /etc/NetworkManager/NetworkManager.conf" ]]; then
    print_error "Incorrect. Use: sudo sed -i 's/^hostname=localhost.localdomain/#hostname=localhost.localdomain/' /etc/NetworkManager/NetworkManager.conf"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 7
  echo
  echo "  Step 7: Restart NetworkManager so the override is no longer applied."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo systemctl restart NetworkManager" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart NetworkManager"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 8
  echo
  echo "  Step 8: Verify the hostname is now correct (static and transient match)."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "hostnamectl status" && "$cmd8" != "hostname" ]]; then
    print_error "Incorrect. Use: hostnamectl status  (or: hostname)"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd8" == "hostname" ]]; then
    echo "  web01"
  else
    echo "  Static hostname: web01"
    echo "Transient hostname: web01"
    echo "         Icon name: computer-vm"
    echo "           Chassis: vm"
    echo "        Machine ID: 7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a"
    echo "           Boot ID: 2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b"
    echo "  Operating System: Red Hat Enterprise Linux 9.4 (Plow)"
    echo "            Kernel: Linux 5.14.0-427.13.1.el9_4.x86_64"
    echo "      Architecture: x86-64"
  fi

  # STEP 9
  echo
  echo "  Step 9: Verify the config no longer contains the hostname override."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "sudo grep -n '^hostname=' /etc/NetworkManager/NetworkManager.conf" ]]; then
    print_error "Incorrect. Use: sudo grep -n '^hostname=' /etc/NetworkManager/NetworkManager.conf"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 10
  echo
  echo "  Step 10: Simulate verification after reboot by checking the runtime hostname source."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "nmcli general hostname" ]]; then
    print_error "Incorrect. Use: nmcli general hostname"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  web01"

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
