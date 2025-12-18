#!/bin/bash

# Lab 310: Examining TCP/UDP Ports and Services – Objective 109.1
# LPIC-1 Focus: Well-known ports, /etc/services file, TCP vs UDP mappings, and SSL/TLS distinctions.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 310: TCP/UDP Ports & Services"
LAB_ID="lab310"
LAB_XP=30500
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
    center_text "Explore TCP/UDP well-known ports, mappings, and /etc/services file."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    echo "  Step 1: Open the system's service-to-port mapping file for viewing."
    read -p "  lab@net-lab310:~$ " cmd1
    echo
    [[ "$cmd1" != "cat /etc/services" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  # Network services, Internet style"
    echo "  ftp-data        20/tcp"
    echo "  ftp             21/tcp"
    echo "  ssh             22/tcp"
    echo "  telnet          23/tcp"
    echo "  smtp            25/tcp"
    echo "  domain          53/tcp"
    echo "  domain          53/udp"
    echo "  http            80/tcp"
    echo "  pop3            110/tcp"
    echo "  https           443/tcp"
    echo

    echo "  Step 2: Search the services database for web traffic entries."
    read -p "  lab@net-lab310:~$ " cmd2
    echo
    [[ "$cmd2" != "grep -i http /etc/services" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  http            80/tcp          www     # WorldWideWeb HTTP"
    echo "  https           443/tcp                 # http protocol over TLS/SSL"
    echo

    echo "  Step 3: Name the organization that manages official port assignments."
    read -p "  lab@net-lab310:~$ " cmd3
    echo
    [[ "$cmd3" != "IANA" && "$cmd3" != "iana" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Provide the two well-known ports for FTP (control and data), concisely."
    read -p "  lab@net-lab310:~$ " cmd4
    echo
    [[ "$cmd4" != "20 and 21" && "$cmd4" != "20,21" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 5: Provide the default port number used by SSH."
    read -p "  lab@net-lab310:~$ " cmd5
    echo
    [[ "$cmd5" != "22" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 6: Locate and display entries for the POP3 service in the mapping file."
    read -p "  lab@net-lab310:~$ " cmd6
    echo
    [[ "$cmd6" != "grep -i pop3 /etc/services" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  pop3            110/tcp                # Post Office Protocol v3"
    echo "  pop3s           995/tcp                # POP3 over SSL/TLS"
    echo

    echo "  Step 7: Provide the port number commonly used for SMTPS."
    read -p "  lab@net-lab310:~$ " cmd7
    echo
    [[ "$cmd7" != "465" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 8: Name the transport-layer protocol that replaced SSL for encryption."
    read -p "  lab@net-lab310:~$ " cmd8
    echo
    [[ "$cmd8" != "TLS" && "$cmd8" != "tls" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 9: Provide the port number used by LDAP over SSL/TLS."
    read -p "  lab@net-lab310:~$ " cmd9
    echo
    [[ "$cmd9" != "636" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 10: Provide the standard port number used by LDAP."
    read -p "  lab@net-lab310:~$ " cmd10
    echo
    [[ "$cmd10" != "389" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 11: Provide the full path of the file that maps services to port numbers."
    read -p "  lab@net-lab310:~$ " cmd11
    echo
    [[ "$cmd11" != "/etc/services" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 12: Search that mapping file for the entry corresponding to the SSH service."
    read -p "  lab@net-lab310:~$ " cmd12
    echo
    [[ "$cmd12" != "grep ssh /etc/services" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ssh             22/tcp                 # Secure Shell Login"
    echo

    echo "  Step 13: Answer whether TCP and UDP share the same service on port 514."
    read -p "  lab@net-lab310:~$ " cmd13
    echo
    [[ "$cmd13" != "no" && "$cmd13" != "No" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 14: Name the protocol associated with port 123."
    read -p "  lab@net-lab310:~$ " cmd14
    echo
    [[ "$cmd14" != "NTP" && "$cmd14" != "ntp" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 15: Provide the UDP port number used by DNS queries."
    read -p "  lab@net-lab310:~$ " cmd15
    echo
    [[ "$cmd15" != "53" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    print_success "Excellent work!"
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
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
