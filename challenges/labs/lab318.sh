#!/bin/bash

# Lab 318: Modern Linux Network Configuration with NetworkManager – Objectives 109.2 & 109.3
# LPIC-1 Focus: Using nmcli to view interfaces, modify configurations, and manage hostnames.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 318: Modern Network Configuration with NetworkManager"
LAB_ID="lab318"
LAB_XP=46200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
  center_text "Use NetworkManager CLI to inspect, modify, and verify network settings."
  center_text "Follow each step carefully and enter commands precisely."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  # Step 1
  echo "  Step 1: Display NetworkManager’s general status."
  read -p "  lab@lab318:~$ " cmd1
  echo
  if [[ "$cmd1" == "nmcli general status" ]]; then
    echo "  STATE      CONNECTIVITY  WIFI-HW  WIFI  WWAN-HW  WWAN"
    echo "  connected  full          enabled  enabled  enabled  disabled"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 2
  echo "  Step 2: Show available network connections."
  read -p "  lab@lab318:~$ " cmd2
  echo
  if [[ "$cmd2" == "nmcli connection show" ]]; then
    echo "  NAME                UUID                                  TYPE      DEVICE"
    echo "  Wired connection 1  12345678-aaaa-bbbb-cccc-123456789abc  ethernet  enp0s3"
    echo "  Wired connection 2  98765432-bbbb-cccc-dddd-987654321def  ethernet  enp0s8"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 3
  echo "  Step 3: View all network devices managed by NetworkManager."
  read -p "  lab@lab318:~$ " cmd3
  echo
  if [[ "$cmd3" == "nmcli device status" ]]; then
    echo "  DEVICE    TYPE      STATE      CONNECTION"
    echo "  enp0s3    ethernet  connected  Wired connection 1"
    echo "  enp0s8    ethernet  connected  Wired connection 2"
    echo "  lo        loopback  unmanaged  --"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 4
  echo "  Step 4: Display details for Wired connection 1."
  read -p "  lab@lab318:~$ " cmd4
  echo
  if [[ "$cmd4" == "nmcli connection show \"Wired connection 1\"" ]]; then
    echo "  connection.id:                          Wired connection 1"
    echo "  connection.interface-name:              enp0s3"
    echo "  ipv4.method:                            auto"
    echo "  ipv4.addresses:                         10.0.3.50/24"
    echo "  ipv4.gateway:                           10.0.3.1"
    echo "  GENERAL.DEVICE:                         enp0s3"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 5
  echo "  Step 5: Display the IP address assigned to enp0s3."
  read -p "  lab@lab318:~$ " cmd5
  echo
  if [[ "$cmd5" == "ip addr show enp0s3" ]]; then
    echo "  2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP"
    echo "      link/ether 08:00:27:aa:bb:cc brd ff:ff:ff:ff:ff:ff"
    echo "      inet 10.0.3.50/24 brd 10.0.3.255 scope global enp0s3"
    echo "         valid_lft forever preferred_lft forever"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 6
  echo "  Step 6: Change Wired connection 2 from dynamic to static addressing."
  read -p "  lab@lab318:~$ " cmd6
  echo
  if [[ "$cmd6" == "sudo nmcli connection modify \"Wired connection 2\" ipv4.method manual" ]]; then
    echo "  (no output)"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 7
  echo "  Step 7: Assign static address 10.0.4.15/24 to Wired connection 2."
  read -p "  lab@lab318:~$ " cmd7
  echo
  if [[ "$cmd7" == "sudo nmcli connection modify \"Wired connection 2\" ipv4.addresses 10.0.4.15/24" ]]; then
    echo "  (no output)"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 8
  echo "  Step 8: Bring the interface enp0s8 online."
  read -p "  lab@lab318:~$ " cmd8
  echo
  if [[ "$cmd8" == "sudo nmcli connection up \"Wired connection 2\"" ]]; then
    echo "  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/3)"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 9
  echo "  Step 9: Verify enp0s8 now uses the new static IP address."
  read -p "  lab@lab318:~$ " cmd9
  echo
  if [[ "$cmd9" == "ip addr show enp0s8" ]]; then
    echo "  3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP"
    echo "      link/ether 08:00:27:bb:cc:dd brd ff:ff:ff:ff:ff:ff"
    echo "      inet 10.0.4.15/24 brd 10.0.4.255 scope global enp0s8"
    echo "         valid_lft forever preferred_lft forever"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 10
  echo "  Step 10: Display the system’s current hostname using NetworkManager."
  read -p "  lab@lab318:~$ " cmd10
  echo
  if [[ "$cmd10" == "nmcli general hostname" ]]; then
    echo "  lab-station"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 11
  echo "  Step 11: Change the system hostname to net-mgr01 using NetworkManager."
  read -p "  lab@lab318:~$ " cmd11
  echo
  if [[ "$cmd11" == "sudo nmcli general hostname net-mgr01" ]]; then
    echo "  (no output)"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 12
  echo "  Step 12: Confirm the hostname has been updated."
  read -p "  lab@lab318:~$ " cmd12
  echo
  if [[ "$cmd12" == "nmcli general hostname" ]]; then
    echo "  net-mgr01"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

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
