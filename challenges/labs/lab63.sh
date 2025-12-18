#!/bin/bash

# Lab 63: Configure and Secure SSH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 63: Configure and Secure SSH"
LAB_ID="lab63"
LAB_XP=23000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SSHD_CONFIG="/etc/ssh/sshd_config"

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
    center_text "Scenario: You are tasked with hardening SSH access on a production server."
    center_text "You'll modify the SSH daemon configuration file to enforce secure policies."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Open the SSH daemon config file for editing."
    read -p "  lab@lpic-lab63:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo nano $SSHD_CONFIG" && "$cmd1" != "sudo vim $SSHD_CONFIG" ]]; then
        print_error "Incorrect. Open $SSHD_CONFIG using nano or vim."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Configuration file opened."
    echo

    echo "  Step 2: Disable root login."
    read -p "  lab@lpic-lab63:~$ " cmd2
    echo
    if [[ "$cmd2" != "PermitRootLogin no" ]]; then
        print_error "Incorrect. Enter exactly: PermitRootLogin no"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Root login disabled."
    echo

    echo "  Step 3: Limit SSH to protocol version 2 only."
    read -p "  lab@lpic-lab63:~$ " cmd3
    echo
    if [[ "$cmd3" != "Protocol 2" ]]; then
        print_error "Incorrect. Enter exactly: Protocol 2"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Protocol version set to 2."
    echo

    echo "  Step 4: Change the default SSH port to 2222."
    read -p "  lab@lpic-lab63:~$ " cmd4
    echo
    if [[ "$cmd4" != "Port 2222" ]]; then
        print_error "Incorrect. Enter exactly: Port 2222"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  SSH port changed to 2222."
    echo

    echo "  Step 5: Restart the SSH service to apply changes."
    read -p "  lab@lpic-lab63:~$ " cmd5
    echo
    if [[ "$cmd5" != "sudo systemctl restart sshd" ]]; then
        print_error "Incorrect. Use: sudo systemctl restart sshd"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  SSH service restarted successfully."
    echo

    echo "  Step 6: Verify SSH is listening on port 2222."
    read -p "  lab@lpic-lab63:~$ " cmd6
    echo
    if [[ "$cmd6" != "sudo netstat -tuln | grep 2222" && "$cmd6" != "ss -tuln | grep 2222" ]]; then
        print_error "Incorrect. Use: sudo netstat -tuln | grep 2222 or ss -tuln | grep 2222"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Active Internet connections (only servers)"
    echo "  Proto Recv-Q Send-Q Local Address           Foreign Address         State"
    echo "  tcp        0      0 0.0.0.0:2222           0.0.0.0:*               LISTEN"
    echo "  tcp6       0      0 :::2222                :::*                    LISTEN"
    echo
    echo "  SSH confirmed to be listening on port 2222."
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
