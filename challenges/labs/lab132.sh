#!/bin/bash

# Lab 132: Networking Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 6"
LAB_ID="lab132"
LAB_XP=22500
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
    center_text "Work with networking fundamentals commands and concepts. (set 6)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: A lab appliance must present a specific vendor MAC for eth0 to access a VLAN. Apply the MAC 02:11:22:33:44:55."
    read -p "  lab@lab132:~$ " cmd1
    echo
    [[ "$cmd1" != "ifconfig eth0 hw ether 02:11:22:33:44:55" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 2: Route lookups are slow on this host due to name resolution. Show the routing table without resolving names."
    read -p "  lab@lab132:~$ " cmd2
    echo
    [[ "$cmd2" != "route -n" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Kernel IP routing table"
    echo "  Destination     Gateway         Genmask         Flags Metric Ref    Use Iface"
    echo "  0.0.0.0         192.168.1.1     0.0.0.0         UG       0   0        0 eth0"
    echo "  192.168.1.0     0.0.0.0         255.255.255.0   U        0   0        0 eth0"
    echo

    echo "  Step 3: You swapped hardware but reused an IP. Clear your machine's stale mapping for 192.168.1.50 so it relearns the address."
    read -p "  lab@lab132:~$ " cmd3
    echo
    [[ "$cmd3" != "arp -d 192.168.1.50" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 4: Support requests the current link status and signal details for wlan0."
    read -p "  lab@lab132:~$ " cmd4
    echo
    [[ "$cmd4" != "iw dev wlan0 link" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connected to 00:16:3e:aa:bb:cc (on wlan0)"
    echo "  SSID: labnet"
    echo "  freq: 2437"
    echo "  RX: 124321 bytes (932 pkts)  TX: 118776 bytes (884 pkts)"
    echo "  signal: -47 dBm"
    echo

    echo "  Step 5: Join the staging wireless by setting the ESSID on wlan0 to 'labnet'."
    read -p "  lab@lab132:~$ " cmd5
    echo
    [[ "$cmd5" != "iwconfig wlan0 essid labnet" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 6: Before joining, scan for nearby wireless networks using wlan0."
    read -p "  lab@lab132:~$ " cmd6
    echo
    [[ "$cmd6" != "iwlist wlan0 scan" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  wlan0     Scan completed :"
    echo "            Cell 01 - Address: 00:16:3E:AA:BB:CC"
    echo "                      ESSID:\"labnet\""
    echo "                      Channel:6  Quality=66/70  Signal level=-44 dBm"
    echo "            Cell 02 - Address: 00:16:3E:DD:EE:FF"
    echo "                      ESSID:\"guest\""
    echo "                      Channel:11 Quality=52/70  Signal level=-58 dBm"
    echo

    echo "  Step 7: You are exposing an internal time service. State the protocol/port pair that must be allowed inbound."
    read -p "  lab@lab132:~$ " cmd7
    echo
    [[ "$cmd7" != "udp/123" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 8: A tunnel requires a smaller frame size. Set the MTU on eth0 to 1400."
    read -p "  lab@lab132:~$ " cmd8
    echo
    [[ "$cmd8" != "ifconfig eth0 mtu 1400" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 9: For a lab demo, create a static ARP entry mapping 192.168.1.70 to 02:aa:bb:cc:dd:ee."
    read -p "  lab@lab132:~$ " cmd9
    echo
    [[ "$cmd9" != "arp -s 192.168.1.70 02:aa:bb:cc:dd:ee" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 10: Investigate socket memory usage on this host."
    read -p "  lab@lab132:~$ " cmd10
    echo
    [[ "$cmd10" != "ss -m" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port"
    echo "  tcp   ESTAB      0      0  192.168.1.100:ssh  192.168.1.50:51234"
    echo "        skmem:(r0,rb131072,t0,tb131072,f0,w0,o0,bl0)"
    echo

    print_success "Nice work!"
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
