#!/bin/bash

# Lab 15: Manage User Accounts and Password Policies

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 15: Manage User Accounts and Password Policies"
LAB_ID="lab15"
LAB_XP=3300
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

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "A new intern has joined your company. You're tasked with"
    center_text "creating their user account, setting default permissions,"
    center_text "applying password expiration policies, and verifying them."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command creates a new user named 'intern'?"
    read -p "  lab@lpic-lab15:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "sudo useradd intern" ]]; then
        print_error "Incorrect. Hint: Use 'useradd' with no home or shell options for now."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  User 'intern' created."
    echo

    echo "  Step 2: What command sets the password for the 'intern' user?"
    read -p "  lab@lpic-lab15:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "sudo passwd intern" ]]; then
        print_error "Incorrect. Hint: Use the passwd command with sudo."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Enter new UNIX password:"
    echo "  Retype new UNIX password:"
    echo "  passwd: password updated successfully"
    echo

    echo "  Step 3: What command forces the user to change their password on first login?"
    read -p "  lab@lpic-lab15:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "sudo chage -d 0 intern" ]]; then
        print_error "Incorrect. Hint: Use chage with -d 0 to expire the password."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Password expiration set. User must change password on next login."
    echo

    echo "  Step 4: What command displays account aging information for 'intern'?"
    read -p "  lab@lpic-lab15:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "chage -l intern" ]]; then
        print_error "Incorrect. Hint: Use 'chage -l' to list aging info."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Last password change                                    : Jul 18, 2025"
    echo "  Password expires                                        : Aug 17, 2025"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : never"
    echo "  Minimum number of days between password change          : 0"
    echo "  Maximum number of days between password change          : 30"
    echo "  Number of days of warning before password expires       : 7"
    echo

    echo "  Step 5: What file defines default values for new accounts?"
    read -p "  lab@lpic-lab15:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "/etc/login.defs" ]]; then
        print_error "Incorrect. Hint: This file contains UID/GID and password policy defaults."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Default account policies defined in /etc/login.defs"
    echo

    print_success "Outstanding!"
    print_info "You successfully created a user account, enforced secure defaults,"
    print_info "and verified password expiration and account configuration."
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
