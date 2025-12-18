#!/bin/bash

# Lab 48: Changing System Hostname

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 48: Changing System Hostname"
LAB_ID="lab48"
LAB_XP=21045
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

OLD_HOSTNAME="old-server"
NEW_HOSTNAME="web-node01"

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
    center_text "Your company recently restructured its internal network."
    center_text "You’ve been asked to update hostnames to reflect new node naming conventions."
    center_text "The current hostname is '$OLD_HOSTNAME' and it should be changed to '$NEW_HOSTNAME'."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View the current hostname."
    read -p "  lab@${OLD_HOSTNAME}:~\$ " cmd1
    echo
    [[ "$cmd1" != "hostnamectl" && "$cmd1" != "hostnamectl status" ]] && {
        print_error "Incorrect. Use 'hostnamectl' or 'hostnamectl status' to view hostname."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "   Static hostname: $OLD_HOSTNAME"
    echo "         Icon name: computer-vm"
    echo "           Chassis: vm"
    echo "        Machine ID: a1b2c3d4e5f6g7h8i9j0"
    echo "           Boot ID: x1y2z3a4b5c6d7e8f9g0"
    echo "  Operating System: Ubuntu 22.04.4 LTS"
    echo "            Kernel: Linux 5.15.0-88-generic"
    echo "      Architecture: x86-64"
    echo

    echo "  Step 2: Change the hostname to '$NEW_HOSTNAME'."
    read -p "  lab@${OLD_HOSTNAME}:~\$ " cmd2
    echo
    [[ "$cmd2" != "sudo hostnamectl set-hostname $NEW_HOSTNAME" && "$cmd2" != "hostnamectl set-hostname $NEW_HOSTNAME" ]] && {
        print_error "Incorrect. Use 'hostnamectl set-hostname $NEW_HOSTNAME'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Hostname successfully changed."
    echo

    echo "  Step 3: Confirm the hostname has been updated."
    read -p "  lab@${NEW_HOSTNAME}:~\$ " cmd3
    echo
    [[ "$cmd3" != "hostnamectl" && "$cmd3" != "hostnamectl status" ]] && {
        print_error "Incorrect. Use 'hostnamectl' or 'hostnamectl status'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "   Static hostname: $NEW_HOSTNAME"
    echo "         Icon name: computer-vm"
    echo "           Chassis: vm"
    echo "        Machine ID: a1b2c3d4e5f6g7h8i9j0"
    echo "           Boot ID: x1y2z3a4b5c6d7e8f9g0"
    echo "  Operating System: Ubuntu 22.04.4 LTS"
    echo "            Kernel: Linux 5.15.0-88-generic"
    echo "      Architecture: x86-64"
    echo

    echo "  Step 4: Verify the change"
    read -p "  lab@${NEW_HOSTNAME}:~\$ " cmd4
    echo
    [[ "$cmd4" != "cat /etc/hostname" ]] && {
        print_error "Incorrect. Use 'cat /etc/hostname' to verify."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  $NEW_HOSTNAME"
    echo

    echo "  Now checking /etc/hosts..."
    echo "  127.0.0.1   localhost"
    echo "  127.0.1.1   $NEW_HOSTNAME"
    echo

    print_success "Well done!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've successfully completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
