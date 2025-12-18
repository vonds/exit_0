#!/bin/bash

# Lab 315: Exploring Network Configuration with NetworkManager – Objectives 109.2 & 109.3
# LPIC-1 Focus: Using nmcli to view, modify, and verify network interfaces and hostnames.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 316: Exploring Network Configuration with NetworkManager"
LAB_ID="lab316"
LAB_XP=45100
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
  center_text "Explore NetworkManager CLI to manage network interfaces and system hostname."
  center_text "Follow the steps carefully and type each command exactly as requested."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  # Step 1: Check NetworkManager status
  echo "  Step 1: Display NetworkManager’s general status."
  read -p "  lab@lab315:~$ " cmd1
  if [[ "$cmd1" == "nmcli general status" ]]; then
    echo
    echo "  STATE      CONNECTIVITY  WIFI-HW  WIFI  WWAN-HW  WWAN"
    echo "  connected  full          enabled  enabled  enabled  disabled"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 2: Show all connections
  echo "  Step 2: Display all active and inactive connections."
  read -p "  lab@lab315:~$ " cmd2
  if [[ "$cmd2" == "nmcli connection show" ]]; then
    echo
    echo "  NAME                UUID                                  TYPE      DEVICE"
    echo "  Wired connection 1  12345678-aaaa-bbbb-cccc-123456789abc  ethernet  enp0s3"
    echo "  Wired connection 2  98765432-bbbb-cccc-dddd-987654321def  ethernet  enp0s8"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 3: Display device summary
  echo "  Step 3: Display a summary of network interfaces."
  read -p "  lab@lab315:~$ " cmd3
  if [[ "$cmd3" == "nmcli device status" ]]; then
    echo
    echo "  DEVICE    TYPE      STATE      CONNECTION"
    echo "  enp0s3    ethernet  connected  Wired connection 1"
    echo "  enp0s8    ethernet  connected  Wired connection 2"
    echo "  lo        loopback  unmanaged  --"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 4: Display connection details
  echo "  Step 4: View detailed settings for the first Ethernet interface."
  read -p "  lab@lab315:~$ " cmd4
  if [[ "$cmd4" == "nmcli connection show \"Wired connection 1\"" ]]; then
    echo
    echo "  connection.id:                          Wired connection 1"
    echo "  connection.interface-name:              enp0s3"
    echo "  ipv4.method:                            auto"
    echo "  ipv4.addresses:                         10.0.3.50/24"
    echo "  ipv4.gateway:                           10.0.3.1"
    echo "  GENERAL.DEVICE:                         enp0s3"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 5: Confirm IP configuration
  echo "  Step 5: Display current IP address information using the ip command."
  read -p "  lab@lab315:~$ " cmd5
  if [[ "$cmd5" == "ip addr show enp0s3" ]]; then
    echo
    echo "  2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP"
    echo "      link/ether 08:00:27:aa:bb:cc brd ff:ff:ff:ff:ff:ff"
    echo "      inet 10.0.3.50/24 brd 10.0.3.255 scope global enp0s3"
    echo "         valid_lft forever preferred_lft forever"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 6: Switch IPv4 method to static (nmcli is silent on success)
  echo "  Step 6: Modify the connection to use a static IP configuration."
  read -p "  lab@lab315:~$ " cmd6
  if [[ "$cmd6" == "sudo nmcli connection modify \"Wired connection 2\" ipv4.method manual" ]]; then
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 7: Assign a new static IP (nmcli is silent on success)
  echo "  Step 7: Assign a new static IP and netmask to the interface."
  read -p "  lab@lab315:~$ " cmd7
  if [[ "$cmd7" == "sudo nmcli connection modify \"Wired connection 2\" ipv4.addresses 10.0.4.15/24" ]]; then
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 8: Bring the interface up (this prints success)
  echo "  Step 8: Bring the modified interface online."
  read -p "  lab@lab315:~$ " cmd8
  if [[ "$cmd8" == "sudo nmcli connection up \"Wired connection 2\"" ]]; then
    echo
    echo "  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/3)"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 9: Verify the new IP assignment
  echo "  Step 9: Verify that the IP address has changed."
  read -p "  lab@lab315:~$ " cmd9
  if [[ "$cmd9" == "ip addr show enp0s8" ]]; then
    echo
    echo "  3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP"
    echo "      link/ether 08:00:27:bb:cc:dd brd ff:ff:ff:ff:ff:ff"
    echo "      inet 10.0.4.15/24 brd 10.0.4.255 scope global enp0s8"
    echo "         valid_lft forever preferred_lft forever"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 10: Display system hostname using nmcli
  echo "  Step 10: Display the system’s hostname using NetworkManager."
  read -p "  lab@lab315:~$ " cmd10
  if [[ "$cmd10" == "nmcli general hostname" ]]; then
    echo
    echo "  lab-station"
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 11: Change the system hostname using nmcli (silent on success)
  echo "  Step 11: Change the system hostname to nm-host01 using NetworkManager."
  read -p "  lab@lab315:~$ " cmd11
  if [[ "$cmd11" == "sudo nmcli general hostname nm-host01" ]]; then
    echo
  else
    echo
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 12: Confirm the hostname change
  echo "  Step 12: Confirm that the hostname has been updated."
  read -p "  lab@lab315:~$ " cmd12
  if [[ "$cmd12" == "nmcli general hostname" ]]; then
    echo
    echo "  nm-host01"
    echo
  else
    echo
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
