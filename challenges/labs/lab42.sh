#!/bin/bash

# Lab 42: One-Time Job Scheduling with at

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 42: One-Time Job Scheduling with at"
LAB_ID="lab42"
LAB_XP=21440
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
    center_text "A user requests that a heavy backup job run exactly once"
    center_text "at 2:30 AM tomorrow. You’ll use the at command to schedule"
    center_text "this and verify it’s queued properly."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Check if the 'atd' daemon is running."
    read -p "  lab@lpic-lab42:~\$ " cmd1
    echo
    [[ "$cmd1" != "systemctl status atd" ]] && {
        print_error "Incorrect. Use: systemctl status atd"
        read -p "Press Enter to try again..." _
        continue
    }
        echo "  ● atd.service - Deferred execution scheduler"
    echo "       Loaded: loaded (/lib/systemd/system/atd.service; enabled; vendor preset: enabled)"
    echo "       Active: active (running) since Tue 2025-07-22 09:41:37 UTC; 1h 23min ago"
    echo "         Docs: man:atd(8)"
    echo "     Main PID: 672 (atd)"
    echo "        Tasks: 1 (limit: 32768)"
    echo "       Memory: 1.1M"
    echo "          CPU: 14ms"
    echo "       CGroup: /system.slice/atd.service"
    echo "               └─672 /usr/sbin/atd -f"
    echo "  "
    echo "  Jul 22 09:41:37 lpic-lab42 systemd[1]: Started Deferred execution scheduler."
    echo "  Jul 22 10:15:01 lpic-lab42 atd[672]: Executing job 'a000010123.0'; mail to: root"
    echo "  Jul 22 10:15:01 lpic-lab42 atd[672]: Job 'a000010123.0' started"
    echo


    echo "  Step 2: Schedule a backup script for 2:30 AM tomorrow."
    echo "  (The script is located at /home/dev/backup.sh)"
    read -p "  lab@lpic-lab42:~\$ " cmd2
    echo
    [[ "$cmd2" != "echo '/home/dev/backup.sh' | at 2:30 AM tomorrow" ]] && {
        print_error "Incorrect. Pipe the command into: at 2:30 AM tomorrow"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 8 at Thu Jul 25 02:30:00 2025"
    echo

    echo "  Step 3: Verify that the job has been queued."
    read -p "  lab@lpic-lab42:~\$ " cmd3
    echo
    [[ "$cmd3" != "atq" ]] && {
        print_error "Incorrect. Use: atq"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  8  Thu Jul 25 02:30:00 2025 a vonds"
    echo

    echo "  Step 4: Check the contents of the queued job."
    read -p "  lab@lpic-lab42:~\$ " cmd4
    echo
    [[ "$cmd4" != "at -c 8" ]] && {
        print_error "Incorrect. Use: at -c 8"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  #!/bin/sh"
    echo "  # atrun uid=1000 gid=1000"
    echo "  # mail vonds 0"
    echo "  umask 22"
    echo "  cd /home/vonds || {"
    echo "    echo 'Execution directory inaccessible'; exit 1;"
    echo "  }"
    echo "  /home/dev/backup.sh"
    echo

    echo "  Step 5: Remove the job (simulate user cancellation)."
    read -p "  lab@lpic-lab42:~\$ " cmd5
    echo
    [[ "$cmd5" != "atrm 8" ]] && {
        print_error "Incorrect. Use: atrm 8"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Job 8 removed."
    echo

    print_success "Excellent work!"
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
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
