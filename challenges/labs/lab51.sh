#!/bin/bash

# Lab 51: Generating a System SOS Report

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 51: Generating a System SOS Report"
LAB_ID="lab51"
LAB_XP=19500
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
    center_text "You are a support engineer at a data center."
    center_text "A customer reports serious performance issues."
    center_text "Your manager asks you to generate and collect a full SOS report for analysis."
    center_text "This lab will walk you through installing, configuring, and using the sosreport utility."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the sosreport package."
    read -p "  lab@support-node:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo dnf install -y sos" && "$cmd1" != "sudo yum install -y sos" ]] && {
        print_error "Incorrect. Use dnf or yum to install the sosreport tool."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sos package installed successfully."
    echo

    echo "  Step 2: Run the sosreport tool to begin a diagnostic collection."
    read -p "  lab@support-node:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo sosreport" ]] && {
        print_error "Incorrect. Use 'sudo sosreport' to start the report collection."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sosreport (version 4.5)"
    echo "  This utility will collect diagnostic and support data from this system."
    echo "  Please enter your first initial and last name [labuser]:"
    echo -n "  > "; read _
    echo "  Please enter the case ID that you are generating this report for:"
    echo -n "  > "; read _
    echo "  Creating archive...this may take a few minutes."
    echo "  sosreport saved to /var/tmp/sosreport-labuser-123456.tar.xz"
    echo

    echo "  Step 3: Verify the report location and contents."
    read -p "  lab@support-node:~$ " cmd3
    echo
    [[ "$cmd3" != "ls /var/tmp" ]] && {
        print_error "Incorrect. Use 'ls /var/tmp' to verify the report exists."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sosreport-labuser-123456.tar.xz"
    echo

    echo "  Step 4: View files in the archive (non-destructive)."
    read -p "  lab@support-node:~$ " cmd4
    echo
    [[ "$cmd4" != "tar -tf /var/tmp/sosreport-labuser-123456.tar.xz" ]] && {
        print_error "Incorrect. Use tar -tf to list files inside the report archive."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sosreport-labuser-123456/etc/hostname"
    echo "  sosreport-labuser-123456/var/log/messages"
    echo "  sosreport-labuser-123456/proc/cpuinfo"
    echo "  sosreport-labuser-123456/sys/kernel/debug"
    echo

    print_success "Well done! You generated and inspected a full sosreport archive."
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
