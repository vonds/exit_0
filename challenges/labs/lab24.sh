#!/bin/bash

# Lab 24: Permission Pitfall Patrol – Mastering File Permissions and Special Bits

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 24: Permission Pitfall"
LAB_ID="lab24"
LAB_XP=21111
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
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
    center_text "A junior admin changed permissions on key directories."
    center_text "Fix security holes, restore ownership, and apply special bits where needed."
    echo
    center_text "Press Enter to begin..."
    read _
    draw_lab_ui

    # ---- Step 1 (Interactive command) ----
    echo "  Step 1: Investigate /tmp permissions."
    echo "         Run the correct command to display the long listing of /tmp."
    while true; do
        read -p "  lab@lpic-lab24:~$ " cmd_ls
        if [[ "$cmd_ls" == "ls -ld /tmp" ]]; then
            # Simulated output
            echo "  drwxrwxrwx  2 root root 4096 Jul 18 12:00 /tmp"
            break
        else
            print_error "  Command not recognized. Expected: ls -ld /tmp"
        fi
    done
    echo

    echo "  What permission is missing that protects user temp files?"
    read -p "  lab@lpic-lab24:~$ " cmd1
    echo
    if [[ "$cmd1" != "sticky bit" && "$cmd1" != "t bit" && "$cmd1" != "sticky" && "$cmd1" != "t" ]]; then
        print_error "  Incorrect. Consider which bit prevents users from deleting each other's files."
        read -p "  Press Enter to retry the lab..." _
        continue
    fi

    # ---- Step 2 ----
    echo "  Step 2: Restore proper permissions to /tmp."
    read -p "  lab@lpic-lab24:~$ " cmd2
    echo
    if [[ "$cmd2" != "chmod 1777 /tmp" ]]; then
        print_error "  Incorrect. Use chmod 1777 /tmp"
        read -p "  Press Enter to retry the lab..." _
        continue
    fi

    # ---- Step 3 ----
    echo "  Step 3: A script requires root privileges even when run by normal users."
    echo "          Which bit allows this?"
    read -p "  lab@lpic-lab24:~$ " cmd3
    echo
    if [[ "$cmd3" != "setuid" ]]; then
        print_error "  Incorrect. Think about running with the file owner's privileges."
        read -p "  Press Enter to retry the lab..." _
        continue
    fi

    # ---- Step 4 ----
    echo "  Step 4: Apply setuid to /usr/local/bin/myscript."
    read -p "  lab@lpic-lab24:~$ " cmd4
    echo
    if [[ "$cmd4" != "chmod u+s /usr/local/bin/myscript" && "$cmd4" != "chmod 4755 /usr/local/bin/myscript" ]]; then
        print_error "  Incorrect. Use chmod u+s /usr/local/bin/myscript (or numeric 4755)."
        read -p "  Press Enter to retry the lab..." _
        continue
    fi

    # ---- Step 5 ----
    echo "  Step 5: Numeric mode for a directory with setgid and full permissions."
    read -p "  lab@lpic-lab24:~$ " cmd5
    echo
    if [[ "$cmd5" != "2770" ]]; then
        print_error "  Incorrect. 2 = setgid; 770 = rwx for owner and group only."
        read -p "  Press Enter to retry the lab..." _
        continue
    fi

    print_success "Well done!"
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
