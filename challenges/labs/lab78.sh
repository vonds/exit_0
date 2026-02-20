#!/bin/bash

# Lab 78: Managing Time with timedatectl

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 78: Managing Time with timedatectl"
LAB_ID="lab78"
LAB_XP=2200
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
    center_text "Scenario: You need to manage and inspect your system clock settings."
    center_text "You will use the 'timedatectl' utility to view and configure time and NTP settings."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Display the current system time and date settings."
    read -p "  lab@lpic-lab79:~$ " cmd1
    echo
    [[ "$cmd1" != "timedatectl" ]] && {
        print_error "Incorrect. Use: timedatectl"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "                 Local time: Tue 2025-07-29 09:34:15 EDT"
    echo "             Universal time: Tue 2025-07-29 13:34:15 UTC"
    echo "                   RTC time: Tue 2025-07-29 13:34:14"
    echo "                  Time zone: America/New_York (EDT, -0400)"
    echo "  System clock synchronized: yes"
    echo "                NTP service: active"
    echo "            RTC in local TZ: no"
    echo

    echo "  Step 2: Change the system time zone to UTC."
    read -p "  lab@lpic-lab79:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo timedatectl set-timezone UTC" ]] && {
        print_error "Incorrect. Use: sudo timedatectl set-timezone UTC"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Time zone set to UTC."
    echo

    echo "  Step 3: Turn off NTP time synchronization."
    read -p "  lab@lpic-lab79:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo timedatectl set-ntp false" ]] && {
        print_error "Incorrect. Use: sudo timedatectl set-ntp false"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  NTP synchronization disabled."
    echo

    echo "  Step 4: Manually set the system time to 10:00:00."
    read -p "  lab@lpic-lab79:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo timedatectl set-time 10:00:00" ]] && {
        print_error "Incorrect. Use: sudo timedatectl set-time 10:00:00"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Time set to 10:00:00."
    echo

    echo "  Step 5: Re-enable NTP time synchronization."
    read -p "  lab@lpic-lab79:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo timedatectl set-ntp true" ]] && {
        print_error "Incorrect. Use: sudo timedatectl set-ntp true"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  NTP synchronization re-enabled."
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
