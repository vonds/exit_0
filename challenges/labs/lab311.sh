#!/bin/bash

# Lab 311: LPIC-1 Essential Ports and Service Acronyms – Objective 109.1
# LPIC-1 Focus: Required TCP/UDP port numbers and the meaning of their service acronyms.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 311: LPIC-1 Port Knowledge"
LAB_ID="lab311"
LAB_XP=31200
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
    center_text "Master LPIC-1 required ports and protocol acronyms."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui

    echo "  Step 1: What port does SSH use?"
    read -p "  lab@lab311:~$ " cmd1
    echo
    [[ "$cmd1" != "22" ]] && {
        print_error "Incorrect. SSH uses port 22/tcp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 2: What does SSH stand for?"
    read -p "  lab@lab311:~$ " cmd2
    echo
    [[ "$cmd2" != "Secure Shell" && "$cmd2" != "secure shell" ]] && {
        print_error "Incorrect. SSH stands for Secure Shell."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 3: What port does HTTP use?"
    read -p "  lab@lab311:~$ " cmd3
    echo
    [[ "$cmd3" != "80" ]] && {
        print_error "Incorrect. HTTP uses port 80/tcp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 4: What does HTTP stand for?"
    read -p "  lab@lab311:~$ " cmd4
    echo
    [[ "$cmd4" != "Hypertext Transfer Protocol" && "$cmd4" != "hypertext transfer protocol" ]] && {
        print_error "Incorrect. HTTP stands for Hypertext Transfer Protocol."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 5: What port does HTTPS use?"
    read -p "  lab@lab311:~$ " cmd5
    echo
    [[ "$cmd5" != "443" ]] && {
        print_error "Incorrect. HTTPS uses port 443/tcp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 6: What does HTTPS stand for?"
    read -p "  lab@lab311:~$ " cmd6
    echo
    [[ "$cmd6" != "Hypertext Transfer Protocol Secure" && "$cmd6" != "hypertext transfer protocol secure" ]] && {
        print_error "Incorrect. HTTPS stands for Hypertext Transfer Protocol Secure."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 7: What port does FTP use for control commands?"
    read -p "  lab@lab311:~$ " cmd7
    echo
    [[ "$cmd7" != "21" ]] && {
        print_error "Incorrect. FTP control uses port 21/tcp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 8: What does FTP stand for?"
    read -p "  lab@lab311:~$ " cmd8
    echo
    [[ "$cmd8" != "File Transfer Protocol" && "$cmd8" != "file transfer protocol" ]] && {
        print_error "Incorrect. FTP stands for File Transfer Protocol."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 9: What port does DNS use for UDP queries?"
    read -p "  lab@lab311:~$ " cmd9
    echo
    [[ "$cmd9" != "53" ]] && {
        print_error "Incorrect. DNS uses port 53 for both TCP and UDP."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 10: What does DNS stand for?"
    read -p "  lab@lab311:~$ " cmd10
    echo
    [[ "$cmd10" != "Domain Name System" && "$cmd10" != "domain name system" ]] && {
        print_error "Incorrect. DNS stands for Domain Name System."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 11: What port does SMTP use for standard mail transport?"
    read -p "  lab@lab311:~$ " cmd11
    echo
    [[ "$cmd11" != "25" ]] && {
        print_error "Incorrect. SMTP uses port 25/tcp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 12: What does SMTP stand for?"
    read -p "  lab@lab311:~$ " cmd12
    echo
    [[ "$cmd12" != "Simple Mail Transfer Protocol" && "$cmd12" != "simple mail transfer protocol" ]] && {
        print_error "Incorrect. SMTP stands for Simple Mail Transfer Protocol."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 13: What port does POP3 use?"
    read -p "  lab@lab311:~$ " cmd13
    echo
    [[ "$cmd13" != "110" ]] && {
        print_error "Incorrect. POP3 uses port 110/tcp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 14: What does POP3 stand for?"
    read -p "  lab@lab311:~$ " cmd14
    echo
    [[ "$cmd14" != "Post Office Protocol version 3" && "$cmd14" != "post office protocol version 3" ]] && {
        print_error "Incorrect. POP3 stands for Post Office Protocol version 3."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 15: What port does IMAP use?"
    read -p "  lab@lab311:~$ " cmd15
    echo
    [[ "$cmd15" != "143" ]] && {
        print_error "Incorrect. IMAP uses port 143/tcp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 16: What does IMAP stand for?"
    read -p "  lab@lab311:~$ " cmd16
    echo
    [[ "$cmd16" != "Internet Message Access Protocol" && "$cmd16" != "internet message access protocol" ]] && {
        print_error "Incorrect. IMAP stands for Internet Message Access Protocol."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 17: What port does NTP use?"
    read -p "  lab@lab311:~$ " cmd17
    echo
    [[ "$cmd17" != "123" ]] && {
        print_error "Incorrect. NTP uses port 123/udp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 18: What does NTP stand for?"
    read -p "  lab@lab311:~$ " cmd18
    echo
    [[ "$cmd18" != "Network Time Protocol" && "$cmd18" != "network time protocol" ]] && {
        print_error "Incorrect. NTP stands for Network Time Protocol."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 19: What port does LDAP use for standard queries?"
    read -p "  lab@lab311:~$ " cmd19
    echo
    [[ "$cmd19" != "389" ]] && {
        print_error "Incorrect. LDAP uses port 389/tcp and 389/udp."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 20: What does LDAP stand for?"
    read -p "  lab@lab311:~$ " cmd20
    echo
    [[ "$cmd20" != "Lightweight Directory Access Protocol" && "$cmd20" != "lightweight directory access protocol" ]] && {
        print_error "Incorrect. LDAP stands for Lightweight Directory Access Protocol."
        read -p "Press Enter to retry..." _
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
