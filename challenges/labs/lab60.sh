#!/bin/bash

# Lab 60: Basic Static IPv4 Setup & Connectivity Test (LPIC-1)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 60: Basic Static IPv4 Setup & Connectivity Test"
LAB_ID="lab60"
LAB_XP=18000
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
    center_text "Scenario: Configure enp1s0 with a static IPv4 and verify connectivity."
    center_text "Target: 192.168.50.10/24 with default gateway 192.168.50.1."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Assign 192.168.50.10/24 to enp1s0."
    read -p "  lab@lpic-lab60:~$ " cmd1
    if [[ "$cmd1" != "ip addr add 192.168.50.10/24 dev enp1s0" ]]; then
        print_error "Incorrect. Example: ip addr add 192.168.50.10/24 dev enp1s0"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 2: Bring enp1s0 up."
    read -p "  lab@lpic-lab60:~$ " cmd2
    if [[ "$cmd2" != "ip link set enp1s0 up" ]]; then
        print_error "Incorrect. Example: ip link set enp1s0 up"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 3: Add the default route via 192.168.50.1."
    read -p "  lab@lpic-lab60:~$ " cmd3
    if [[ "$cmd3" != "ip route add default via 192.168.50.1" ]]; then
        print_error "Incorrect. Example: ip route add default via 192.168.50.1"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 4: Verify connectivity with one ICMP echo."
    read -p "  lab@lpic-lab60:~$ " cmd4
    if [[ "$cmd4" != "ping -c 1 8.8.8.8" ]]; then
        print_error "Incorrect. Example: ping -c 1 8.8.8.8"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data."
    echo "  64 bytes from 8.8.8.8: icmp_seq=1 ttl=xx time=xx.x ms"
    echo
    echo "  --- 8.8.8.8 ping statistics ---"
    echo "  1 packets transmitted, 1 received, 0% packet loss, time xxms"
    echo "  rtt min/avg/max/mdev = xx.x/xx.x/xx.x/0.0 ms"
    echo

    print_success "Static IPv4 configured and connectivity verified."
    print_info "You earned $LAB_XP XP for completing this lab!"
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
