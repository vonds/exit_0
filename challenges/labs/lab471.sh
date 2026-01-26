#!/bin/bash

# Lab 471: Rocky Linux 10 — Firewall, Routing, Time, and NTP (RHCSA Focus)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 471: Firewall, Routing, and Time Services (Rocky 10)"
LAB_ID="lab471"
LAB_XP=47100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab471:~$ "

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
  center_text "You're hardening and finalizing a Rocky Linux 10 system."
  center_text "You must configure firewall rules, manage routes,"
  center_text "adjust time settings, and enable NTP synchronization."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: add firewall port permanent
  echo "  Step 1: Permanently allow TCP port 7869."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo firewall-cmd --add-port=7869/tcp --permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 2: add firewall service permanent
  echo "  Step 2: Permanently allow HTTPS service."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo firewall-cmd --add-service=https --permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 3: list active firewall
  echo "  Step 3: Display the ACTIVE firewall configuration."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo firewall-cmd --list-all" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  public (active)"
  echo "    target: default"
  echo "    icmp-block-inversion: no"
  echo "    interfaces: eth0 eth1"
  echo "    sources:"
  echo "    services: cockpit dhcpv6-client ssh"
  echo "    ports: 8080/tcp 22/tcp 7869/tcp 53/udp"
  echo "    protocols:"
  echo "    forward: yes"
  echo "    masquerade: no"
  echo "    forward-ports:"
  echo "    source-ports:"
  echo "    icmp-blocks:"
  echo "    rich rules:"
  echo

  # STEP 4: remove port runtime
  echo "  Step 4: Remove UDP port 53 from the ACTIVE configuration (runtime)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo firewall-cmd --remove-port=53/udp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 5: add trusted source permanent
  echo "  Step 5: Permanently add source 10.11.12.0/24 to the trusted zone."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo firewall-cmd --add-source=10.11.12.0/24 --zone=trusted --permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 6: list active firewall again (realistic: 53/udp removed, https service not shown until reload if only permanent change)
  echo "  Step 6: Display ACTIVE firewall configuration again."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo firewall-cmd --list-all" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  public (active)"
  echo "    target: default"
  echo "    icmp-block-inversion: no"
  echo "    interfaces: eth0 eth1"
  echo "    sources:"
  echo "    services: cockpit dhcpv6-client ssh"
  echo "    ports: 8080/tcp 22/tcp 7869/tcp"
  echo "    protocols:"
  echo "    forward: yes"
  echo "    masquerade: no"
  echo "    forward-ports:"
  echo "    source-ports:"
  echo "    icmp-blocks:"
  echo "    rich rules:"
  echo

  # STEP 7: runtime-to-permanent (saves runtime changes; permanent also already has https + 7869)
  echo "  Step 7: Save runtime firewall changes into permanent config."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo firewall-cmd --runtime-to-permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 8: list permanent firewall (should include https now)
  echo "  Step 8: Display PERMANENT firewall configuration."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo firewall-cmd --list-all --permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  public (active)"
  echo "    target: default"
  echo "    icmp-block-inversion: no"
  echo "    interfaces: eth1"
  echo "    sources:"
  echo "    services: cockpit dhcpv6-client ssh https"
  echo "    ports: 8080/tcp 22/tcp 7869/tcp"
  echo "    protocols:"
  echo "    forward: yes"
  echo "    masquerade: no"
  echo "    forward-ports:"
  echo "    source-ports:"
  echo "    icmp-blocks:"
  echo "    rich rules:"
  echo

  # STEP 9: add temporary route
  echo "  Step 9: Add a TEMPORARY route to 192.168.0.0/24 via 172.28.128.100."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo ip route add 192.168.0.0/24 via 172.28.128.100" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 10: persist route via NM
  echo "  Step 10: Persist that route with NetworkManager on connection 'System eth1'."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo nmcli connection modify 'System eth1' +ipv4.routes '192.168.0.0/24 172.28.128.100'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 11: reapply
  echo "  Step 11: Reapply eth1 connection settings to the device."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo nmcli device reapply eth1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Connection successfully reapplied to device 'eth1'."
  echo

  # STEP 12: ip route show (realistic multi-route output)
  echo "  Step 12: Show routing table."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "ip route show" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  default via 172.28.128.1 dev eth1 proto dhcp src 172.28.128.73 metric 100"
  echo "  default via 192.168.121.1 dev eth0 proto dhcp src 192.168.121.153 metric 101"
  echo "  172.12.0.0/24 dev docker0 proto kernel scope link src 172.12.0.1 linkdown"
  echo "  172.28.128.0/24 dev eth1 proto kernel scope link src 172.28.128.73 metric 100"
  echo "  192.168.121.0/24 dev eth0 proto kernel scope link src 192.168.121.153 metric 101"
  echo "  192.168.0.0/24 via 172.28.128.100 dev eth1"
  echo

  # STEP 13: add secondary IP
  echo "  Step 13: Add IP address 10.0.0.50/24 to eth1."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo ip a add 10.0.0.50/24 dev eth1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 14: list timezones America
  echo "  Step 14: List timezones that contain 'America'."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "timedatectl list-timezones | grep America" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  America/Chicago"
  echo "  America/Denver"
  echo "  America/Los_Angeles"
  echo "  America/New_York"
  echo "  America/Phoenix"
  echo

  # STEP 15: set timezone
  echo "  Step 15: Set timezone to Asia/Kolkata."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sudo timedatectl set-timezone Asia/Kolkata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 16: install chrony (realistic yum/dnf summary)
  echo "  Step 16: Install chrony."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "sudo yum install chrony -y" && "$cmd16" != "sudo dnf install chrony -y" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:33:42 ago on Thu 15 Jan 2026 06:03:43 PM IST."
  echo "  Dependencies resolved."
  echo "  ================================================================================"
  echo "   Package      Architecture   Version          Repository                   Size"
  echo "  ================================================================================"
  echo "  Installing:"
  echo "   chrony       x86_64         4.8-1.el10       baseos                      350 k"
  echo
  echo "  Transaction Summary"
  echo "  ================================================================================"
  echo "  Install  1 Package"
  echo
  echo "  Total download size: 350 k"
  echo "  Installed size: 680 k"
  echo "  Downloading Packages:"
  echo "  chrony-4.8-1.el10.x86_64.rpm                                     2.8 MB/s | 350 kB  00:00"
  echo "  Running transaction check"
  echo "  Transaction check succeeded."
  echo "  Running transaction test"
  echo "  Transaction test succeeded."
  echo "  Running transaction"
  echo "    Installing       : chrony-4.8-1.el10.x86_64                                    1/1"
  echo "    Running scriptlet: chrony-4.8-1.el10.x86_64                                    1/1"
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/chronyd.service → /usr/lib/systemd/system/chronyd.service."
  echo
  echo "  Complete!"
  echo

  # STEP 17: start chronyd
  echo "  Step 17: Start chronyd."
  read -p "$PROMPT" cmd17
  echo
  if [[ "$cmd17" != "sudo systemctl start chronyd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 18: enable chronyd
  echo "  Step 18: Enable chronyd."
  read -p "$PROMPT" cmd18
  echo
  if [[ "$cmd18" != "sudo systemctl enable chronyd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/chronyd.service → /usr/lib/systemd/system/chronyd.service."
  echo

  # STEP 19: timedatectl show (realistic keys)
  echo "  Step 19: Verify timezone and NTP state."
  read -p "$PROMPT" cmd19
  echo
  if [[ "$cmd19" != "sudo timedatectl show" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Timezone=Asia/Kolkata"
  echo "  LocalRTC=no"
  echo "  CanNTP=yes"
  echo "  NTP=yes"
  echo "  NTPSynchronized=yes"
  echo "  TimeUSec=Thu 2026-01-15 18:37:59 IST"
  echo "  RTCTimeUSec=Thu 2026-01-15 18:37:59 IST"
  echo

  # STEP 20: set-local-rtc 1 (real warning)
  echo "  Step 20: Set RTC to local time (LocalRTC=1)."
  read -p "$PROMPT" cmd20
  echo
  if [[ "$cmd20" != "sudo timedatectl set-local-rtc 1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Warning: The system is now being configured to read the RTC time in the local time zone"
  echo "           This mode cannot be fully supported. It will create various problems"
  echo "           with time zone changes and daylight saving time adjustments. The RTC"
  echo "           time is never updated, it relies on external facilities to maintain it."
  echo "           If at all possible, use RTC in UTC"
  echo

  print_success "Excellent work."
  print_info "You completed RHCSA-relevant tasks on Rocky 10:"
  print_info "- firewalld (ports/services, runtime vs permanent, zones, runtime-to-permanent)"
  print_info "- routing (temporary ip route + persistent nmcli route + reapply)"
  print_info "- addressing (secondary IP via ip addr)"
  print_info "- time services (timezone + chrony + NTP verification + RTC mode warning)"
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
