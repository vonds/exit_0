#!/bin/bash

# Lab 62: SSH and Telnet - Remote Access Tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 62: SSH and Telnet - Remote Access"
LAB_ID="lab62"
LAB_XP=19000
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

REMOTE_HOST="192.168.0.42"
TELNET_PORT="23"

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "You're working remotely and need to access a legacy and modern server."
    center_text "Use SSH and Telnet to test connections and basic functionality."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Connect to a remote server using SSH as user 'admin'."
    read -p "  lab@lpic-lab62:~\$ " cmd1
    echo
    [[ "$cmd1" != "ssh admin@$REMOTE_HOST" ]] && {
        print_error "Incorrect. Use: ssh admin@$REMOTE_HOST"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  The authenticity of host '$REMOTE_HOST' can't be established."
    echo "  ECDSA key fingerprint is SHA256:examplekey."
    echo "  Are you sure you want to continue connecting (yes/no/[fingerprint])?"

    read -p "  > " confirm
    [[ "$confirm" != "yes" ]] && {
        print_error "You must accept the fingerprint to continue."
        read -p "Press Enter to try again..." _
        continue
    }
    echo
    echo "  Warning: Permanently added '$REMOTE_HOST' (ECDSA) to the list of known hosts."
    echo
    echo "  admin@$REMOTE_HOST's password:"
    echo "  Welcome to remote server."

    echo
    echo "  Step 2: Exit the SSH session."
    read -p "  admin@$REMOTE_HOST:~\$ " cmd2
    [[ "$cmd2" != "exit" ]] && {
        print_error "Incorrect. Use: exit"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connection closed."

    echo
    echo "  Step 3: Connect to a legacy server using Telnet on port 23."
    read -p "  lab@lpic-lab62:~\$ " cmd3
    [[ "$cmd3" != "telnet $REMOTE_HOST $TELNET_PORT" ]] && {
        print_error "Incorrect. Use: telnet $REMOTE_HOST $TELNET_PORT"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Trying $REMOTE_HOST..."
    echo "  Connected to $REMOTE_HOST."
    echo "  Escape character is '^]'."
    echo "  Welcome to Legacy Server."
    echo

    echo "  Step 4: Close the Telnet session."
    read -p "  > " cmd4
    [[ "$cmd4" != "quit" && "$cmd4" != "exit" ]] && {
        print_error "Incorrect. Use: quit or exit"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connection closed by foreign host."
    echo

    print_success "Excellent! You completed the remote connection tasks."
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
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
