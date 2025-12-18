#!/bin/bash

# Lab 83: Linux Web-Based Administration (Cockpit)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 83: Linux Web-Based Administration (Cockpit)"
LAB_ID="lab83"
LAB_XP=2250
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
    center_text "Scenario: A team wants to manage Linux systems through a secure"
    center_text "web-based dashboard. Your task is to install and configure Cockpit."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the Cockpit web interface package."
    read -p "  lab@lpic-lab83:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install cockpit -y" && "$cmd1" != "sudo yum install cockpit -y" && "$cmd1" != "sudo dnf install cockpit -y" && "$cmd1" != "sudo pacman -S cockpit" ]] && {
        print_error "Incorrect. Try: sudo apt install cockpit -y (or pacman/yum/dnf depending on distro)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Cockpit package installed successfully."
    echo

    echo "  Step 2: Enable and start the Cockpit socket."
    read -p "  lab@lpic-lab83:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo systemctl enable --now cockpit.socket" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now cockpit.socket"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Cockpit socket is now active and enabled."
    echo

    echo "  Step 3: Open your browser and access Cockpit locally."
    read -p "  lab@lpic-lab83:~$ " cmd3
    echo
    [[ "$cmd3" != "xdg-open https://localhost:9090" && "$cmd3" != "firefox https://localhost:9090" && "$cmd3" != "chromium https://localhost:9090" ]] && {
        print_error "Incorrect. You must open https://localhost:9090 in your browser."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Cockpit login page opened in your browser."
    echo

    echo "  Step 4: From the terminal, verify that Cockpit is listening on port 9090."
    read -p "  lab@lpic-lab83:~$ " cmd4
    echo
    [[ "$cmd4" != "ss -tuln | grep 9090" ]] && {
        print_error "Incorrect. Use: ss -tuln | grep 9090"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Netid State  Recv-Q Send-Q Local Address:Port   Peer Address:Port"
    echo "  tcp   LISTEN 0      128    0.0.0.0:9090        0.0.0.0:*"
    echo "  tcp   LISTEN 0      128       [::]:9090           [::]:*"
    echo "  Cockpit is listening on port 9090."
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
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
