#!/bin/bash

# Lab 49: Finding System Information (uname, dmidecode)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 49: Finding System Information"
LAB_ID="lab49"
LAB_XP=12090
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
    center_text "Your manager needs detailed info about this machine's OS, hardware, and architecture."
    center_text "You'll use 'uname' and 'dmidecode' to gather the information."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Print the kernel name."
    read -p "  lab@sysinfo:~\$ " cmd1
    echo
    [[ "$cmd1" != "uname" && "$cmd1" != "uname -s" ]] && {
        print_error "Incorrect. Use 'uname' or 'uname -s'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Linux"
    echo

    echo "  Step 2: Print the kernel release version."
    read -p "  lab@sysinfo:~\$ " cmd2
    echo
    [[ "$cmd2" != "uname -r" ]] && {
        print_error "Incorrect. Use 'uname -r'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  5.15.0-88-generic"
    echo

    echo "  Step 3: Display all available system info with uname."
    read -p "  lab@sysinfo:~\$ " cmd3
    echo
    [[ "$cmd3" != "uname -a" ]] && {
        print_error "Incorrect. Use 'uname -a'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Linux sysinfo 5.15.0-88-generic #98-Ubuntu SMP x86_64 GNU/Linux"
    echo

    echo "  Step 4: View the system manufacturer info."
    read -p "  lab@sysinfo:~\$ " cmd4
    echo
    [[ "$cmd4" != "sudo dmidecode -s system-manufacturer" && "$cmd4" != "dmidecode -s system-manufacturer" ]] && {
        print_error "Incorrect. Use 'sudo dmidecode -s system-manufacturer'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  QEMU"
    echo

    echo "  Step 5: Check the system's product name."
    read -p "  lab@sysinfo:~\$ " cmd5
    echo
    [[ "$cmd5" != "sudo dmidecode -s system-product-name" && "$cmd5" != "dmidecode -s system-product-name" ]] && {
        print_error "Incorrect. Use 'sudo dmidecode -s system-product-name'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Standard PC (i440FX + PIIX, 1996)"
    echo

    echo "  Step 6: View the system UUID."
    read -p "  lab@sysinfo:~\$ " cmd6
    echo
    [[ "$cmd6" != "sudo dmidecode -s system-uuid" && "$cmd6" != "dmidecode -s system-uuid" ]] && {
        print_error "Incorrect. Use 'sudo dmidecode -s system-uuid'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  12345678-90AB-CDEF-1234-567890ABCDEF"
    echo

    print_success "Excellent! You've collected all the system info."
    print_info "You earned $LAB_XP XP for completing this lab!"
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
