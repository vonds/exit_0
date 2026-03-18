#!/bin/bash

# Lab 184: Find and Save Setuid Files (Essential Tools)
# Objective: Locate setuid binaries on local filesystems, save a sorted list, validate results, and compare scope.

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
    echo
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
    center_text "Audit setuid binaries, save the results, and verify what was found."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # Step 1
    draw_lab_ui
    echo "  Step 1: Find all setuid files on the local filesystem and save them to $TARGET_ALL."
    read -p "  root@servera:~# " cmd1
    echo
    [[ "$cmd1" != "find / -xdev -type f -perm /4000 2>/dev/null | sort > /root/setuid_files.txt" ]] && {
        print_error "Use: find / -xdev -type f -perm /4000 2>/dev/null | sort > /root/setuid_files.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  root@servera:~# wc -l /root/setuid_files.txt"
    echo "  18 /root/setuid_files.txt"
    echo
    echo "  Search complete. Results saved to $TARGET_ALL."
    echo

    # Step 2
    echo "  Step 2: Display the first 5 lines of the saved list."
    read -p "  root@servera:~# " cmd2
    echo
    [[ "$cmd2" != "head -n 5 /root/setuid_files.txt" ]] && {
        print_error "Use: head -n 5 /root/setuid_files.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /usr/bin/chage"
    echo "  /usr/bin/chfn"
    echo "  /usr/bin/chsh"
    echo "  /usr/bin/gpasswd"
    echo "  /usr/bin/mount"
    echo

    # Step 3
    echo "  Step 3: Show how many setuid files were found."
    read -p "  root@servera:~# " cmd3
    echo
    [[ "$cmd3" != "wc -l /root/setuid_files.txt" ]] && {
        print_error "Use: wc -l /root/setuid_files.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  18 /root/setuid_files.txt"
    echo

    # Step 4
    echo "  Step 4: Repeat the search only under /usr and save it to $TARGET_USR."
    read -p "  root@servera:~# " cmd4
    echo
    [[ "$cmd4" != "find /usr -type f -perm /4000 2>/dev/null | sort > /root/setuid_usr.txt" ]] && {
        print_error "Use: find /usr -type f -perm /4000 2>/dev/null | sort > /root/setuid_usr.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  root@servera:~# wc -l /root/setuid_usr.txt"
    echo "  14 /root/setuid_usr.txt"
    echo
    echo "  Search complete. Results saved to $TARGET_USR."
    echo

    # Step 5
    echo "  Step 5: Compare how many entries are in each saved file."
    read -p "  root@servera:~# " cmd5
    echo
    [[ "$cmd5" != "wc -l /root/setuid_files.txt /root/setuid_usr.txt" ]] && {
        print_error "Use: wc -l /root/setuid_files.txt /root/setuid_usr.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  18 /root/setuid_files.txt"
    echo "  14 /root/setuid_usr.txt"
    echo "  32 total"
    echo

    # Step 6
    echo "  Step 6: Check the permissions of one known setuid binary."
    read -p "  root@servera:~# " cmd6
    echo
    [[ "$cmd6" != "ls -l /usr/bin/passwd" ]] && {
        print_error "Use: ls -l /usr/bin/passwd"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -rwsr-xr-x. 1 root root 33544 Jan 12 08:14 /usr/bin/passwd"
    echo
    echo "  The 's' in the owner's execute field confirms the setuid bit is set."
    echo

    print_success "Nice work!"
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