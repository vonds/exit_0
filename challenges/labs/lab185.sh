#!/bin/bash

# Lab 185: Filter Log Messages and Archive /var/log (Essential Tools)
# Objective: Extract ACPI-related messages to /root/logs, verify output, and archive /var/log to /tmp/log_archive.tgz.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 185: Filter Log Messages and Archive /var/log"
LAB_ID="lab185"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

LOG_SOURCE="/var/log/messages"
OUT_DIR="/root/logs"
OUT_FILE="$OUT_DIR/acpi_messages.txt"
ARCHIVE="/tmp/log_archive.tgz"

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
    center_text "Goal: Extract ACPI messages to $OUT_FILE and create a gzip archive of /var/log at $ARCHIVE."
    center_text "Tip: Use grep for filtering and tar -czf for creating a .tgz archive."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # Step 1: Create output directory
    draw_lab_ui
    echo "  Step 1: Create the output directory $OUT_DIR if it does not exist."
    echo "          Expected: mkdir -p $OUT_DIR"
    read -p "  lab@lab185:~$ " cmd1
    echo
    [[ "$cmd1" != "mkdir -p /root/logs" ]] && {
        print_error "Use: mkdir -p /root/logs"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ($OUT_DIR ensured)"
    echo

    # Step 2: Filter ACPI messages to file
    echo "  Step 2: Extract lines containing ACPI from $LOG_SOURCE and write them to $OUT_FILE."
    echo "          Ignore read errors from grep if any."
    echo "          Expected: grep -F \"ACPI\" $LOG_SOURCE > $OUT_FILE"
    read -p "  lab@lab185:~$ " cmd2
    echo
    [[ "$cmd2" != "grep -F \"ACPI\" /var/log/messages > /root/logs/acpi_messages.txt" ]] && {
        print_error "Use: grep -F \"ACPI\" /var/log/messages > /root/logs/acpi_messages.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (ACPI messages saved to $OUT_FILE)"
    echo

    # Step 3: Preview first 3 lines
    echo "  Step 3: Show the first 3 lines of $OUT_FILE."
    read -p "  lab@lab185:~$ " cmd3
    echo
    [[ "$cmd3" != "head -n 3 /root/logs/acpi_messages.txt" ]] && {
        print_error "Use: head -n 3 /root/logs/acpi_messages.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (preview displayed)"
    echo

    # Step 4: Count matches
    echo "  Step 4: Print the total number of ACPI lines saved."
    read -p "  lab@lab185:~$ " cmd4
    echo
    [[ "$cmd4" != "wc -l /root/logs/acpi_messages.txt" ]] && {
        print_error "Use: wc -l /root/logs/acpi_messages.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (count displayed)"
    echo

    # Step 5: Create a gzip archive of /var/log
    echo "  Step 5: Create a gzip-compressed archive of /var/log and save it to $ARCHIVE."
    echo "          Expected: tar -czf $ARCHIVE /var/log"
    read -p "  lab@lab185:~$ " cmd5
    echo
    [[ "$cmd5" != "tar -czf /tmp/log_archive.tgz /var/log" ]] && {
        print_error "Use: tar -czf /tmp/log_archive.tgz /var/log"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (archive created at $ARCHIVE)"
    echo

    # Step 6: Verify archive contents
    echo "  Step 6: List a few entries from the archive to verify contents."
    echo "          Expected: tar -tzf $ARCHIVE | head -n 5"
    read -p "  lab@lab185:~$ " cmd6
    echo
    [[ "$cmd6" != "tar -tzf /tmp/log_archive.tgz | head -n 5" ]] && {
        print_error "Use: tar -tzf /tmp/log_archive.tgz | head -n 5"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (archive contents previewed)"
    echo

    # Step 7: Show archive size
    echo "  Step 7: Show the size of $ARCHIVE in human-readable form."
    read -p "  lab@lab185:~$ " cmd7
    echo
    [[ "$cmd7" != "ls -lh /tmp/log_archive.tgz" ]] && {
        print_error "Use: ls -lh /tmp/log_archive.tgz"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (archive size displayed)"
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
