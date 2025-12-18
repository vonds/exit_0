#!/bin/bash

# Lab 160: atrm Remove Scheduled Jobs (10 questions, realistic outputs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "  Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "  Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 160: atrm Remove Scheduled Jobs"
LAB_ID="lab160"
LAB_XP=20000
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
    echo "  Practice removing jobs from the at queue with atrm."
    echo "  Use exact commands as prompted."
    echo
    echo "  Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View the current queue before deleting jobs."
    read -p "  lab@lpic-lab160:~$ " cmd1
    echo
    if [[ "$cmd1" != "atq" ]]; then
        echo "  Incorrect. Use: atq"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  7  Sun Sep 14 20:30:00 2025 a lab"
    echo "  8  Sun Sep 14 21:00:00 2025 a lab"
    echo "  9  Sun Sep 14 22:00:00 2025 a lab"
    echo

    echo "  Step 2: Remove job 7 from the queue."
    read -p "  lab@lpic-lab160:~$ " cmd2
    echo
    if [[ "$cmd2" != "atrm 7" ]]; then
        echo "  Incorrect. Use: atrm 7"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Job 7 removed from the at queue."
    echo

    echo "  Step 3: Verify job 7 is no longer listed."
    read -p "  lab@lpic-lab160:~$ " cmd3
    echo
    if [[ "$cmd3" != "atq" ]]; then
        echo "  Incorrect. Use: atq"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  8  Sun Sep 14 21:00:00 2025 a lab"
    echo "  9  Sun Sep 14 22:00:00 2025 a lab"
    echo

    echo "  Step 4: Remove job 8 from the queue."
    read -p "  lab@lpic-lab160:~$ " cmd4
    echo
    if [[ "$cmd4" != "atrm 8" ]]; then
        echo "  Incorrect. Use: atrm 8"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Job 8 removed from the at queue."
    echo

    echo "  Step 5: Verify the queue after removing job 8."
    read -p "  lab@lpic-lab160:~$ " cmd5
    echo
    if [[ "$cmd5" != "atq" ]]; then
        echo "  Incorrect. Use: atq"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  9  Sun Sep 14 22:00:00 2025 a lab"
    echo

    echo "  Step 6: Remove job 9 from the queue."
    read -p "  lab@lpic-lab160:~$ " cmd6
    echo
    if [[ "$cmd6" != "atrm 9" ]]; then
        echo "  Incorrect. Use: atrm 9"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Job 9 removed from the at queue."
    echo

    echo "  Step 7: Verify the queue is now empty."
    read -p "  lab@lpic-lab160:~$ " cmd7
    echo
    if [[ "$cmd7" != "atq" ]]; then
        echo "  Incorrect. Use: atq"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  (no output – the queue is empty)"
    echo

    echo "  Step 8: Submit a job 'echo Hello' for tomorrow at 09:00 and show it in atq."
    read -p "  lab@lpic-lab160:~$ " cmd8
    echo
    if [[ "$cmd8" != "echo echo Hello | at 9:00 AM tomorrow" ]]; then
        echo "  Incorrect. Example: echo echo Hello | at 9:00 AM tomorrow"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  job 10 at Mon Sep 15 09:00:00 2025"
    echo "  atq output:"
    echo "  10  Mon Sep 15 09:00:00 2025 a lab"
    echo

    echo "  Step 9: Remove job 10 using atrm."
    read -p "  lab@lpic-lab160:~$ " cmd9
    echo
    if [[ "$cmd9" != "atrm 10" ]]; then
        echo "  Incorrect. Use: atrm 10"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Job 10 removed from the at queue."
    echo

    echo "  Step 10: Verify the queue is empty again."
    read -p "  lab@lpic-lab160:~$ " cmd10
    echo
    if [[ "$cmd10" != "atq" ]]; then
        echo "  Incorrect. Use: atq"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  (no output – the queue is empty)"
    echo

    echo "  Excellent work!"
    echo "  You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    echo "  You've successfully completed this lab $completion_count time(s)."
    echo
    echo "  Would you like to:"
    echo "  1) Retry this lab"
    echo "  2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
