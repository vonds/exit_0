#!/bin/bash

# Lab 97: Set up a basic NTP client with chronyd

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 97: Set up a basic NTP client with chronyd"
LAB_ID="lab97"
LAB_XP=2750
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
    center_text "Scenario: A server's clock is drifting and logs are out of order."
    center_text "Configure this host as an NTP client using chronyd and verify sync."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install chrony."
    read -p "  lab@lpic-lab97:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo dnf install chrony -y" && "$cmd1" != "sudo yum install chrony -y" ]] && {
        print_error "Incorrect. Use: sudo dnf install chrony -y"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  chrony installed."
    echo

    echo "  Step 2: Enable and start the chronyd service."
    read -p "  lab@lpic-lab97:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo systemctl enable --now chronyd" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now chronyd"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  chronyd enabled and started."
    echo

    echo "  Step 3: Check chronyd service status."
    read -p "  lab@lpic-lab97:~$ " cmd3
    echo
    [[ "$cmd3" != "systemctl status chronyd --no-pager" ]] && {
        print_error "Incorrect. Use: systemctl status chronyd --no-pager"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ● chronyd.service - NTP client/server"
    echo "     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled)"
    echo "     Active: active (running)"
    echo

    echo "  Step 4: Verify time sync configuration with timedatectl."
    read -p "  lab@lpic-lab97:~$ " cmd4
    echo
    [[ "$cmd4" != "timedatectl status" ]] && {
        print_error "Incorrect. Use: timedatectl status"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Local time: Tue 2025-12-16 15:12:44 EST"
    echo "  Universal time: Tue 2025-12-16 20:12:44 UTC"
    echo "  RTC time: Tue 2025-12-16 20:12:44"
    echo "  Time zone: America/New_York (EST, -0500)"
    echo "  System clock synchronized: yes"
    echo "  NTP service: active"
    echo

    echo "  Step 5: Check NTP sources using chronyc."
    read -p "  lab@lpic-lab97:~$ " cmd5
    echo
    [[ "$cmd5" != "chronyc sources -v" ]] && {
        print_error "Incorrect. Use: chronyc sources -v"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  210 Number of sources = 2"
    echo "  ^* time.cloudflare.com   3   6   377    28    -92us[ -120us] +/-   15ms"
    echo "  ^+ time.google.com       2   6   377    30   +120us[  +90us] +/-   20ms"
    echo

    echo "  Step 6: Force a step correction (one-time) if the drift is large."
    read -p "  lab@lpic-lab97:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo chronyc makestep" ]] && {
        print_error "Incorrect. Use: sudo chronyc makestep"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  200 OK"
    echo

    echo "  Step 7: Confirm tracking stats (current offset, frequency, etc.)."
    read -p "  lab@lpic-lab97:~$ " cmd7
    echo
    [[ "$cmd7" != "chronyc tracking" ]] && {
        print_error "Incorrect. Use: chronyc tracking"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Reference ID    : 0A0B0C0D (time.cloudflare.com)"
    echo "  Stratum         : 4"
    echo "  Ref time (UTC)  : Tue Dec 16 20:13:02 2025"
    echo "  System time     : 0.000123456 seconds fast of NTP time"
    echo "  Last offset     : +0.000045678 seconds"
    echo "  RMS offset      : 0.000200000 seconds"
    echo "  Frequency       : 15.123 ppm fast"
    echo "  Skew            : 0.456 ppm"
    echo "  Root delay      : 0.012345678 seconds"
    echo "  Root dispersion : 0.001234567 seconds"
    echo

    echo "  Step 8: Verify chrony config file location and key directives."
    read -p "  lab@lpic-lab97:~$ " cmd8
    echo
    [[ "$cmd8" != "ls -l /etc/chrony.conf" && "$cmd8" != "sudo ls -l /etc/chrony.conf" ]] && {
        print_error "Incorrect. Use: ls -l /etc/chrony.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -rw-r--r--. 1 root root 1234 Dec 16 14:58 /etc/chrony.conf"
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
    print_info "You have completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
