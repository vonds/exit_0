#!/bin/bash

# Lab 456: RHEL Networking Automation — configure a new NIC with nmcli + update /etc/hosts safely

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 456: Script nmcli Static IP + Safe /etc/hosts Update"
LAB_ID="lab456"
LAB_XP=45600
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

normalize_script() {
  sed -e 's/[[:space:]]\+$//' | awk 'NR==1{first=NR} {lines[NR]=$0} END{
    start=1
    while (start<=NR && lines[start]=="") start++
    end=NR
    while (end>=1 && lines[end]=="") end--
    for (i=start;i<=end;i++) print lines[i]
  }'
}

expected_script() {
  cat <<'EOF'
#!/bin/bash
set -euo pipefail

DEV="enp0s8"
CON_NAME="lab456-static"
IP_CIDR="192.168.56.50/24"
GW="192.168.56.1"
DNS="1.1.1.1"
HOST_IP="192.168.56.50"
HOSTNAME_CHOSEN="appnode456"

cp -a /etc/hosts /etc/hosts.bak.lab456

nmcli con add type ethernet ifname "$DEV" con-name "$CON_NAME" ipv4.method manual ipv4.addresses "$IP_CIDR" ipv4.gateway "$GW" ipv4.dns "$DNS" autoconnect yes

nmcli con up "$CON_NAME"

printf '%s\t%s\n' "$HOST_IP" "$HOSTNAME_CHOSEN" >> /etc/hosts

nmcli -p dev show "$DEV" | grep -E 'IP4.ADDRESS|IP4.GATEWAY|IP4.DNS'

tail -n 5 /etc/hosts
EOF
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "In VirtualBox Manager, present a NEW network interface to server40."
  center_text "On server40, log in as user1 (has sudo)."
  echo
  center_text "Write ONE bash script that:"
  center_text "1) Uses nmcli to configure custom IPv4 settings on the new NIC (manual IP)"
  center_text "2) Copies /etc/hosts to a backup file"
  center_text "3) Chooses a hostname and appends a mapping to /etc/hosts (no overwriting)"
  echo
  center_text "Notes:"
  center_text "- This lab uses enp0s8 as the 'new' NIC (the lab environment name)."
  center_text "- You must not overwrite /etc/hosts; append only."
  echo
  center_text "This lab simulates editing by having you paste the ENTIRE script, then validating it."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify the new NIC
  echo "  Step 1: List network devices and identify the newly-added interface."
  read -p "  lab@rhel-lab456:~$ " cmd1
  echo
  if [[ "$cmd1" != "nmcli dev status" && "$cmd1" != "ip link show" && "$cmd1" != "ip -br link" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  DEVICE   TYPE      STATE      CONNECTION"
  echo "  enp0s3   ethernet  connected  System enp0s3"
  echo "  enp0s8   ethernet  disconnected  --"
  echo "  lo       loopback  unmanaged  --"
  echo

  # STEP 2: Open editor
  echo "  Step 2: Open the script for editing: /home/user1/lab456_net.sh"
  read -p "  lab@rhel-lab456:~$ " cmd2
  echo
  if [[ "$cmd2" != "vim /home/user1/lab456_net.sh" && "$cmd2" != "nano /home/user1/lab456_net.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 3: Paste full script and validate
  echo "  Step 3: Paste the FULL script content now."
  echo "          When finished, type a single line containing: END"
  echo
  echo "          Note: strict check against expected script (ignores trailing spaces"
  echo "          and leading/trailing blank lines, but otherwise must match)."
  echo

  tmp="$(mktemp)"
  while IFS= read -r line; do
    [[ "$line" == "END" ]] && break
    printf '%s\n' "$line" >> "$tmp"
  done
  echo

  user_norm="$(mktemp)"
  exp_norm="$(mktemp)"
  normalize_script < "$tmp" > "$user_norm"
  expected_script | normalize_script > "$exp_norm"

  if ! diff -u "$exp_norm" "$user_norm" >/dev/null 2>&1; then
    print_error "Script validation failed."
    echo
    print_info "Expected script:"
    echo
    expected_script
    echo
    print_info "Fix your script and try again."
    echo
    read -p "Press Enter to restart the lab..." _
    rm -f "$tmp" "$user_norm" "$exp_norm"
    continue
  fi

  echo "  (script content validated)"
  echo "  (saved to /home/user1/lab456_net.sh)"
  echo
  rm -f "$tmp" "$user_norm" "$exp_norm"

  # STEP 4: Make executable
  echo "  Step 4: Make the script executable."
  read -p "  lab@rhel-lab456:~$ " cmd4
  echo
  if [[ "$cmd4" != "chmod +x /home/user1/lab456_net.sh" && "$cmd4" != "chmod +x lab456_net.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 5: Run script with sudo
  echo "  Step 5: Run your script with sudo."
  read -p "  lab@rhel-lab456:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo /home/user1/lab456_net.sh" && "$cmd5" != "sudo ./lab456_net.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Connection 'lab456-static' (a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d) successfully added."
  echo "  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/12)"
  echo "  IP4.ADDRESS[1]:                         192.168.56.50/24"
  echo "  IP4.GATEWAY:                            192.168.56.1"
  echo "  IP4.DNS[1]:                             1.1.1.1"
  echo "  (hosts backup created: /etc/hosts.bak.lab456)"
  echo "  (mapping appended to /etc/hosts)"
  echo
  echo "  192.168.56.50    appnode456"
  echo

  # STEP 6: Verify interface IP
  echo "  Step 6: Verify the new interface has the configured IPv4 address."
  read -p "  lab@rhel-lab456:~$ " cmd6
  echo
  if [[ "$cmd6" != "nmcli -p dev show enp0s8" && \
        "$cmd6" != "ip -br addr show enp0s8" && \
        "$cmd6" != "ip addr show enp0s8" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  enp0s8: connected"
  echo "  IP4.ADDRESS[1]: 192.168.56.50/24"
  echo "  IP4.GATEWAY: 192.168.56.1"
  echo "  IP4.DNS[1]: 1.1.1.1"
  echo

  # STEP 7: Verify /etc/hosts append (no overwrite)
  echo "  Step 7: Verify /etc/hosts contains the new mapping and existing content remains."
  read -p "  lab@rhel-lab456:~$ " cmd7
  echo
  if [[ "$cmd7" != "tail -n 5 /etc/hosts" && \
        "$cmd7" != "grep -n appnode456 /etc/hosts" && \
        "$cmd7" != "sudo tail -n 5 /etc/hosts" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  127.0.0.1   localhost localhost.localdomain"
  echo "  ::1         localhost localhost.localdomain"
  echo "  192.168.56.50    appnode456"
  echo

  print_success "Great job."
  print_info "You wrote a script that configured a new NIC using nmcli (manual IPv4),"
  print_info "safely backed up /etc/hosts, and appended a hostname mapping without overwriting."
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
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
