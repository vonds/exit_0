#!/bin/bash

# Lab 21: Understand and Use the Sticky Bit

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 21: Understand and Use the Sticky Bit"
LAB_ID="lab21"
LAB_XP=3888
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
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
    center_text "Your task: Set up a shared directory where users can write,"
    center_text "but not delete files they don't own. This requires understanding"
    center_text "and properly using the sticky bit."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command creates a shared directory for group use?"
    read -p "  lab@lpic-lab21:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "mkdir -p /tmp/shared" ]]; then
        print_error "Incorrect. You need to create a directory under /tmp named 'shared'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 2: What command sets group write permissions on /tmp/shared?"
    read -p "  lab@lpic-lab21:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "chmod 777 /tmp/shared" && "$cmd2" != "chmod a+rwx /tmp/shared" ]]; then
        print_error "Incorrect. You're expected to make it world-writable."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 3: What command adds the sticky bit to the directory?"
    read -p "  lab@lpic-lab21:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "chmod +t /tmp/shared" && "$cmd3" != "chmod 1777 /tmp/shared" ]]; then
        print_error "Incorrect. Try using +t or octal 1xxx."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 4: How can you verify the sticky bit is set?"
    read -p "  lab@lpic-lab21:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "ls -ld /tmp/shared" ]]; then
        print_error "Incorrect. Use ls -ld to check sticky bit (t) on a directory."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  drwxrwxrwt 2 root root 4096 Jul 18 15:04 /tmp/shared"
    echo

    print_success "Well done!"
    print_info "The sticky bit restricts file deletion in shared directories."
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
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
