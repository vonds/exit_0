#!/bin/bash

# Lab 308: Inspecting Network Protocols – Objective 109.1
# LPIC-1 focus: OSI vs TCP/IP mapping (conceptual), connection vs connectionless,
# TCP three-way handshake, ICMP echo (ping), DNS lookups (UDP/TCP 53),
# traceroute behavior, and inspecting sockets with ss.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 308"
LAB_ID="lab308"
LAB_XP=36800
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

PROMPT="student@lab308:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Objective 109.1 — Inspecting Network Protocols"
  center_text "Interactive: ping/ICMP, DNS queries, traceroute, TCP handshake, and socket inspection."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1: ICMP echo request/reply with ping (allow common variants)
  echo "  Step 1: Send two ICMP echo requests to 8.8.8.8."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "ping -c 2 8.8.8.8" && "$cmd1" != "ping -c2 8.8.8.8" ]]; then
    print_error "Incorrect. Use: ping -c 2 8.8.8.8  (or)  ping -c2 8.8.8.8"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data."
  echo "  64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=13.1 ms"
  echo "  64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=12.8 ms"
  echo "  "
  echo "  --- 8.8.8.8 ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss, time 1002ms"
  echo "  rtt min/avg/max/mdev = 12.8/12.9/13.1/0.2 ms"

  # STEP 2: Which protocol does ping use? (accept ICMP/icmp)
  echo
  echo "  Step 2: Which protocol does ping use? Enter just the acronym."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "ICMP" && "$cmd2" != "icmp" ]]; then
    print_error "Incorrect. Acceptable answers: ICMP  or  icmp"
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 3: DNS lookup (allow three common commands; static outputs per command)
  echo
  echo "  Step 3: Resolve a hostname (example.com) to an address."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" == "dig +short example.com" ]]; then
    echo
    echo "  93.184.216.34"
  elif [[ "$cmd3" == "host example.com" ]]; then
    echo
    echo "  example.com has address 93.184.216.34"
    echo "  example.com has IPv6 address 2606:2800:220:1:248:1893:25c8:1946"
  elif [[ "$cmd3" == "getent hosts example.com" ]]; then
    echo
    echo "  93.184.216.34   example.com"
  else
    print_error "Incorrect. Use one of: dig +short example.com  |  host example.com  |  getent hosts example.com"
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 4: Primary transport for DNS queries (accept UDP/udp)
  echo
  echo "  Step 4: Enter the primary transport protocol used by DNS queries."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "UDP" && "$cmd4" != "udp" ]]; then
    print_error "Incorrect. Acceptable answers: UDP  or  udp"
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 5: Inspect sockets with ss (allow several exact forms)
  echo
  echo "  Step 5: List TCP and UDP sockets without resolving names."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "ss -tun" && "$cmd5" != "ss -tuna" && "$cmd5" != "ss -tunp" && "$cmd5" != "ss -tuna | head" ]]; then
    print_error "Incorrect. Use one of: ss -tun  |  ss -tuna  |  ss -tunp  |  ss -tuna | head"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  Netid State   Recv-Q Send-Q Local Address:Port   Peer Address:Port"
  echo "  tcp   ESTAB   0      0      192.168.1.10:46528   93.184.216.34:443"
  echo "  tcp   ESTAB   0      0      192.168.1.10:46522   8.8.8.8:443"
  echo "  udp   UNCONN  0      0      127.0.0.53:53        0.0.0.0:*"
  echo "  udp   UNCONN  0      0      192.168.1.10:53241   8.8.8.8:53"

  # STEP 6: Three-way handshake (allow multiple exact variants)
  echo
  echo "  Step 6: Enter the three TCP handshake messages in order, comma-separated (no spaces)."      
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "SYN,SYN-ACK,ACK" && "$cmd6" != "syn,syn-ack,ack" && "$cmd6" != "SYN,SYNACK,ACK" && "$cmd6" != "syn,synack,ack" ]]; then
    print_error "Incorrect. Acceptable answers: SYN,SYN-ACK,ACK  |  syn,syn-ack,ack  |  SYN,SYNACK,ACK  |  syn,synack,ack"
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 7: HTTPS headers (allow example.com and www.example.com)
  echo
    echo "  Step 7: Fetch only the headers from the endpoint https://example.com."
    read -p "  $PROMPT" cmd7
    if [[ "$cmd7" != "curl -I https://example.com" && \
            "$cmd7" != "curl -I https://www.example.com" && \
            "$cmd7" != "curl --head https://example.com" && \
            "$cmd7" != "curl --head https://www.example.com" && \
            "$cmd7" != "curl -IL https://example.com" && \
            "$cmd7" != "curl -IL https://www.example.com" ]]; then
        print_error "Incorrect. Use: curl -I https://example.com  (also allowed: --head, -IL, or the www host)"
        read -p "Press Enter to continue..." _
        continue
    fi

  echo
  echo "  HTTP/2 200"
  echo "  content-type: text/html; charset=UTF-8"
  echo "  content-length: 1256"
  echo "  cache-control: max-age=604800"
  echo "  date: Tue, 21 Oct 2025 12:34:56 GMT"
  echo "  server: ECD (nyc/1234)"
  echo "  "

  # STEP 8: Traceroute / tracepath (allow either)
  echo "  Step 8: Trace the path to 8.8.8.8 without resolving names."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" == "traceroute -n 8.8.8.8" ]]; then
    echo
    echo "  traceroute to 8.8.8.8 (8.8.8.8), 30 hops max"
    echo "   1  192.168.1.1    0.456 ms  0.392 ms  0.404 ms"
    echo "   2  10.0.0.1       6.221 ms  6.115 ms  6.107 ms"
    echo "   3  203.0.113.5   10.934 ms 10.872 ms 10.866 ms"
    echo "   4  8.8.8.8       12.801 ms 12.777 ms 12.768 ms"
  elif [[ "$cmd8" == "tracepath -n 8.8.8.8" ]]; then
    echo
    echo "   1:  192.168.1.1                                         0.456ms"
    echo "   2:  10.0.0.1                                            6.221ms"
    echo "   3:  203.0.113.5                                        10.934ms"
    echo "   4:  8.8.8.8                                            12.801ms reached"
    echo "       Resume: pmtu 1500 hops 4 back 4"
  else
    print_error "Incorrect. Use: traceroute -n 8.8.8.8  (or)  tracepath -n 8.8.8.8"
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 9: Default transport for traceroute on Linux (accept UDP/udp)
  echo
  echo "  Step 9: Enter the default transport used by traceroute on Linux (without -I)."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "UDP" && "$cmd9" != "udp" ]]; then
    print_error "Incorrect. Acceptable answers: UDP  or  udp"
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 10: Connection vs connectionless (accept upper/lower)
  echo
  echo "  Step 10: Enter the connection-oriented protocol, then the two connectionless protocols."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "TCP,UDP,ICMP" && "$cmd10" != "tcp,udp,icmp" ]]; then
    print_error "Incorrect. Acceptable answers: TCP,UDP,ICMP  (or)  tcp,udp,icmp"
    read -p "Press Enter to continue..." _
    continue
  fi

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


# windows 80k
# ADK December 2022

# use AI for docs
# bandicam
# uac windows permissions
# pxe boot server - (secure boot)