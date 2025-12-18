#!/bin/bash

# Lab 336: A+ Networking Fundamentals (10 Questions)
# Focus: Fiber testing, IMAP, DNS issues, SSH vs Telnet, Wi-Fi bandwidth features,
#        TCP vs UDP, Remote access/file mgmt, Fastest dual-band Wi-Fi, 5 GHz compatibility,
#        SMB file/print sharing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 336: A+ Section 2"
LAB_ID="lab336"
LAB_XP=18400
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
    center_text "Scenario: Review key A+ networking fundamentals — open-ended responses only."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1: Fiber testing before difficult run
    draw_lab_ui
    echo "  You’re installing fiber between buildings through a hard-to-access conduit."
    echo "  Before pulling the run, which tool should you use to ensure the cable works?"
    read -p "  lab@lab336:~$ " cmd1
    echo
    if [[ "$cmd1" != "Cable tester" && "$cmd1" != "cable tester" ]]; then
        print_error "Incorrect. The correct answer is: Cable tester."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Cable tester"
    echo

    # Q2: Email protocol with multiple clients on same mailbox
    echo "  Which email protocol lets multiple clients stay connected to the same mailbox?"
    read -p "  lab@lab336:~$ " cmd2
    echo
    if [[ "$cmd2" != "IMAP" && "$cmd2" != "imap" ]]; then
        print_error "Incorrect. The correct answer is: IMAP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IMAP"
    echo

    # Q3: Laptop can't reach Google; internals fine; phone via cellular works
    echo "  Your laptop on the company network can't open www.google.com, but internal servers"
    echo "  and printing work. Your phone on cellular opens Google fine. Most likely reason?"
    read -p "  lab@lab336:~$ " cmd3
    echo
    if [[ "$cmd3" != "DNS server problem" && "$cmd3" != "dns server problem" && "$cmd3" != "DNS" && "$cmd3" != "dns" ]]; then
        print_error "Incorrect. The correct answer is: DNS server problem."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DNS server problem"
    echo

    # Q4: Replacement for Telnet
    echo "  Which protocol was designed to replace Telnet?"
    read -p "  lab@lab336:~$ " cmd4
    echo
    if [[ "$cmd4" != "SSH" && "$cmd4" != "ssh" ]]; then
        print_error "Incorrect. The correct answer is: SSH."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SSH"
    echo

    # Q5: Feature that effectively doubles available bandwidth (ac/ax/be)
    echo "  What feature of 802.11ac/ax/be effectively doubles available bandwidth?"
    read -p "  lab@lab336:~$ " cmd5
    echo
    if [[ "$cmd5" != "QAM" && "$cmd5" != "qam" ]]; then
        print_error "Incorrect. The correct answer is: QAM."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: QAM"
    echo

    # Q6: Connection-oriented, attempts to guarantee delivery
    echo "  Which protocol is connection-oriented and attempts to guarantee delivery?"
    read -p "  lab@lab336:~$ " cmd6
    echo
    if [[ "$cmd6" != "TCP" && "$cmd6" != "tcp" ]]; then
        print_error "Incorrect. The correct answer is: TCP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: TCP"
    echo

    # Q7: Log in remotely and manage files as if local
    echo "  Which protocol lets a user log in to a remote computer and manage files as if local?"
    read -p "  lab@lab336:~$ " cmd7
    echo
    if [[ "$cmd7" != "RDP" && "$cmd7" != "rdp" && "$cmd7" != "Remote Desktop Protocol" && "$cmd7" != "remote desktop protocol" ]]; then
        print_error "Incorrect. The correct answer is: RDP (Remote Desktop Protocol)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: RDP"
    echo

    # Q8: Fastest Wi-Fi that operates in both 2.4 and 5 GHz
    echo "  Which Wi-Fi standard is the fastest and operates in both 2.4 and 5 GHz?"
    read -p "  lab@lab336:~$ " cmd8
    echo
    if [[ "$cmd8" != "802.11ax" && "$cmd8" != "Wi-Fi 6" && "$cmd8" != "Wi-Fi 6" && "$cmd8" != "wifi 6" && "$cmd8" != "802.11AX" ]]; then
        print_error "Incorrect. The correct answer is: 802.11ax (Wi-Fi 6)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.11ax (Wi-Fi 6)"
    echo

    # Q9: 5 GHz device can't join new LAN despite correct password
    echo "  A 5 GHz-only device can't connect to a new LAN despite the correct password."
    echo "  Which network type might cause this?"
    read -p "  lab@lab336:~$ " cmd9
    echo
    if [[ "$cmd9" != "802.11g" && "$cmd9" != "802.11G" ]]; then
        print_error "Incorrect. The correct answer is: 802.11g (2.4 GHz only)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.11g"
    echo

    # Q10: Protocol for shared access to files and printers
    echo "  Which protocol provides shared access to files and printers on a network?"
    read -p "  lab@lab336:~$ " cmd10
    echo
    if [[ "$cmd10" != "SMB" && "$cmd10" != "smb" ]]; then
        print_error "Incorrect. The correct answer is: SMB."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SMB"
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to A+ Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
