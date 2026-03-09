#!/bin/bash

# Lab 186: Archive /home with gzip & bzip2, then extract and verify (Essential Tools)
# Objective: Create gzip and bzip2 archives of /home, verify contents, extract to test dirs, and validate.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 186: Home Dir Archives"
LAB_ID="lab186"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

TGZ="/root/home_backup.tgz"
TBZ="/root/home_backup.tar.bz2"
RESTORE_GZ="/tmp/restore_gz"
RESTORE_BZ="/tmp/restore_bz2"

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
    center_text "Goal: Create gzip and bzip2 tar archives of /home and extract them to verify."
    center_text "Tip: tar -czf (gzip), tar -cjf (bzip2), tar -tzf / tar -tjf to list, -xzf / -xjf to extract."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # Step 1: Create gzip archive
    draw_lab_ui
    echo "  Step 1: Create a gzip-compressed archive of /home at $TGZ."
    echo "          Expected: tar -czf $TGZ /home"
    read -p "  lab@lab186:~$ " cmd1
    echo
    [[ "$cmd1" != "tar -czf /root/home_backup.tgz /home" ]] && {
        print_error "Use: tar -czf /root/home_backup.tgz /home"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (created $TGZ)"
    echo

    # Step 2: Create bzip2 archive
    echo "  Step 2: Create a bzip2-compressed archive of /home at $TBZ."
    echo "          Expected: tar -cjf $TBZ /home"
    read -p "  lab@lab186:~$ " cmd2
    echo
    [[ "$cmd2" != "tar -cjf /root/home_backup.tar.bz2 /home" ]] && {
        print_error "Use: tar -cjf /root/home_backup.tar.bz2 /home"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (created $TBZ)"
    echo

    # Step 3: Verify gzip archive contents (list)
    echo "  Step 3: List a few entries from the gzip archive to verify."
    echo "          Expected: tar -tzf $TGZ | head -n 5"
    read -p "  lab@lab186:~$ " cmd3
    echo
    [[ "$cmd3" != "tar -tzf /root/home_backup.tgz | head -n 5" ]] && {
        print_error "Use: tar -tzf /root/home_backup.tgz | head -n 5"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (listed contents of $TGZ)"
    echo

    # Step 4: Verify bzip2 archive contents (list)
    echo "  Step 4: List a few entries from the bzip2 archive to verify."
    echo "          Expected: tar -tjf $TBZ | head -n 5"
    read -p "  lab@lab186:~$ " cmd4
    echo
    [[ "$cmd4" != "tar -tjf /root/home_backup.tar.bz2 | head -n 5" ]] && {
        print_error "Use: tar -tjf /root/home_backup.tar.bz2 | head -n 5"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (listed contents of $TBZ)"
    echo

    # Step 5: Prepare restore dirs
    echo "  Step 5: Create restore directories $RESTORE_GZ and $RESTORE_BZ."
    echo "          Expected: mkdir -p $RESTORE_GZ $RESTORE_BZ"
    read -p "  lab@lab186:~$ " cmd5
    echo
    [[ "$cmd5" != "mkdir -p /tmp/restore_gz /tmp/restore_bz2" ]] && {
        print_error "Use: mkdir -p /tmp/restore_gz /tmp/restore_bz2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (restore dirs created)"
    echo

    # Step 6: Extract gzip archive to restore_gz
    echo "  Step 6: Extract the gzip archive to $RESTORE_GZ."
    echo "          Expected: tar -xzf $TGZ -C $RESTORE_GZ"
    read -p "  lab@lab186:~$ " cmd6
    echo
    [[ "$cmd6" != "tar -xzf /root/home_backup.tgz -C /tmp/restore_gz" ]] && {
        print_error "Use: tar -xzf /root/home_backup.tgz -C /tmp/restore_gz"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (extracted gzip archive)"
    echo

    # Step 7: Extract bzip2 archive to restore_bz2
    echo "  Step 7: Extract the bzip2 archive to $RESTORE_BZ."
    echo "          Expected: tar -xjf $TBZ -C $RESTORE_BZ"
    read -p "  lab@lab186:~$ " cmd7
    echo
    [[ "$cmd7" != "tar -xjf /root/home_backup.tar.bz2 -C /tmp/restore_bz2" ]] && {
        print_error "Use: tar -xjf /root/home_backup.tar.bz2 -C /tmp/restore_bz2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (extracted bzip2 archive)"
    echo

    # Step 8: Validate extraction (show top-level entries)
    echo "  Step 8: Show the top level of each restore directory to confirm extraction."
    echo "          Expected:"
    echo "            ls -1 $RESTORE_GZ | head -n 5"
    echo "            ls -1 $RESTORE_BZ | head -n 5"
    read -p "  lab@lab186:~$ " cmd8a
    echo
    [[ "$cmd8a" != "ls -1 /tmp/restore_gz | head -n 5" ]] && {
        print_error "Use: ls -1 /tmp/restore_gz | head -n 5"
        read -p "Press Enter to try again..." _
        continue
    }
    read -p "  lab@lab186:~$ " cmd8b
    echo
    [[ "$cmd8b" != "ls -1 /tmp/restore_bz2 | head -n 5" ]] && {
        print_error "Use: ls -1 /tmp/restore_bz2 | head -n 5"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (restores validated)"
    echo

    # Step 9: Show archive sizes (human-readable)
    echo "  Step 9: Display the sizes of both archives."
    echo "          Expected: ls -lh $TGZ $TBZ"
    read -p "  lab@lab186:~$ " cmd9
    echo
    [[ "$cmd9" != "ls -lh /root/home_backup.tgz /root/home_backup.tar.bz2" ]] && {
        print_error "Use: ls -lh /root/home_backup.tgz /root/home_backup.tar.bz2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (sizes displayed)"
    echo

    # Step 10: Bonus — verify that /home was the archive root (optional check)
    echo "  Step 10 (bonus): Print the first path in the gzip archive to confirm root."
    echo "           Expected: tar -tzf $TGZ | head -n 1"
    read -p "  lab@lab186:~$ " cmd10
    echo
    [[ "$cmd10" != "tar -tzf /root/home_backup.tgz | head -n 1" ]] && {
        print_error "Use: tar -tzf /root/home_backup.tgz | head -n 1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (archive root confirmed)"
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
