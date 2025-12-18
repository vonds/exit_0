#!/bin/bash

# Lab 340: A+ Networking Fundamentals (10 Questions, Set 5)
# Focus: Public IPv4s, SMB/445, CIFS, IPv6 truths, DNS A/TXT, IPv6 loopback,
#        Toner probe, DHCP, Switch behavior

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 340: A+ Section 2"
LAB_ID="lab340"
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

    # Q1: Public IPv4 addresses (choose two)
    draw_lab_ui
    echo "  Which TWO of the following are public IPv4 addresses?"
    echo "  69.252.80.71, 144.160.155.40, 172.20.10.11, 169.254.1.100"
    read -p "  lab@lab340:~$ " cmd1
    echo
    if [[ "$cmd1" != "69.252.80.71 and 144.160.155.40" && "$cmd1" != "144.160.155.40 and 69.252.80.71" \
       && "$cmd1" != "69.252.80.71, 144.160.155.40" && "$cmd1" != "144.160.155.40, 69.252.80.71" ]]; then
        print_error "Incorrect. The correct pair is: 69.252.80.71 and 144.160.155.40."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 69.252.80.71 and 144.160.155.40"
    echo

    # Q2: Port 445 protocol
    echo "  Which TCP/IP protocol uses port 445?"
    read -p "  lab@lab340:~$ " cmd2
    echo
    if [[ "$cmd2" != "SMB" && "$cmd2" != "smb" && "$cmd2" != "Server Message Block" ]]; then
        print_error "Incorrect. The correct answer is: SMB."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SMB"
    echo

    # Q3: Old SMB rendition no longer often used
    echo "  What rendition of SMB was widely used by Windows/NAS but is no longer often used?"
    read -p "  lab@lab340:~$ " cmd3
    echo
    if [[ "$cmd3" != "CIFS" && "$cmd3" != "cifs" && "$cmd3" != "Common Internet File System" ]]; then
        print_error "Incorrect. The correct answer is: CIFS."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: CIFS"
    echo

    # Q4: IPv6 truths 
    echo "  For IPv6, name BOTH true facts about its interfaces and communication."
    read -p "  lab@lab340:~$ " cmd4
    echo
    if [[ "$cmd4" != "link-local required no broadcasts" \
        && "$cmd4" != "link-local no broadcasts" \
        && "$cmd4" != "no broadcasts link-local" \
        && "$cmd4" != "link-local unicast no broadcast" ]]; then
        print_error "Incorrect. Expected: link-local required + no broadcasts."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: link-local required + no broadcasts"
    echo


    # Q5: DNS record for IPv4 resolution
    echo "  In DNS, which record type resolves a domain name to an IPv4 address?"
    read -p "  lab@lab340:~$ " cmd5
    echo
    if [[ "$cmd5" != "A" && "$cmd5" != "a" && "$cmd5" != "A record" && "$cmd5" != "a record" ]]; then
        print_error "Incorrect. The correct answer is: A (A record)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: A record"
    echo

    # Q6: DNS entry for verification bits / updates info
    echo "  Which DNS record type can store verification lines or update info for a domain?"
    read -p "  lab@lab340:~$ " cmd6
    echo
    if [[ "$cmd6" != "TXT" && "$cmd6" != "txt" && "$cmd6" != "TXT record" && "$cmd6" != "txt record" ]]; then
        print_error "Incorrect. The correct answer is: TXT."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: TXT record"
    echo

    # Q7: IPv6 loopback equivalent to 127.0.0.1
    echo "  Which IPv6 address is equivalent to IPv4 127.0.0.1?"
    read -p "  lab@lab340:~$ " cmd7
    echo
    if [[ "$cmd7" != "::1" ]]; then
        print_error "Incorrect. The correct answer is: ::1."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: ::1"
    echo

    # Q8: Identify which cable goes to which workstation (unlabeled panel)
    echo "  Patch panel cables are unlabeled. Which tool lets you identify which cable goes to which workstation?"
    read -p "  lab@lab340:~$ " cmd8
    echo
    if [[ "$cmd8" != "Toner probe" && "$cmd8" != "toner probe" && "$cmd8" != "Tone generator and probe" && "$cmd8" != "tone generator and probe" && "$cmd8" != "Toner" && "$cmd8" != "toner" ]]; then
        print_error "Incorrect. The correct answer is: Toner probe (Tone generator and probe)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Toner probe"
    echo

    # Q9: Protocol assigning IPs dynamically
    echo "  Which protocol dynamically assigns IP addresses to clients?"
    read -p "  lab@lab340:~$ " cmd9
    echo
    if [[ "$cmd9" != "DHCP" && "$cmd9" != "dhcp" && "$cmd9" != "Dynamic Host Configuration Protocol" && "$cmd9" != "dynamic host configuration protocol" ]]; then
        print_error "Incorrect. The correct answer is: DHCP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DHCP"
    echo

    # Q10: Device with per-port collision domains, forwards by MAC
    echo "  Which device has multiple ports (each its own collision domain) and forwards based on MAC addresses?"
    read -p "  lab@lab340:~$ " cmd10
    echo
    if [[ "$cmd10" != "Switch" && "$cmd10" != "switch" ]]; then
        print_error "Incorrect. The correct answer is: Switch."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Switch"
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
