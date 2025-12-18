#!/bin/bash

# Lab 135: Networking Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 9"
LAB_ID="lab135"
LAB_XP=29500
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
    center_text "Work with networking fundamentals commands and concepts. (set 9)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Assign 192.168.1.1/24 to interface eth0 using iproute2."
    read -p "  lab@lab35:~$ " cmd1
    echo
    [[ "$cmd1" != "ip addr add 192.168.1.1/24 dev eth0" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 2: Display the system's current DNS resolver settings managed by systemd-resolved."
    read -p "  lab@lab35:~$ " cmd2
    echo
    [[ "$cmd2" != "resolvectl status" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Global"
    echo "        Current DNS Server: 1.1.1.1"
    echo "        DNSSEC setting: no"
    echo "  Link 2 (eth0)"
    echo "        Current DNS Server: 192.168.1.1"
    echo "        DNS Domain: example.local"
    echo

    echo "  Step 3: Enable centralized interface management with NetworkManager on this host."
    read -p "  lab@lab35:~$ " cmd3
    echo
    [[ "$cmd3" != "nmcli networking on" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 4: A dig query returned status: NXDOMAIN. Briefly state what NXDOMAIN means."
    read -p "  lab@lab35:~$ " cmd4
    echo
    [[ "$cmd4" != "domain not found" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 5: Name the systemd daemon responsible for managing network interfaces natively."
    read -p "  lab@lab35:~$ " cmd5
    echo
    [[ "$cmd5" != "systemd-networkd" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 6: Set the static hostname of this machine to edge-node-1 using the appropriate tool."
    read -p "  lab@lab35:~$ " cmd6
    echo
    [[ "$cmd6" != "hostnamectl set-hostname edge-node-1" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 7: State the default protocol/port pair used by IMAP over SSL."
    read -p "  lab@lab35:~$ " cmd7
    echo
    [[ "$cmd7" != "tcp/993" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 8: Show interface addresses without name resolution to simplify parsing."
    read -p "  lab@lab35:~$ " cmd8
    echo
    [[ "$cmd8" != "ip -n addr" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  2: eth0    inet 192.168.1.1/24 brd 192.168.1.255 scope global eth0"
    echo "             valid_lft forever preferred_lft forever"
    echo "  1: lo      inet 127.0.0.1/8 scope host lo"
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
