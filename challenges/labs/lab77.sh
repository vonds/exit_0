#!/bin/bash

# Lab 77: Network Time Protocol (NTP)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 77: Network Time Protocol (NTP)"
LAB_ID="lab77"
LAB_XP=20000
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
    center_text "Scenario: Your server's system time is incorrect and needs to be synchronized."
    center_text "You'll use RHEL's chrony-based NTP tools to install, query, and set time accurately."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the NTP client/server package on a RHEL-based system."
    read -p "  lab@rhel-lab77:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo dnf install -y chrony" ]] && {
        print_error "Incorrect. Use: sudo dnf install -y chrony"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Last metadata expiration check: 0:00:07 ago on Mon 29 Jul 2025 10:22:44 AM EDT."
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package          Arch       Version                 Repository            Size"
    echo "  ================================================================================"
    echo "   chrony           x86_64     4.4-1.el9              baseos                450 k"
    echo
    echo "  Transaction Summary"
    echo "  ================================================================================"
    echo "  Install  1 Package"
    echo
    echo "  Total download size: 450 k"
    echo "  Installed size: 1.8 M"
    echo "  Is this ok [y/N]: y"
    echo "  Downloading Packages:"
    echo "  chrony-4.4-1.el9.x86_64.rpm                         450 kB/s | 450 kB     00:01"
    echo "  -------------------------------------------------------------------------------"
    echo "  Total                                                450 kB/s | 450 kB     00:01"
    echo "  Running transaction check"
    echo "  Running transaction test"
    echo "  Transaction test succeeded."
    echo "  Running transaction"
    echo "    Preparing        :  1/1"
    echo "    Installing       :  chrony-4.4-1.el9.x86_64       1/1"
    echo "    Verifying        :  chrony-4.4-1.el9.x86_64       1/1"
    echo "  Installed products updated."
    echo

    echo "  Step 2: Query current time sources from the chrony NTP client."
    read -p "  lab@rhel-lab77:~$ " cmd2
    echo
    [[ "$cmd2" != "chronyc sources -v" ]] && {
        print_error "Incorrect. Use: chronyc sources -v"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  210 Number of sources = 4"
    echo "  =============================================================================="
    echo "    .-- Source mode  '^' = server, '=' = peer, '#' = local clock."
    echo "   / .- Source state '*' = current synced, '+' = combined, '-' = not combined,"
    echo "  |  |                '?' = unreachable, 'x' = time may be in error,"
    echo "  |  |                '~' = time too variable."
    echo "  MS Name/IP address         Stratum Poll Reach LastRx Last sample"
    echo "  =============================================================================="
    echo "  ^* time.cloudflare.com          3   6   377    32   -0.000123   0.000345"
    echo "  ^+ 0.rhel.pool.ntp.org          2   6   377    58   -0.000456   0.000789"
    echo "  ^- 1.rhel.pool.ntp.org          2   6   377    60    0.000321   0.000654"
    echo "  ^- 2.rhel.pool.ntp.org          2   6   377    15   -0.000210   0.000432"
    echo

    echo "  Step 3: Force an immediate step adjustment of the system clock."
    read -p "  lab@rhel-lab77:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo chronyc makestep" ]] && {
        print_error "Incorrect. Use: sudo chronyc makestep"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  200 OK"
    echo "  makestep: adjusted offset by 0.000456 seconds"
    echo

    echo "  Step 4: Enable and start the chrony service on boot."
    read -p "  lab@rhel-lab77:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo systemctl enable --now chronyd" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now chronyd"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Created symlink /etc/systemd/system/multi-user.target.wants/chronyd.service → /usr/lib/systemd/system/chronyd.service."
    echo "  Running transaction"
    echo "    Starting chronyd.service - NTP client/server"
    echo "  Job for chronyd.service started successfully."
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
