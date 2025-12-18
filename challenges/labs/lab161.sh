#!/bin/bash

# Lab 161: systemd-run Transient Units & Timers (10 questions, realistic outputs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "  Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "  Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 161: systemd-run Transient Units & Timers"
LAB_ID="lab161"
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
    echo "  Practice creating transient services/scopes and timers with systemd-run."
    echo "  Use exact commands as prompted."
    echo
    echo "  Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Run a transient service that echoes 'hello' and wait for completion."
    echo "          Use unit name 'hello-job'."
    read -p "  root@lpic-lab161:~# " cmd1
    echo
    if [[ "$cmd1" != "systemd-run --unit=hello-job --wait /bin/echo hello" ]]; then
        echo "  Incorrect. Use: systemd-run --unit=hello-job --wait /bin/echo hello"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Running as unit: hello-job.service"
    echo "  hello"
    echo "  Finished with result: success"
    echo

    echo "  Step 2: Schedule a transient timer to run '/usr/bin/logger hi-from-timer' in 2 minutes."
    echo "          Use unit name 'notify-job'."
    read -p "  root@lpic-lab161:~# " cmd2
    echo
    if [[ "$cmd2" != "systemd-run --on-active=2min --unit=notify-job /usr/bin/logger hi-from-timer" ]]; then
        echo "  Incorrect. Use: systemd-run --on-active=2min --unit=notify-job /usr/bin/logger hi-from-timer"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Running timer as unit: notify-job.timer"
    echo "  Will run service: notify-job.service"
    echo

    echo "  Step 3: Create a transient timer to echo 'weekly' every Monday at 15:00."
    echo "          Use unit name 'weekly-task'."
    read -p "  root@lpic-lab161:~# " cmd3
    echo
    if [[ "$cmd3" != "systemd-run --on-calendar='Mon *-*-* 15:00:00' --unit=weekly-task /bin/echo weekly" ]]; then
        echo "  Incorrect. Use: systemd-run --on-calendar='Mon *-*-* 15:00:00' --unit=weekly-task /bin/echo weekly"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Running timer as unit: weekly-task.timer"
    echo "  Will run service: weekly-task.service"
    echo

    echo "  Step 4: As the current user, schedule '/bin/echo hi-user' for 10 seconds from now."
    echo "          Use unit name 'user-echo'."
    read -p "  lab@lpic-lab161:~$ " cmd4
    echo
    if [[ "$cmd4" != "systemd-run --user --on-active=10s --unit=user-echo /bin/echo hi-user" ]]; then
        echo "  Incorrect. Use: systemd-run --user --on-active=10s --unit=user-echo /bin/echo hi-user"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Running timer as unit: user-echo.timer"
    echo "  Will run service: user-echo.service"
    echo

    echo "  Step 5: Start a transient scope that limits memory to 200M while running 'sleep 60'."
    read -p "  root@lpic-lab161:~# " cmd5
    echo
    if [[ "$cmd5" != "systemd-run --scope -p MemoryMax=200M sleep 60" ]]; then
        echo "  Incorrect. Use: systemd-run --scope -p MemoryMax=200M sleep 60"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Running scope as unit: run-$(date +%s).scope"
    echo

    echo "  Step 6: Run a oneshot service that touches '/tmp/config.done' and remains active after exit."
    echo "          Use unit name 'config-touch'."
    read -p "  root@lpic-lab161:~# " cmd6
    echo
    if [[ "$cmd6" != "systemd-run --unit=config-touch --wait -p Type=oneshot -p RemainAfterExit=yes /usr/bin/touch /tmp/config.done" ]]; then
        echo "  Incorrect. Use: systemd-run --unit=config-touch --wait -p Type=oneshot -p RemainAfterExit=yes /usr/bin/touch /tmp/config.done"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Running as unit: config-touch.service"
    echo "  Finished with result: success"
    echo

    echo "  Step 7: Show the last 3 log lines for 'hello-job.service' (no pager)."
    read -p "  root@lpic-lab161:~# " cmd7
    echo
    if [[ "$cmd7" != "journalctl -u hello-job.service -n 3 --no-pager" ]]; then
        echo "  Incorrect. Use: journalctl -u hello-job.service -n 3 --no-pager"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Sep 14 12:00:01 host systemd[1]: Started hello-job.service - /bin/echo hello."
    echo "  Sep 14 12:00:01 host echo[12345]: hello"
    echo "  Sep 14 12:00:01 host systemd[1]: hello-job.service: Deactivated successfully."
    echo

    echo "  Step 8: List all timers and show next run times (system-wide)."
    read -p "  root@lpic-lab161:~# " cmd8
    echo
    if [[ "$cmd8" != "systemctl list-timers --all" ]]; then
        echo "  Incorrect. Use: systemctl list-timers --all"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  NEXT                        LEFT          LAST                        PASSED        UNIT                 ACTIVATES"
    echo "  Sun 2025-09-14 12:02:00     1min 30s left Sun 2025-09-14 11:59:00     30s ago       notify-job.timer     notify-job.service"
    echo "  Mon 2025-09-15 15:00:00     1 day left    n/a                         n/a           weekly-task.timer    weekly-task.service"
    echo "  n/a                         n/a           n/a                         n/a           timers.target        "
    echo

    echo "  Step 9: Stop the per-user timer 'user-echo.timer'."
    read -p "  lab@lpic-lab161:~$ " cmd9
    echo
    if [[ "$cmd9" != "systemctl --user stop user-echo.timer" ]]; then
        echo "  Incorrect. Use: systemctl --user stop user-echo.timer"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Stopped user-echo.timer."
    echo

    echo "  Step 10: Stop both 'notify-job.timer' and 'weekly-task.timer'."
    read -p "  root@lpic-lab161:~# " cmd10
    echo
    if [[ "$cmd10" != "systemctl stop notify-job.timer weekly-task.timer" ]]; then
        echo "  Incorrect. Use: systemctl stop notify-job.timer weekly-task.timer"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Stopped notify-job.timer."
    echo "  Stopped weekly-task.timer."
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
