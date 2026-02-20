#!/bin/bash

# Lab 21b: SSH Host Security & Key-Based Auth

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 21b: SSH Host Security & Key-Based Auth"
LAB_ID="lab21b"
LAB_XP=3200
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
    # Robust increment even if key is missing
    jq --arg lab "$LAB_ID" '.[$lab] = ((.[$lab] // 0) + 1)' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "You're tasked with configuring SSH for key-based login and hardening settings."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command generates an ed25519 SSH key for alice with comment 'alice@test'?"
    read -p "  lab@lpic-lab21b:~$ > " cmd1
    echo

    if [[ "$cmd1" != "ssh-keygen -t ed25519 -C 'alice@test'" && "$cmd1" != "ssh-keygen -t ed25519 -C \"alice@test\"" ]]; then
        print_error "Incorrect. Use: ssh-keygen -t ed25519 -C 'alice@test'"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Generating public/private ed25519 key pair..."
    echo "  Your identification has been saved in /home/alice/.ssh/id_ed25519"
    echo "  Your public key has been saved in /home/alice/.ssh/id_ed25519.pub"
    echo

    echo "  Step 2: What command copies alice's public key to host 'server'?"
    read -p "  lab@lpic-lab21b:~$ > " cmd2
    echo

    if [[ "$cmd2" != "ssh-copy-id alice@server" ]]; then
        print_error "Incorrect. Use: ssh-copy-id alice@server"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Key copied successfully. Alice can now log in without a password."
    echo

    echo "  Step 3: What sshd_config option disables root logins?"
    read -p "  lab@lpic-lab21b:~$ > " cmd3
    echo

    if [[ "$cmd3" != "PermitRootLogin no" ]]; then
        print_error "Incorrect. Answer: PermitRootLogin no"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Root logins disabled."
    echo

    echo "  Step 4: What sshd_config options disable password logins and allow only user alice?"
    read -p "  lab@lpic-lab21b:~$ > " cmd4
    echo

    if [[ "$cmd4" != "PasswordAuthentication no" && "$cmd4" != "AllowUsers alice" ]]; then
        print_error "Incorrect. Provide: PasswordAuthentication no and AllowUsers alice"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Password authentication disabled, only alice allowed."
    echo

    echo "  Step 5: What commands set SSH port 2222, reload sshd, and verify PermitRootLogin?"
    read -p "  lab@lpic-lab21b:~$ > " cmd5
    echo

    if [[ "$cmd5" != "Port 2222" && "$cmd5" != "sudo systemctl reload sshd" && "$cmd5" != "sshd -T | grep permitrootlogin" ]]; then
        print_error "Expected sequence: Port 2222, then sudo systemctl reload sshd, then sshd -T | grep permitrootlogin"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Port set to 2222, sshd reloaded, verified permitrootlogin=no."
    echo

    print_success "Excellent!"
    print_info "You configured SSH for key-only access, disabled root and password logins,"
    print_info "restricted access to alice, changed the port, and verified settings."
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
    else
        # any other input repeats the lab
        continue
    fi
done
