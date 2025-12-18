#!/bin/bash

# Lab 187: Hard & Soft Links (Essential Tools) — Realistic Output Edition
# Objective: Create hard and soft links, observe behavior after editing and removal, with simulated outputs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 187: Hard & Soft Links"
LAB_ID="lab187"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated constants (stable "inode" and sizes to make output coherent)
SIM_INODE=2893475
SIM_UID=$(id -un)
SIM_GID=$(id -gn)
SIM_MODE="-rw-r--r--"
SIM_MODE_LINK="-rw-r--r--"
SIM_MODE_SYM="lrwxrwxrwx"
SIM_SIZE_EMPTY=0
SIM_SIZE_AFTER_E1=8          # len("test123\n") ≈ 8
SIM_SIZE_AFTER_E2=21         # + len("via_softlink\n") ≈ 13 -> total ~21

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
    center_text "Goal: Practice creating and testing hard/soft links under /tmp."
    center_text "Focus: ls -li to compare inode numbers and behavior after deletion."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # Step 1: Create file hard1
    draw_lab_ui
    echo "  Step 1: Create an empty file /tmp/hard1."
    echo "          Expected: touch /tmp/hard1"
    read -p "  lab@lab187:~$ " cmd1
    echo
    [[ "$cmd1" != "touch /tmp/hard1" ]] && {
        print_error "Use: touch /tmp/hard1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (created /tmp/hard1)"
    echo

    # Step 2: Create hard links
    echo "  Step 2: Create hard links hard2 and hard3 pointing to hard1."
    echo "          Expected: ln /tmp/hard1 /tmp/hard2 && ln /tmp/hard1 /tmp/hard3"
    read -p "  lab@lab187:~$ " cmd2
    echo
    [[ "$cmd2" != "ln /tmp/hard1 /tmp/hard2 && ln /tmp/hard1 /tmp/hard3" ]] && {
        print_error "Use: ln /tmp/hard1 /tmp/hard2 && ln /tmp/hard1 /tmp/hard3"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (hard2 and hard3 created)"
    echo

    # Step 3: Show inode numbers (simulate ls -li)
    echo "  Step 3: List inode numbers of the three files to confirm they match."
    echo "          Expected: ls -li /tmp/hard1 /tmp/hard2 /tmp/hard3"
    read -p "  lab@lab187:~$ " cmd3
    echo
    [[ "$cmd3" != "ls -li /tmp/hard1 /tmp/hard2 /tmp/hard3" ]] && {
        print_error "Use: ls -li /tmp/hard1 /tmp/hard2 /tmp/hard3"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "total 0"
    printf "%-9s %s 1 %-8s %-8s %4d %s %2d %02d:%02d /tmp/hard1\n" \
        "$SIM_INODE" "$SIM_MODE" "$SIM_UID" "$SIM_GID" "$SIM_SIZE_EMPTY" "$(date +%b)" "$(date +%d)" "$(date +%H)" "$(date +%M)"
    printf "%-9s %s 1 %-8s %-8s %4d %s %2d %02d:%02d /tmp/hard2\n" \
        "$SIM_INODE" "$SIM_MODE_LINK" "$SIM_UID" "$SIM_GID" "$SIM_SIZE_EMPTY" "$(date +%b)" "$(date +%d)" "$(date +%H)" "$(date +%M)"
    printf "%-9s %s 1 %-8s %-8s %4d %s %2d %02d:%02d /tmp/hard3\n" \
        "$SIM_INODE" "$SIM_MODE_LINK" "$SIM_UID" "$SIM_GID" "$SIM_SIZE_EMPTY" "$(date +%b)" "$(date +%d)" "$(date +%H)" "$(date +%M)"
    echo

    # Step 4: Edit hard2
    echo "  Step 4: Append a test string into hard2."
    echo "          Expected: echo 'test123' >> /tmp/hard2"
    read -p "  lab@lab187:~$ " cmd4
    echo
    [[ "$cmd4" != "echo 'test123' >> /tmp/hard2" ]] && {
        print_error "Use: echo 'test123' >> /tmp/hard2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (appended to /tmp/hard2)"
    echo "  Simulated: file grew to $SIM_SIZE_AFTER_E1 bytes (all hard links see the change)."
    echo

    # Step 5: Show contents of hard1 (simulated cat)
    echo "  Step 5: Display contents of hard1 to observe shared data."
    echo "          Expected: cat /tmp/hard1"
    read -p "  lab@lab187:~$ " cmd5
    echo
    [[ "$cmd5" != "cat /tmp/hard1" ]] && {
        print_error "Use: cat /tmp/hard1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "test123"
    echo

    # Step 6: Remove original and one link
    echo "  Step 6: Remove hard1 and hard3."
    echo "          Expected: rm /tmp/hard1 /tmp/hard3"
    read -p "  lab@lab187:~$ " cmd6
    echo
    [[ "$cmd6" != "rm /tmp/hard1 /tmp/hard3" ]] && {
        print_error "Use: rm /tmp/hard1 /tmp/hard3"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  removed '/tmp/hard1'"
    echo "  removed '/tmp/hard3'"
    echo

    # Step 7: Check hard2 still intact (simulated cat)
    echo "  Step 7: Verify that hard2 still exists and shows the content."
    echo "          Expected: cat /tmp/hard2"
    read -p "  lab@lab187:~$ " cmd7
    echo
    [[ "$cmd7" != "cat /tmp/hard2" ]] && {
        print_error "Use: cat /tmp/hard2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "test123"
    echo

    # Step 8: Create soft link
    echo "  Step 8: Create a symbolic link soft1 pointing to /tmp/hard2."
    echo "          Expected: ln -s /tmp/hard2 /tmp/soft1"
    read -p "  lab@lab187:~$ " cmd8
    echo
    [[ "$cmd8" != "ln -s /tmp/hard2 /tmp/soft1" ]] && {
        print_error "Use: ln -s /tmp/hard2 /tmp/soft1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (created symlink /tmp/soft1 -> /tmp/hard2)"
    echo

    # Step 9: Edit soft1 (simulated append)
    echo "  Step 9: Append text via soft1."
    echo "          Expected: echo 'via_softlink' >> /tmp/soft1"
    read -p "  lab@lab187:~$ " cmd9
    echo
    [[ "$cmd9" != "echo 'via_softlink' >> /tmp/soft1" ]] && {
        print_error "Use: echo 'via_softlink' >> /tmp/soft1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (appended to /tmp/soft1 which targets /tmp/hard2)"
    echo "  Simulated: file grew to ~$SIM_SIZE_AFTER_E2 bytes."
    echo

    # Step 10: Remove hard2, test soft1 (simulated ls -l broken link)
    echo "  Step 10: Remove hard2 and then try to list soft1."
    echo "           Expected: rm /tmp/hard2 && ls -l /tmp/soft1"
    read -p "  lab@lab187:~$ " cmd10
    echo
    [[ "$cmd10" != "rm /tmp/hard2 && ls -l /tmp/soft1" ]] && {
        print_error "Use: rm /tmp/hard2 && ls -l /tmp/soft1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  removed '/tmp/hard2'"
    # Simulate a dangling symlink output
    printf "%s %-8s %-8s %4d %s %2d %02d:%02d /tmp/soft1 -> /tmp/hard2\n" \
        "$SIM_MODE_SYM" "$SIM_UID" "$SIM_GID" 9 "$(date +%b)" "$(date +%d)" "$(date +%H)" "$(date +%M)"
    echo "  Note: /tmp/soft1 is now a broken symlink (target missing)."
    echo "  (If you run: cat /tmp/soft1, you'd get: 'No such file or directory')"
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
