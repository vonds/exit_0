#!/bin/bash

# Lab 184: Find and Save Setuid Files (Essential Tools)
# Objective: Locate all setuid binaries on local filesystems, save a sorted list, validate, and compare scope.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 184: Find and Save Setuid Files"
LAB_ID="lab184"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

TARGET_ALL="/root/setuid_files.txt"
TARGET_USR="/root/setuid_usr.txt"

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
    center_text "Goal: Find all setuid files on local filesystems and save them for audit."
    center_text "Tip: Use -perm -4000 and avoid crossing devices with -xdev."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # Step 1
    draw_lab_ui
    echo "  Step 1: Find all setuid files on local filesystems and save a sorted list to $TARGET_ALL."
    echo "          (Ignore errors from unreadable paths.)"
    echo
    echo "  Expected pattern:"
    echo "    find / -xdev -type f -perm -4000 -print 2>/dev/null | sort > $TARGET_ALL"
    echo
    read -p "  lab@lab184:~$ " cmd1
    echo
    [[ "$cmd1" != "find / -xdev -type f -perm -4000 -print 2>/dev/null | sort > /root/setuid_files.txt" ]] && {
        print_error "Use: find / -xdev -type f -perm -4000 -print 2>/dev/null | sort > /root/setuid_files.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (setuid search saved to $TARGET_ALL)"
    echo

    # Step 2
    echo "  Step 2: Show the first 5 lines of the saved list to verify content."
    read -p "  lab@lab184:~$ " cmd2
    echo
    [[ "$cmd2" != "head -n 5 /root/setuid_files.txt" ]] && {
        print_error "Use: head -n 5 /root/setuid_files.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (displayed first 5 lines)"
    echo

    # Step 3
    echo "  Step 3: Print the total count of setuid files found."
    read -p "  lab@lab184:~$ " cmd3
    echo
    [[ "$cmd3" != "wc -l /root/setuid_files.txt" ]] && {
        print_error "Use: wc -l /root/setuid_files.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (displayed total count)"
    echo

    # Step 4
    echo "  Step 4: Repeat the search but restrict scope to /usr and save to $TARGET_USR."
    echo
    echo "  Expected pattern:"
    echo "    find /usr -xdev -type f -perm -4000 -print 2>/dev/null | sort > $TARGET_USR"
    echo
    read -p "  lab@lab184:~$ " cmd4
    echo
    [[ "$cmd4" != "find /usr -xdev -type f -perm -4000 -print 2>/dev/null | sort > /root/setuid_usr.txt" ]] && {
        print_error "Use: find /usr -xdev -type f -perm -4000 -print 2>/dev/null | sort > /root/setuid_usr.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (setuid search in /usr saved to $TARGET_USR)"
    echo

    # Step 5
    echo "  Step 5: Compare the two lists to see differences (unified diff)."
    read -p "  lab@lab184:~$ " cmd5
    echo
    [[ "$cmd5" != "diff -u /root/setuid_usr.txt /root/setuid_files.txt" ]] && {
        print_error "Use: diff -u /root/setuid_usr.txt /root/setuid_files.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (differences displayed)"
    echo

    # Step 6
    echo "  Step 6: Show one example file's permission bits with ls -l (use the first entry from the main list)."
    echo "          (Hint: head -n1 with command substitution.)"
    read -p "  lab@lab184:~$ " cmd6
    echo
    [[ "$cmd6" != "ls -l \"$(head -n1 /root/setuid_files.txt)\"" ]] && {
        print_error 'Use: ls -l "$(head -n1 /root/setuid_files.txt)"'
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (example file permissions shown)"
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
