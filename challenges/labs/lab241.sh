#!/bin/bash

# Lab 241: Update /etc/hosts and test name resolution — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real system files are modified.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 241: /etc/hosts + ping by name/IP"
LAB_ID="lab241"
LAB_XP=20600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated targets
IP1="192.168.50.10"
HN1_FQDN="server1.example.local"
HN1_SHORT="server1"
IP2="192.168.60.20"
HN2_FQDN="server2.example.local"
HN2_SHORT="server2"

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
  center_text "Goal: Add two host mappings to /etc/hosts, then verify name resolution and connectivity."
  center_text "Targets: ${IP1} ↔ ${HN1_FQDN} (${HN1_SHORT}), ${IP2} ↔ ${HN2_FQDN} (${HN2_SHORT})."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: View current hosts file (simulated)
  draw_lab_ui
  echo "  Step 1: Display the current /etc/hosts."
  read -p "  lab@lab241:~\$ " cmd1
  if [[ "$cmd1" == "cat /etc/hosts" ]]; then
    echo "  127.0.0.1   localhost"
    echo "  ::1         localhost ip6-localhost ip6-loopback"
    echo "  127.0.1.1   lpic-lab241"
  else
    print_error "Hint: View the file directly to see existing mappings."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Add server1 mapping (simulate tee echoing the line)
  echo "  Step 2: Append a hosts entry for ${HN1_FQDN} (${IP1})."
  read -p "  lab@lab241:~\$ " cmd2
  if [[ "$cmd2" == "echo '${IP1} ${HN1_FQDN} ${HN1_SHORT}' | sudo tee -a /etc/hosts" ]] || \
     [[ "$cmd2" == "sudo sh -c 'echo \"${IP1} ${HN1_FQDN} ${HN1_SHORT}\" >> /etc/hosts'" ]]; then
    echo "  ${IP1} ${HN1_FQDN} ${HN1_SHORT}"
  else
    print_error "Hint: Append a properly formatted line with the IP, FQDN, and shortname."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Add server2 mapping
  echo "  Step 3: Append a hosts entry for ${HN2_FQDN} (${IP2})."
  read -p "  lab@lab241:~\$ " cmd3
  if [[ "$cmd3" == "echo '${IP2} ${HN2_FQDN} ${HN2_SHORT}' | sudo tee -a /etc/hosts" ]] || \
     [[ "$cmd3" == "sudo sh -c 'echo \"${IP2} ${HN2_FQDN} ${HN2_SHORT}\" >> /etc/hosts'" ]]; then
    echo "  ${IP2} ${HN2_FQDN} ${HN2_SHORT}"
  else
    print_error "Hint: Append the second mapping in the same format as the first."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify the new lines exist
  echo "  Step 4: Verify both mappings are present."
  read -p "  lab@lab241:~\$ " cmd4
  if [[ "$cmd4" == "grep -E 'server1|server2' /etc/hosts" ]] || \
     [[ "$cmd4" == "grep server /etc/hosts" ]]; then
    echo "  ${IP1} ${HN1_FQDN} ${HN1_SHORT}"
    echo "  ${IP2} ${HN2_FQDN} ${HN2_SHORT}"
  else
    print_error "Hint: Use grep to filter for the hostnames you just added."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Ping by IP
  echo "  Step 5: Test connectivity by IP to ${IP1}."
  read -p "  lab@lab241:~\$ " cmd5
  if [[ "$cmd5" == "ping -c 2 ${IP1}" ]]; then
    echo "  PING ${IP1} (${IP1}) 56(84) bytes of data."
    echo "  64 bytes from ${IP1}: icmp_seq=1 ttl=64 time=0.482 ms"
    echo "  64 bytes from ${IP1}: icmp_seq=2 ttl=64 time=0.497 ms"
    echo
    echo "  --- ${IP1} ping statistics ---"
    echo "  2 packets transmitted, 2 received, 0% packet loss, time 1002ms"
    echo "  rtt min/avg/max/mdev = 0.482/0.490/0.497/0.008 ms"
  else
    print_error "Hint: Try a short, count-limited ping to the first IP."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Ping by hostname (FQDN or short)
  echo "  Step 6: Resolve and ping by hostname (${HN1_FQDN} or ${HN1_SHORT})."
  read -p "  lab@lab241:~\$ " cmd6
  if [[ "$cmd6" == "ping -c 2 ${HN1_FQDN}" ]]; then
    echo "  PING ${HN1_FQDN} (${IP1}) 56(84) bytes of data."
    echo "  64 bytes from ${IP1}: icmp_seq=1 ttl=64 time=0.489 ms"
    echo "  64 bytes from ${IP1}: icmp_seq=2 ttl=64 time=0.505 ms"
    echo
    echo "  --- ${HN1_FQDN} ping statistics ---"
    echo "  2 packets transmitted, 2 received, 0% packet loss, time 1003ms"
    echo "  rtt min/avg/max/mdev = 0.489/0.497/0.505/0.008 ms"
  elif [[ "$cmd6" == "ping -c 2 ${HN1_SHORT}" ]]; then
    echo "  PING ${HN1_SHORT} (${IP1}) 56(84) bytes of data."
    echo "  64 bytes from ${IP1}: icmp_seq=1 ttl=64 time=0.491 ms"
    echo "  64 bytes from ${IP1}: icmp_seq=2 ttl=64 time=0.499 ms"
    echo
    echo "  --- ${HN1_SHORT} ping statistics ---"
    echo "  2 packets transmitted, 2 received, 0% packet loss, time 1001ms"
    echo "  rtt min/avg/max/mdev = 0.491/0.495/0.499/0.004 ms"
  else
    print_error "Hint: Use ping with either the FQDN or short hostname you added."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Verify resolution with getent
  echo "  Step 7: Confirm name resolution via NSS."
  read -p "  lab@lab241:~\$ " cmd7
  if [[ "$cmd7" == "getent hosts ${HN1_SHORT}" || "$cmd7" == "getent hosts ${HN1_FQDN}" ]]; then
    echo "  ${IP1} ${HN1_FQDN} ${HN1_SHORT}"
  else
    print_error "Hint: Use getent hosts <name> to see resolver output from NSS."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You updated /etc/hosts, verified mappings, and confirmed resolution (simulated)."
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
