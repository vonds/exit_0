#!/bin/bash

# Lab 88: Managing Log Rotation with logrotate

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 88: Managing Log Rotation with logrotate"
LAB_ID="lab88"
LAB_XP=1500
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
    center_text "Scenario: Manage log growth and retention using the logrotate utility."
    center_text "Configure a custom rotation policy for a sample log file and apply it manually."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Ensure the logrotate package is installed."
    read -p "  lab@lpic-lab88:~$ " cmd1
    echo
    if [[ "$cmd1" == "sudo apt install logrotate -y" ]]; then
        echo "  Reading package lists... Done"
        echo "  Building dependency tree..."
        echo "  Reading state information... Done"
        echo "  logrotate is already the newest version."
        echo "  0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded."
    elif [[ "$cmd1" == "sudo dnf install logrotate -y" ]]; then
        echo "  Last metadata expiration check: 0:02:13 ago on Mon 06 Jan 2025 10:12:34 AM UTC."
        echo "  Package logrotate-3.x-xx.el9.x86_64 is already installed."
        echo "  Dependencies resolved."
        echo "  Nothing to do."
        echo "  Complete!"
    elif [[ "$cmd1" == "sudo pacman -S logrotate" ]]; then
        echo "  resolving dependencies..."
        echo "  looking for conflicting packages..."
        echo ""
        echo "  Packages (1) logrotate-3.x-x"
        echo ""
        echo "  Total Installed Size:  0.20 MiB"
        echo "  :: Proceed with installation? [Y/n] y"
        echo "  (1/1) checking keys in keyring                                [################################] 100%"
        echo "  (1/1) installing logrotate                                    [################################] 100%"
    else
        print_error "Incorrect. Try: sudo apt install logrotate -y (or dnf/pacman depending on distro)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 2: Create a custom log file to test with."
    read -p "  lab@lpic-lab88:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo touch /var/log/testapp.log" ]] && {
        print_error "Incorrect. Use: sudo touch /var/log/testapp.log"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Sample log file created at /var/log/testapp.log."
    echo

    echo "  Step 3: Create a logrotate configuration for testapp.log."
    read -p "  lab@lpic-lab88:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo nano /etc/logrotate.d/testapp" && "$cmd3" != "sudo vim /etc/logrotate.d/testapp" ]] && {
        print_error "Incorrect. Open the config file with sudo nano /etc/logrotate.d/testapp"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (editor opened; you add the following content and save the file)"
    echo "  ---------------------------------------------------------------"
    echo "  /var/log/testapp.log {"
    echo "      weekly"
    echo "      rotate 4"
    echo "      compress"
    echo "      missingok"
    echo "      notifempty"
    echo "  }"
    echo "  ---------------------------------------------------------------"
    echo

    echo "  Step 4: Simulate log rotation manually for testapp."
    read -p "  lab@lpic-lab88:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo logrotate -f /etc/logrotate.d/testapp" ]] && {
        print_error "Incorrect. Use: sudo logrotate -f /etc/logrotate.d/testapp"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Forced rotation for /var/log/testapp.log completed."
    echo

    echo "  Step 5: List rotated log files to confirm."
    read -p "  lab@lpic-lab88:~$ " cmd5
    echo
    [[ "$cmd5" != "ls /var/log/testapp.log*" ]] && {
        print_error "Incorrect. Use: ls /var/log/testapp.log*"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /var/log/testapp.log"
    echo "  /var/log/testapp.log.1.gz"
    echo

    echo "  Step 6: View the default global config file."
    read -p "  lab@lpic-lab88:~$ " cmd6
    echo
    [[ "$cmd6" != "cat /etc/logrotate.conf" ]] && {
        print_error "Incorrect. Use: cat /etc/logrotate.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  # see 'man logrotate' for details"
    echo "  # global options for log rotation"
    echo "  weekly"
    echo "  rotate 4"
    echo "  create"
    echo "  include /etc/logrotate.d"
    echo "  # system-specific logs may be listed here"
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
