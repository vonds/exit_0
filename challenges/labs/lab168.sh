#!/bin/bash

# Lab Security 6: Bonus Odds & Ends (covers remaining MCQs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Security 6: Bonus Odds & Ends"
LAB_ID="lab_sec_6"
LAB_XP=28400
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
    center_text "Small but important commands and facts from the set."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Run a single command via su without an interactive session."
    read -p "  lab@security-6:~$ " cmd1
    echo
    [[ "$cmd1" != "su -c 'date'" ]] && {
        print_error "Use: su -c 'command'"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (command executed under su)"
    echo

    echo "  Step 2: Unlock a locked account with passwd."
    read -p "  lab@security-6:~$ " cmd2
    echo
    [[ "$cmd2" != "passwd -u user" ]] && {
        print_error "Use: passwd -u USER"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Account unlocked."
    echo

    echo "  Step 3: Expire an account based on days since epoch using chage."
    read -p "  lab@security-6:~$ " cmd3
    echo
    [[ "$cmd3" != "chage -E 20000 user" && "$cmd3" != "chage -E 2025-12-31 user" ]] && {
        print_error "Use: chage -E <days|YYYY-MM-DD> USER"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Expiration applied."
    echo

    echo "  Step 4: Generate an RSA SSH key (explicit type)."
    read -p "  lab@security-6:~$ " cmd4
    echo
    [[ "$cmd4" != "ssh-keygen -t rsa" ]] && {
        print_error "Use: ssh-keygen -t rsa"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  RSA key generated."
    echo

    echo "  Step 5: Add multiple-choice remnant — state the ssh option for X11 (echo flag)."
    read -p "  lab@security-6:~$ " cmd5
    echo
    [[ "$cmd5" != "echo -X" ]] && {
        print_error "Echo: -X"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -X"
    echo

    echo "  Step 6: State the file used to show a message when nologin is active."
    read -p "  lab@security-6:~$ " cmd6
    echo
    [[ "$cmd6" != "echo /etc/nologin" ]] && {
        print_error "Echo: /etc/nologin"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /etc/nologin"
    echo

    echo "  Step 7: Show how to set NOPASSWD for a command (echo the token)."
    read -p "  lab@security-6:~$ " cmd7
    echo
    [[ "$cmd7" != "echo NOPASSWD" ]] && {
        print_error "Echo: NOPASSWD"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  NOPASSWD"
    echo

    echo "  Step 8: Indicate how to connect with a different login (echo the ssh flag)."
    read -p "  lab@security-6:~$ " cmd8
    echo
    [[ "$cmd8" != "echo -l" ]] && {
        print_error "Echo: -l"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -l"
    echo

    echo "  Step 9: Name the sudo group specifier prefix used in sudoers (echo it)."
    read -p "  lab@security-6:~$ " cmd9
    echo
    [[ "$cmd9" != "echo %admins" ]] && {
        print_error "Echo: %admins"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  %admins"
    echo

    echo "  Step 10: In hosts.allow wildcard set, echo the keyword that matches all."
    read -p "  lab@security-6:~$ " cmd10
    echo
    [[ "$cmd10" != "echo ALL" ]] && {
        print_error "Echo: ALL"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ALL"
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
