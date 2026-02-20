#!/bin/bash

# Lab 4: Modify SSH Configuration Using sed (LPIC-1 Style)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 4: sed - SSH Config Hardening"
LAB_ID="lab4"
LAB_XP=1720
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
CONFIG_FILE="/tmp/sshd_config"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
}

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

prepare_config() {
    cat <<EOF > "$CONFIG_FILE"
    # SSH Daemon Configuration
    PermitRootLogin yes
    PasswordAuthentication yes
    Port 22
EOF
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Your task is to harden SSH settings using the sed command."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    prepare_config
    draw_lab_ui

    # --- NEW INTERACTIVE FIRST PART ---
    echo "  Step 1: View the current SSH daemon configuration."
    read -p "  lab@lpic-lab4:~$ " cmd1
    echo
    if [[ "$cmd1" != "cat /tmp/sshd_config" && "$cmd1" != "cat $CONFIG_FILE" ]]; then
        print_error "Incorrect. Run: cat /tmp/sshd_config"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  lab@lpic-lab4:~$ $cmd1"
    cat "$CONFIG_FILE"
    echo

    echo "  Step 2: Disable root login by modifying PermitRootLogin to 'no'"
    read -p "  lab@lpic-lab4:~$ " cmd2
    if [[ "$cmd2" != "sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /tmp/sshd_config" ]]; then
        print_error "Incorrect. Try again using sed substitution with the correct pattern."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 3: Disable password authentication by changing 'PasswordAuthentication yes' to 'no'"
    read -p "  lab@lpic-lab4:~$ " cmd3
    if [[ "$cmd3" != "sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /tmp/sshd_config" ]]; then
        print_error "Incorrect. Double check the exact syntax and try again."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 4: Change the default SSH port to 2222"
    read -p "  lab@lpic-lab4:~$ " cmd4
    if [[ "$cmd4" != "sed -i 's/^Port 22/Port 2222/' /tmp/sshd_config" ]]; then
        print_error "Incorrect. Use sed to match 'Port 22' and change it to 'Port 2222'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # Simulated result summary (kept from original)
    echo "  PermitRootLogin no"
    echo "  PasswordAuthentication no"
    echo "  Port 2222"
    echo 

    print_success "All configuration changes successfully applied!"
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    record_lab_completion

    echo
    completion_count=$(get_lab_completion_count)
    print_info "You've completed this lab $completion_count time(s)."
    echo

    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
