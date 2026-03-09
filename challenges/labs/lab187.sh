#!/bin/bash

# Lab 187: Hard & Soft Links (Essential Tools) — Simulated RHCSA Edition
# Objective: Practice hard links and symbolic links using fully simulated output.
# NOTE: This lab is fully simulated and does not modify the real filesystem.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 187: Hard & Soft Links"
LAB_ID="lab187"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SIM_LINK_COUNT=1
SIM_SIZE=0
SIM_CONTENT=""
SOFTLINK_TARGET_EXISTS=1

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
    SIM_LINK_COUNT=1
    SIM_SIZE=0
    SIM_CONTENT=""
    SOFTLINK_TARGET_EXISTS=1

    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Goal: Practice creating and testing hard and soft links with simulated output."
    center_text "Focus: inode behavior, link counts, shared data, and broken symlinks."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create the original file."
    read -p "  lab@lab187:~$ " cmd1
    echo
    [[ "$cmd1" != "touch /tmp/hard1" ]] && {
        print_error "Use: touch /tmp/hard1"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_LINK_COUNT=1
    SIM_SIZE=0
    SIM_CONTENT=""

    echo "  File created."
    echo

    echo "  Step 2: Create a hard link named /tmp/hard2."
    read -p "  lab@lab187:~$ " cmd2
    echo
    [[ "$cmd2" != "ln /tmp/hard1 /tmp/hard2" ]] && {
        print_error "Use: ln /tmp/hard1 /tmp/hard2"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_LINK_COUNT=2

    echo "  Hard link created."
    echo

    echo "  Step 3: Create another hard link named /tmp/hard3."
    read -p "  lab@lab187:~$ " cmd3
    echo
    [[ "$cmd3" != "ln /tmp/hard1 /tmp/hard3" ]] && {
        print_error "Use: ln /tmp/hard1 /tmp/hard3"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_LINK_COUNT=3

    echo "  Hard link created."
    echo

    echo "  Step 4: List the three files with inode numbers."
    read -p "  lab@lab187:~$ " cmd4
    echo
    [[ "$cmd4" != "ls -li /tmp/hard1 /tmp/hard2 /tmp/hard3" ]] && {
        print_error "Use: ls -li /tmp/hard1 /tmp/hard2 /tmp/hard3"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  total 0"
    if [[ "$SIM_SIZE" -eq 0 ]]; then
        echo "  2893475 -rw-r--r-- 3 student student 0 Mar 08 12:00 /tmp/hard1"
        echo "  2893475 -rw-r--r-- 3 student student 0 Mar 08 12:00 /tmp/hard2"
        echo "  2893475 -rw-r--r-- 3 student student 0 Mar 08 12:00 /tmp/hard3"
    else
        echo "  2893475 -rw-r--r-- 3 student student $SIM_SIZE Mar 08 12:00 /tmp/hard1"
        echo "  2893475 -rw-r--r-- 3 student student $SIM_SIZE Mar 08 12:00 /tmp/hard2"
        echo "  2893475 -rw-r--r-- 3 student student $SIM_SIZE Mar 08 12:00 /tmp/hard3"
    fi
    echo

    echo "  Step 5: Append text through /tmp/hard2."
    read -p "  lab@lab187:~$ " cmd5
    echo
    [[ "$cmd5" != "echo test123 >> /tmp/hard2" ]] && {
        print_error "Use: echo test123 >> /tmp/hard2"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_CONTENT="test123"
    SIM_SIZE=8

    echo "  File updated."
    echo

    echo "  Step 6: Read the content through /tmp/hard1."
    read -p "  lab@lab187:~$ " cmd6
    echo
    [[ "$cmd6" != "cat /tmp/hard1" ]] && {
        print_error "Use: cat /tmp/hard1"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  test123"
    echo

    echo "  Step 7: Remove /tmp/hard1 and /tmp/hard3."
    read -p "  lab@lab187:~$ " cmd7
    echo
    [[ "$cmd7" != "rm /tmp/hard1 /tmp/hard3" ]] && {
        print_error "Use: rm /tmp/hard1 /tmp/hard3"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_LINK_COUNT=1

    echo "  removed '/tmp/hard1'"
    echo "  removed '/tmp/hard3'"
    echo

    echo "  Step 8: Confirm /tmp/hard2 still has the data."
    read -p "  lab@lab187:~$ " cmd8
    echo
    [[ "$cmd8" != "cat /tmp/hard2" ]] && {
        print_error "Use: cat /tmp/hard2"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  test123"
    echo

    echo "  Step 9: Create a symbolic link named /tmp/soft1 pointing to /tmp/hard2."
    read -p "  lab@lab187:~$ " cmd9
    echo
    [[ "$cmd9" != "ln -s /tmp/hard2 /tmp/soft1" ]] && {
        print_error "Use: ln -s /tmp/hard2 /tmp/soft1"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Symlink created."
    echo

    echo "  Step 10: Append text through the symbolic link."
    read -p "  lab@lab187:~$ " cmd10
    echo
    [[ "$cmd10" != "echo via_softlink >> /tmp/soft1" ]] && {
        print_error "Use: echo via_softlink >> /tmp/soft1"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_CONTENT=$'test123\nvia_softlink'
    SIM_SIZE=21

    echo "  File updated."
    echo

    echo "  Step 11: Read the content through /tmp/hard2."
    read -p "  lab@lab187:~$ " cmd11
    echo
    [[ "$cmd11" != "cat /tmp/hard2" ]] && {
        print_error "Use: cat /tmp/hard2"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  test123"
    echo "  via_softlink"
    echo

    echo "  Step 12: Remove /tmp/hard2 and inspect the symlink."
    read -p "  lab@lab187:~$ " cmd12
    echo
    [[ "$cmd12" != "rm /tmp/hard2 && ls -l /tmp/soft1" ]] && {
        print_error "Use: rm /tmp/hard2 && ls -l /tmp/soft1"
        read -p "Press Enter to try again..." _
        continue
    }

    SOFTLINK_TARGET_EXISTS=0

    echo "  removed '/tmp/hard2'"
    echo "  lrwxrwxrwx 1 student student 10 Mar 08 12:00 /tmp/soft1 -> /tmp/hard2"
    echo "  Note: /tmp/soft1 is now a broken symlink."
    echo

    echo "  Step 13: Try to read the broken symlink."
    read -p "  lab@lab187:~$ " cmd13
    echo
    [[ "$cmd13" != "cat /tmp/soft1" ]] && {
        print_error "Use: cat /tmp/soft1"
        read -p "Press Enter to try again..." _
        continue
    }

    if [[ "$SOFTLINK_TARGET_EXISTS" -eq 0 ]]; then
        echo "  cat: /tmp/soft1: No such file or directory"
    fi
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
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