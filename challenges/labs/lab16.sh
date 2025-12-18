#!/bin/bash

# Lab 16: Process Management and Job Control

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 16: Process Management and Job Control"
LAB_ID="lab16"
LAB_XP=23320
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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Your system is running slowly. Identify resource-hungry processes,"
  center_text "stop runaway jobs, and manage process priorities using standard tools."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1 (interactive): Baseline snapshot with ps
  echo "  Step 1: Show the first few processes with CPU/memory columns."
  read -p "  lab@lpic-lab16:~$ " cmd1
  echo
  if [[ "$cmd1" != "ps aux | head -n 5" && "$cmd1" != "ps aux | head -5" && "$cmd1" != "ps aux | head -5" ]]; then
    print_error "Incorrect. Try: ps aux | head -n 5"
    read -p "Press Enter to try again..." _
    continue
  fi

  # Realistic ps output (trimmed)
  echo "  USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
  echo "  root         1  0.0  0.1 167936  1104 ?        Ss   Jul18   0:02 /sbin/init"
  echo "  root       402  0.1  0.3  98720  3128 ?        Ss   08:01   0:00 /lib/systemd/systemd-journald"
  echo "  root       711  0.0  0.2  72960  2140 ?        Ss   08:01   0:00 /usr/sbin/cron -f"
  echo "  lab       1357 25.3  4.1 248112 42280 ?        Rl   12:45   1:37 /usr/bin/python3 script.py"
  echo

  # STEP 2 (interactive): Live view with top; show realistic snapshot instead of placeholder
  echo "  Step 2: Launch an interactive live view of running processes."
  read -p "  lab@lpic-lab16:~$ " cmd2
  echo
  if [[ "$cmd2" != "top" ]]; then
    print_error "Incorrect. Use: top"
    read -p "Press Enter to try again..." _
    continue
  fi

  # Simulated 'top' snapshot (first ~10 lines)
  echo "  top - 12:48:33 up  2:47,  1 user,  load average: 2.23, 2.10, 1.76"
  echo "  Tasks: 188 total,   2 running, 186 sleeping,   0 stopped,   0 zombie"
  echo "  %Cpu(s): 38.6 us,  3.1 sy,  0.0 ni, 57.9 id,  0.1 wa,  0.0 hi,  0.3 si,  0.0 st"
  echo "  MiB Mem :   7860.0 total,   1180.5 free,   2387.2 used,   4292.3 buff/cache"
  echo "  MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   4970.1 avail Mem "
  echo
  echo "    PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND"
  echo "   1357 lab       20   0  248.1m  41.3m   5.1m R  98.3  0.5   1:39.21 python3"
  echo "    711 root      20   0   71.2m   2.1m   1.0m S   0.3  0.0   0:00.11 cron"
  echo "    978 root      20   0  130.4m   6.2m   3.3m S   0.3  0.1   0:03.47 systemd-journal"
  echo "   1630 lab       20   0  101.0m   3.8m   2.4m S   0.3  0.0   0:00.45 top"
  echo "  (Press 'q' to quit top)"
  echo

  # STEP 3 (interactive): Kill the heavy process
  echo "  Step 3: Terminate the runaway python process with PID 1357."
  read -p "  lab@lpic-lab16:~$ " cmd3
  echo
  if [[ "$cmd3" != "kill 1357" && "$cmd3" != "sudo kill 1357" && "$cmd3" != "kill -15 1357" ]]; then
    print_error "Incorrect. Use: kill 1357 (SIGTERM)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  bash: sent SIGTERM to PID 1357"
  echo

  # STEP 4 (interactive): Show background jobs
  echo "  Step 4: Show only the background jobs in your current shell."
  read -p "  lab@lpic-lab16:~$ " cmd4
  echo
  if [[ "$cmd4" != "jobs" ]]; then
    print_error "Incorrect. Use: jobs"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  [1]-  Running                 ./bigjob.sh &"
  echo

  # STEP 5 (interactive): Bring job to foreground
  echo "  Step 5: Bring the background job back to the foreground."
  read -p "  lab@lpic-lab16:~$ " cmd5
  echo
  if [[ "$cmd5" != "fg" && "$cmd5" != "fg %1" ]]; then
    print_error "Incorrect. Use: fg (or 'fg %1' to target job 1)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ./bigjob.sh"
  echo "  (running in foreground; press Ctrl+Z to background)"
  echo

  # STEP 6 (interactive): Run a command with lower priority
  echo "  Step 6: Run a script with lower CPU scheduling priority (higher nice value)."
  read -p "  lab@lpic-lab16:~$ " cmd6
  echo
  if [[ "$cmd6" != "nice -n 10 ./backup.sh" && "$cmd6" != "nice -10 ./backup.sh" ]]; then
    print_error "Incorrect. Example: nice -n 10 ./backup.sh"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  started './backup.sh' with nice value +10 (lower priority)"
  echo

  print_success "Excellent!"
  print_info "You captured a snapshot with ps, inspected live processes with top,"
  print_info "terminated a runaway process, managed jobs in the shell, and used nice to adjust priority."
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
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
