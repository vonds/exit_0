#!/bin/bash

# Lab 64: SSH Keys - Access Remote Server without Password

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 64: SSH Keys - Access Remote Server without Password"
LAB_ID="lab64"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

REMOTE_USER="labuser"
REMOTE_IP="192.168.1.50"
KEY_FILE="$HOME/.ssh/id_rsa.pub"

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
    center_text "Scenario: You're frequently connecting to a remote server and want to set up"
    center_text "SSH key-based authentication to avoid typing your password each time."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Generate an SSH key pair."
    read -p "  lab@lpic-lab64:~$ " cmd1
    echo
    if [[ "$cmd1" != "ssh-keygen -t rsa" ]]; then
        print_error "Incorrect. Use 'ssh-keygen -t rsa'."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating public/private rsa key pair."
    echo "  Enter file in which to save the key (/home/lab/.ssh/id_rsa):"
    echo "  Created key at $KEY_FILE"
    echo

    echo "  Step 2: Copy the public key to the remote server."
    read -p "  lab@lpic-lab64:~$ " cmd2
    echo
    if [[ "$cmd2" != "ssh-copy-id $REMOTE_USER@$REMOTE_IP" ]]; then
        print_error "Incorrect. Use 'ssh-copy-id $REMOTE_USER@$REMOTE_IP'."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /usr/bin/ssh-copy-id: INFO: Source of key: $KEY_FILE"
    echo "  Number of key(s) added: 1"
    echo "  Now try logging into the machine, with:"
    echo "    ssh $REMOTE_USER@$REMOTE_IP"
    echo

    echo "  Step 3: Log into the remote server using your private key."
    read -p "  lab@lpic-lab64:~$ " cmd3
    echo
    if [[ "$cmd3" != "ssh $REMOTE_USER@$REMOTE_IP" ]]; then
        print_error "Incorrect. Use 'ssh $REMOTE_USER@$REMOTE_IP'."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Welcome to $REMOTE_IP. No password required."
    echo

    echo "  Step 4: Exit the SSH session."
    read -p "  $REMOTE_USER@$REMOTE_IP:~$ " cmd4
    echo
    if [[ "$cmd4" != "exit" ]]; then
        print_error "Incorrect. Use 'exit' to leave the remote session."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Connection to $REMOTE_IP closed."
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
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
