#!/bin/bash

# Lab 59: NIC Information and Diagnostics with ethtool

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 59: NIC Information and Diagnostics with ethtool"
LAB_ID="lab59"
LAB_XP=7170
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

INTERFACE="enp0s3"

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
    center_text "Scenario: You're performing diagnostics on a suspected faulty NIC."
    center_text "Your task is to collect and review interface hardware settings using ethtool."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View detailed information for the interface '$INTERFACE'."
    read -p "  lab@lpic-lab59:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo ethtool $INTERFACE" ]] && {
        print_error "Incorrect. Use sudo ethtool $INTERFACE to view details."
        read -p "Press Enter to try again..." _
        continue
    }

    # Realistic 'ethtool enp0s3' output
    echo "  Settings for $INTERFACE:"
    echo "          Supported ports: [ TP ]"
    echo "          Supported link modes:   10baseT/Half 10baseT/Full"
    echo "                                  100baseT/Half 100baseT/Full"
    echo "                                  1000baseT/Full"
    echo "          Supported pause frame use: Symmetric Receive-only"
    echo "          Supports auto-negotiation: Yes"
    echo "          Advertised link modes:  10baseT/Half 10baseT/Full"
    echo "                                  100baseT/Half 100baseT/Full"
    echo "                                  1000baseT/Full"
    echo "          Advertised pause frame use: Symmetric Receive-only"
    echo "          Advertised auto-negotiation: Yes"
    echo "          Speed: 1000Mb/s"
    echo "          Duplex: Full"
    echo "          Port: Twisted Pair"
    echo "          PHYAD: 1"
    echo "          Transceiver: internal"
    echo "          Auto-negotiation: on"
    echo "          MDI-X: Unknown"
    echo "          Link detected: yes"
    echo

    echo "  Step 2: Check the current link status."
    read -p "  lab@lpic-lab59:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo ethtool $INTERFACE | grep 'Link detected'" ]] && {
        print_error "Incorrect. Use grep 'Link detected' to filter the link status."
        read -p "Press Enter to try again..." _
        continue
    }

    # Realistic filtered output
    echo "  Link detected: yes"
    echo

    echo "  Step 3: Retrieve supported and advertised link modes."
    read -p "  lab@lpic-lab59:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo ethtool $INTERFACE | grep -A 10 'Supported link modes'" ]] && {
        print_error "Incorrect. Use grep -A 10 to view supported link modes."
        read -p "Press Enter to try again..." _
        continue
    }

    # Realistic 'grep -A 10 "Supported link modes"' slice
    echo "  Supported link modes:   10baseT/Half 10baseT/Full"
    echo "                          100baseT/Half 100baseT/Full"
    echo "                          1000baseT/Full"
    echo "  Supported pause frame use: Symmetric Receive-only"
    echo "  Supports auto-negotiation: Yes"
    echo "  Advertised link modes:  10baseT/Half 10baseT/Full"
    echo "                          100baseT/Half 100baseT/Full"
    echo "                          1000baseT/Full"
    echo "  Advertised pause frame use: Symmetric Receive-only"
    echo "  Advertised auto-negotiation: Yes"
    echo "  Speed: 1000Mb/s"
    echo "  Duplex: Full"
    echo

    echo "  Step 4: View interface statistics."
    read -p "  lab@lpic-lab59:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo ethtool -S $INTERFACE" ]] && {
        print_error "Incorrect. Use sudo ethtool -S $INTERFACE to view NIC statistics."
        read -p "Press Enter to try again..." _
        continue
    }

    # Realistic 'ethtool -S enp0s3' stats snapshot
    echo "  NIC statistics:"
    echo "       rx_packets: 124839"
    echo "       tx_packets: 118204"
    echo "       rx_bytes: 189234567"
    echo "       tx_bytes: 172004321"
    echo "       rx_broadcast: 214"
    echo "       tx_broadcast: 19"
    echo "       rx_multicast: 1538"
    echo "       tx_multicast: 0"
    echo "       rx_errors: 0"
    echo "       tx_errors: 0"
    echo "       rx_dropped: 3"
    echo "       tx_dropped: 0"
    echo "       rx_length_errors: 0"
    echo "       rx_crc_errors: 0"
    echo "       rx_frame_errors: 0"
    echo "       tx_aborted_errors: 0"
    echo "       tx_carrier_errors: 0"
    echo "       collisions: 0"
    echo "       tx_queue_0_packets: 118204"
    echo "       tx_queue_0_bytes: 172004321"
    echo

    print_success "Well done."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
