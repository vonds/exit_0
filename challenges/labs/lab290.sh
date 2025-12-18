#!/bin/bash

# Lab 290: Filesystem Maintenance & Tuning (Safety-first recovery)
# Scenario: A filesystem shows increasing mount counts and a recent unclean shutdown.
#           Inspect mount-count settings, run a safe dry-run check, perform repairs in maintenance,
#           and tune mount-count policy. This lab emphasizes safety: preview with fsck -n before -y.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 290: Filesystem Maintenance & Tuning"
LAB_ID="lab290"
LAB_XP=1800
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

# NOTE: This lab assumes a test device /dev/loop2 is available for safe operations.
# In a real environment, replace /dev/loop2 with the correct device and ensure backups exist.

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Inspect a filesystem's mount counts, run a non-destructive check, perform repairs if authorized, and tune fsck policy."
    center_text "Use the commands provided in prompts. sudo variants are accepted."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1
    echo "  Step 1: Check mount count and maximum mount count for /dev/loop2."
    echo "          Use: sudo tune2fs -l /dev/loop2 | egrep 'Mount count|Maximum mount count'"
    read -p "  lab@lab290:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo tune2fs -l /dev/loop2 | egrep 'Mount count|Maximum mount count'" && \
          "$cmd1" != "tune2fs -l /dev/loop2 | egrep 'Mount count|Maximum mount count'" ]]; then
        print_error "Incorrect. Expected: sudo tune2fs -l /dev/loop2 | egrep 'Mount count|Maximum mount count'"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Mount count:              27"
    echo "  Maximum mount count:      30"
    echo

    # Step 2
    echo "  Step 2: Run a non-destructive filesystem check (preview)."
    echo "          Use: sudo fsck -n /dev/loop2"
    read -p "  lab@lab290:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo fsck -n /dev/loop2" && "$cmd2" != "fsck -n /dev/loop2" ]]; then
        print_error "Incorrect. Expected: sudo fsck -n /dev/loop2"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  fsck from util-linux 2.36.1"
    echo "  e2fsck 1.45.5 (07-Jan-2020)"
    echo "  Pass 1: Checking inodes..."
    echo "  Pass 2: Checking blocks..."
    echo "  Pass 3: Checking directory structure..."
    echo "  Pass 4: Checking directory connectivity..."
    echo "  Pass 5: Checking group summary information..."
    echo "  WARNING: Filesystem has errors but -n was specified; no changes will be made."
    echo "  The following fixes would be performed:"
    echo "   - Reclaimed 3 inodes"
    echo "   - Cleared orphaned inode 12345"
    echo

    # Step 3
    echo "  Step 3: If you have a verified backup and are in a maintenance window, run automatic repairs."
    echo "          Use: sudo fsck -y /dev/loop2"
    read -p "  lab@lab290:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo fsck -y /dev/loop2" && "$cmd3" != "fsck -y /dev/loop2" ]]; then
        print_error "Incorrect. Expected: sudo fsck -y /dev/loop2"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  fsck from util-linux 2.36.1"
    echo "  e2fsck 1.45.5 (07-Jan-2020)"
    echo "  Pass 1: Checking inodes..."
    echo "  Inode 12345 was part of the orphan list.  Fix<y>? yes"
    echo "  Pass 2: Checking blocks..."
    echo "  Pass 3: Checking directory structure..."
    echo "  Pass 4: Checking directory connectivity..."
    echo "  Pass 5: Checking group summary information..."
    echo "  /dev/loop2: ***** FILE SYSTEM WAS MODIFIED *****"
    echo

    # Step 4
    echo "  Step 4: Set the maximum mount count to 10 to force fsck periodically."
    echo "          Use: sudo tune2fs -c 10 /dev/loop2"
    read -p "  lab@lab290:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo tune2fs -c 10 /dev/loop2" && "$cmd4" != "tune2fs -c 10 /dev/loop2" ]]; then
        print_error "Incorrect. Expected: sudo tune2fs -c 10 /dev/loop2"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  tune2fs 1.45.5 (07-Jan-2020)"
    echo "  Setting maximum mount count to 10 for /dev/loop2."
    echo

    # Step 5
    echo "  Step 5: Verify the updated maximum mount count."
    echo "          Use: sudo tune2fs -l /dev/loop2 | grep 'Maximum mount count'"
    read -p "  lab@lab290:~$ " cmd5
    echo
    if [[ "$cmd5" != "sudo tune2fs -l /dev/loop2 | grep 'Maximum mount count'" && \
          "$cmd5" != "tune2fs -l /dev/loop2 | grep 'Maximum mount count'" ]]; then
        print_error "Incorrect. Expected: sudo tune2fs -l /dev/loop2 | grep 'Maximum mount count'"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Maximum mount count:      10"
    echo

    # Step 6 (Concrete explanation expected)
    echo "  Step 6: Why did we run fsck -n before fsck -y? Provide the concise reason (one short sentence)."
    echo "          Acceptable answers should include one of: 'preview', 'no changes', 'dry run', or 'non-destructive'."
    read -p "  lab@lab290:~$ " cmd6
    echo
    lower_cmd6=$(echo "$cmd6" | tr '[:upper:]' '[:lower:]')
    if [[ "$lower_cmd6" == *"preview"* || "$lower_cmd6" == *"no change"* || "$lower_cmd6" == *"dry run"* || \
          "$lower_cmd6" == *"non-destruct"* || "$lower_cmd6" == *"non destructive"* ]]; then
        echo "  Accepted explanation."
    else
        print_error "Answer not recognized. Mention that -n performs a preview / dry run (no changes) before making repairs with -y."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # Completion
    print_success "Lab complete: inspected mount counts, previewed fsck, performed repairs, and tuned mount-count policy."
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    echo "Completed: $completion_count time(s)"
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
