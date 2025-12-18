#!/bin/bash

# Lab 85: Setting Up a Central Logging Server (rsyslog)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 85: Central Logging with rsyslog"
LAB_ID="lab85"
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
    center_text "Scenario: Configure a Linux machine as a central logging server using rsyslog."
    center_text "The system will listen for logs over UDP port 514."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the rsyslog package."
    read -p "  lab@lpic-lab85:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install rsyslog -y" && "$cmd1" != "sudo dnf install rsyslog -y" && "$cmd1" != "sudo pacman -S rsyslog" ]] && {
        print_error "Incorrect. Try: sudo apt install rsyslog -y  (or dnf/pacman)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  rsyslog installed successfully."
    echo

    echo "  Step 2: Enable rsyslog to receive logs via UDP (514)."
    read -p "  lab@lpic-lab85:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo nano /etc/rsyslog.conf" && "$cmd2" != "sudo vim /etc/rsyslog.conf" ]] && {
        print_error "Incorrect. Open /etc/rsyslog.conf with nano or vim to enable UDP input modules."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  You uncommented or added the lines:"
    echo "  module(load=\"imudp\")"
    echo "  input(type=\"imudp\" port=\"514\")"
    echo

    echo "  Step 3: Restart the rsyslog service."
    read -p "  lab@lpic-lab85:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo systemctl restart rsyslog" ]] && {
        print_error "Incorrect. Use: sudo systemctl restart rsyslog"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  rsyslog service restarted."
    echo

    echo "  Step 4: Verify rsyslog is listening on UDP port 514."
    read -p "  lab@lpic-lab85:~$ " cmd4
    echo
    [[ "$cmd4" != "ss -tuln | grep 514" ]] && {
        print_error "Incorrect. Use: ss -tuln | grep 514"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Output:"
    echo "  LISTEN 0      100       0.0.0.0:514        0.0.0.0:*"
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
