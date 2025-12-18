#!/bin/bash

# Lab 315: Configuring a System Hostname – Objectives 109.2 & 109.3
# LPIC-1 Focus: view, choose, and set hostnames; hostnamectl vs legacy files; env var behavior.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 315: Configuring a System Hostname"
LAB_ID="lab315"
LAB_XP=41200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated initial/target hostnames for this lab
INITIAL_HOST="lab-station"
TARGET_HOST="LL01.class.org"

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
  center_text "Practice hostname inspection and configuration on a systemd-based distro."
  center_text "Follow prompts exactly. Use echo-style, single-line outputs are simulated."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  # Step 1: hostnamectl (or hostnamectl status)
  echo "  Step 1: View the hostname using the systemd tool."
  read -p "  lab@lab315:~$ " cmd1
  echo
  if [[ "$cmd1" == "hostnamectl" || "$cmd1" == "hostnamectl status" ]]; then
    echo "   Static hostname: $INITIAL_HOST"
    echo "         Icon name: computer-vm"
    echo "           Chassis: vm"
    echo "        Machine ID: 11111111111111111111111111111111"
    echo "           Boot ID: 22222222222222222222222222222222"
    echo "  Operating System: Rocky Linux 10 (Red Quartz)"
    echo "            Kernel: Linux 6.12.0"
    echo "      Architecture: x86-64"
    echo
  else
    print_error "Incorrect. Use 'hostnamectl' or 'hostnamectl status'."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 2: $HOSTNAME environment variable
  echo "  Step 2: Show the hostname via the environment variable."
  read -p "  lab@lab315:~$ " cmd2
  echo
  if [[ "$cmd2" == 'echo $HOSTNAME' ]]; then
    echo "  $INITIAL_HOST"
    echo
  else
    print_error "Incorrect. Use: echo \$HOSTNAME"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 3: hostname command
  echo "  Step 3: Show the hostname using the classic command."
  read -p "  lab@lab315:~$ " cmd3
  echo
  if [[ "$cmd3" == "hostname" ]]; then
    echo "  $INITIAL_HOST"
    echo
  else
    print_error "Incorrect. Use: hostname"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 4: /etc/hostname contents
  echo "  Step 4: View the configuration file that stores the persistent hostname on most distros."
  read -p "  lab@lab315:~$ " cmd4
  echo
  if [[ "$cmd4" == "cat /etc/hostname" ]]; then
    echo "  $INITIAL_HOST"
    echo
  else
    print_error "Incorrect. Use: cat /etc/hostname"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 5: Choose a new hostname
  echo "  Step 5: For this lab, set the new hostname to exactly: $TARGET_HOST"
  read -p "  lab@lab315:~$ " cmd5
  echo
  if [[ "$cmd5" == "hostnamectl set-hostname $TARGET_HOST" ]]; then
    echo
  else
    print_error "Incorrect. Use exactly: hostnamectl set-hostname $TARGET_HOST"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 6: Verify change via hostnamectl
  echo "  Step 6: Verify the change with the same systemd tool."
  read -p "  lab@lab315:~$ " cmd6
  echo
  if [[ "$cmd6" == "hostnamectl" || "$cmd6" == "hostnamectl status" ]]; then
    echo "   Static hostname: $TARGET_HOST"
    echo "         Icon name: computer-vm"
    echo "           Chassis: vm"
    echo "        Machine ID: 11111111111111111111111111111111"
    echo "           Boot ID: 22222222222222222222222222222222"
    echo "  Operating System: Rocky Linux 10 (Red Quartz)"
    echo "            Kernel: Linux 6.12.0"
    echo "      Architecture: x86-64"
    echo
  else
    print_error "Incorrect. Use 'hostnamectl' or 'hostnamectl status'."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 7: Verify via hostname
  echo "  Step 7: Verify with the classic command."
  read -p "  lab@lab315:~$ " cmd7
  echo
  if [[ "$cmd7" == "hostname" ]]; then
    echo "  $TARGET_HOST"
    echo
  else
    print_error "Incorrect. Use: hostname"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 8: Verify /etc/hostname auto-update
  echo "  Step 8: Check that the config file was updated."
  read -p "  lab@lab315:~$ " cmd8
  echo
  if [[ "$cmd8" == "cat /etc/hostname" ]]; then
    echo "  $TARGET_HOST"
    echo
  else
    print_error "Incorrect. Use: cat /etc/hostname"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 9: Check $HOSTNAME before new login
  echo "  Step 9: Show the environment variable again (before a new login)."
  read -p "  lab@lab315:~$ " cmd9
  echo
  if [[ "$cmd9" == 'echo $HOSTNAME' ]]; then
    echo "  $INITIAL_HOST"
    echo
  else
    print_error "Incorrect. Use: echo \$HOSTNAME"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 10: Simulate new login to refresh env
  echo "  Step 10: Start a new login shell to refresh environment variables."
  read -p "  lab@lab315:~$ " cmd10
  echo
  if [[ "$cmd10" == "exec bash -l" ]]; then
    echo "  (login shell started)"
    echo
  else
    print_error "Incorrect. Use: exec bash -l"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 11: Check $HOSTNAME after new login
  echo "  Step 11: Show the environment variable again (after new login)."
  read -p "  lab@lab315:~$ " cmd11
  echo
  if [[ "$cmd11" == 'echo $HOSTNAME' ]]; then
    echo "  $TARGET_HOST"
    echo
  else
    print_error "Incorrect. Use: echo \$HOSTNAME"
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 12: Legacy Red Hat path
  echo "  Step 12: On older Red Hat-based systems, which file could set the hostname?"
  read -p "  lab@lab315:~$ " cmd12
  echo
  [[ "$cmd12" != "/etc/sysconfig/network" ]] && { print_error "Incorrect. Use: /etc/sysconfig/network"; read -p "Press Enter to retry..." _; continue; }

  # Step 13: Legacy line format
  echo "  Step 13: What exact line would set the hostname in that legacy file to $TARGET_HOST?"
  read -p "  lab@lab315:~$ " cmd13
  echo
  [[ "$cmd13" != "HOSTNAME=$TARGET_HOST" ]] && { print_error "Incorrect. Use exactly: HOSTNAME=$TARGET_HOST"; read -p "Press Enter to retry..." _; continue; }

  # Step 14: hostnamectl field for the actual host name
  echo "  Step 14: In 'hostnamectl' output, which field shows the actual configured hostname?"
  read -p "  lab@lab315:~$ " cmd14
  echo
  [[ "$cmd14" != "Static hostname" ]] && { print_error "Incorrect. The field is: Static hostname"; read -p "Press Enter to retry..." _; continue; }

  # Step 15: Best practice on uppercase characters
  echo "  Step 15: What is the hostname best practice regarding uppercase characters?"
  read -p "  lab@lab315:~$ " cmd15
  echo
  [[ "$cmd15" != "avoid uppercase characters" ]] && { print_error "Incorrect. Answer exactly: avoid uppercase characters"; read -p "Press Enter to retry..." _; continue; }

  print_success "Excellent work!"
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
