#!/bin/bash

# Lab 50: Finding System Architecture (arch)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 50: Finding System Architecture"
LAB_ID="lab50"
LAB_XP=18500
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
    center_text "You're preparing a report for a new software deployment."
    center_text "The application requires a 64-bit architecture system."
    center_text "Let's use terminal commands to verify the system's architecture."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Check the machine architecture."
    read -p "  lab@arch-audit:~\$ " cmd1
    echo
    [[ "$cmd1" != "arch" ]] && {
        print_error "Incorrect. Use the 'arch' command to check system architecture."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  x86_64"
    echo

    echo "  Step 2: Use uname to confirm the same architecture."
    read -p "  lab@arch-audit:~\$ " cmd2
    echo
    [[ "$cmd2" != "uname -m" ]] && {
        print_error "Incorrect. Use 'uname -m' to show the machine hardware name."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  x86_64"
    echo

    echo "  Step 3: List architecture and CPU info."
    read -p "  lab@arch-audit:~\$ " cmd3
    echo
    [[ "$cmd3" != "lscpu" ]] && {
        print_error "Incorrect. Use 'lscpu' to display CPU and architecture details."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Architecture:           x86_64"
    echo "  CPU op-mode(s):         32-bit, 64-bit"
    echo "  Byte Order:             Little Endian"
    echo "  CPU(s):                 2"
    echo "  Model name:             Intel(R) Xeon(R) CPU"
    echo

    echo "  Step 4: Identify if the system supports 64-bit binaries."
    read -p "  lab@arch-audit:~\$ " cmd4
    echo
    [[ "$cmd4" != "getconf LONG_BIT" ]] && {
        print_error "Incorrect. Use 'getconf LONG_BIT' to verify bit mode."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  64"
    echo

    echo "  Step 5: Your final task: Write a short note 'System is 64-bit compatible' confirming architecture."
    read -p "  lab@arch-audit:~\$ " cmd5
    echo
    [[ "$cmd5" != "echo 'System is 64-bit compatible'" ]] && {
        print_error "Incorrect. Your echo message must match exactly."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  System is 64-bit compatible"
    echo

    print_success "System architecture successfully verified."
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
``