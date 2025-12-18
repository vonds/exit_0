#!/bin/bash

# Lab 84: Setting Up a Proxy Server with Squid

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 84: Setting Up a Proxy Server with Squid"
LAB_ID="lab84"
LAB_XP=2500
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
    center_text "Scenario: Install and configure Squid as a basic proxy server for HTTP traffic."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the Squid proxy server."
    read -p "  lab@lpic-lab84:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install squid -y" && "$cmd1" != "sudo dnf install squid -y" && "$cmd1" != "sudo pacman -S squid" ]] && {
        print_error "Incorrect. Try: sudo apt install squid -y  (or dnf/pacman)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Squid package installed successfully."
    echo

    echo "  Step 2: Enable and start the Squid service."
    read -p "  lab@lpic-lab84:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo systemctl enable --now squid" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now squid"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Squid service is now active and enabled."
    echo

    echo "  Step 3: Test proxy port is open (default 3128)."
    read -p "  lab@lpic-lab84:~$ " cmd3
    echo
    [[ "$cmd3" != "ss -tuln | grep 3128" ]] && {
        print_error "Incorrect. Use: ss -tuln | grep 3128"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Output:"
    echo "  LISTEN 0      100        0.0.0.0:3128       0.0.0.0:*"
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
