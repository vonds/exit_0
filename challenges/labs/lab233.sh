#!/bin/bash

# Lab 233: at — schedule as user100, redirect output to /tmp/date.out (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real jobs, files, services, or users are changed.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 233: at (user100 → /tmp/date.out)"
LAB_ID="lab233"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated artifacts
AT_UNIT="atd"
SIM_USER="user100"
OUT_FILE="/tmp/date.out"
SIM_JOB_ID="10"
SIM_AT_TIME="Tue Jul 22 13:45:00 2025"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$LEVEL" "$(calculate_xp_to_next_level)"
  echo; echo; echo
}
record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}
get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

reset_state() {
  : # nothing persistent to reset in this simulation
}

while true; do
  reset_state

  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Goal: Queue a one-time at job under '${SIM_USER}' that writes the current date to ${OUT_FILE}."
  center_text "Then verify the queue, inspect the job's script, and confirm the output file."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Ensure the scheduler daemon is running (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check the ${AT_UNIT} service status."
  read -p "  lab@lab233:~$ " cmd1
  [[ "$cmd1" != "systemctl status atd" ]] && {
    print_error "Hint: Use the system service manager to view the 'at' daemon status."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  ● atd.service - Deferred execution scheduler"
  echo "       Loaded: loaded (/lib/systemd/system/atd.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 13:40:37 UTC; 1min 23s ago"
  echo "         Docs: man:atd(8)"
  echo "     Main PID: 672 (atd)"
  echo "        Tasks: 1 (limit: 32768)"
  echo "       Memory: 1.1M"
  echo "          CPU: 14ms"
  echo "       CGroup: /system.slice/atd.service"
  echo "               └─672 /usr/sbin/atd -f"
  echo

  # Step 2: Confirm target account exists (SIMULATED)
  echo "  Step 2: Verify the '${SIM_USER}' account."
  read -p "  lab@lab233:~$ " cmd2
  if [[ "$cmd2" == "id user100" ]]; then
    echo "uid=1003(user100) gid=1003(user100) groups=1003(user100)"
  elif [[ "$cmd2" == "getent passwd user100" ]]; then
    echo "user100:x:1003:1003::/home/user100:/bin/bash"
  else
    print_error "Hint: Use a standard user lookup command for '${SIM_USER}'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Queue a job under user100 that writes date to /tmp/date.out (SIMULATED)
  echo "  Step 3: Queue a near-future one-time job as '${SIM_USER}' that writes the current date to ${OUT_FILE}."
  read -p "  lab@lab233:~$ " cmd3
  # Accept common patterns: sudo/su/runuser to submit as user100, with at and date >> /tmp/date.out
  if [[ "$cmd3" =~ user100 ]] && [[ "$cmd3" =~ at[[:space:]] ]] && [[ "$cmd3" =~ date ]] && [[ "$cmd3" =~ "/tmp/date.out" ]]; then
    echo "job ${SIM_JOB_ID} at ${SIM_AT_TIME}"
  else
    print_error "Hint: Submit the at job *as ${SIM_USER}* and ensure it appends the current date to ${OUT_FILE}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify job is queued (SIMULATED)
  echo "  Step 4: List queued one-time jobs."
  read -p "  lab@lab233:~$ " cmd4
  [[ "$cmd4" != "atq" ]] && {
    print_error "Hint: Use the queue viewer for one-time jobs."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  ${SIM_JOB_ID}  ${SIM_AT_TIME} a ${SIM_USER}"
  echo

  # Step 5: Inspect the queued job’s script (SIMULATED)
  echo "  Step 5: Show the full queued job content."
  read -p "  lab@lab233:~$ " cmd5
  if [[ "$cmd5" == "at -c ${SIM_JOB_ID}" || "$cmd5" == "at -c 10" ]]; then
    echo "#!/bin/sh"
    echo "# atrun uid=1003 gid=1003"
    echo "# mail ${SIM_USER} 0"
    echo "umask 22"
    echo "cd /home/${SIM_USER} || { echo 'Execution directory inaccessible'; exit 1; }"
    echo "/usr/bin/date >> ${OUT_FILE}"
  else
    print_error "Hint: Use the command that dumps a queued job as a shell script."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: (Simulate time passing) Show daemon logs when the job runs (SIMULATED)
  echo "  Step 6: (Fast-forward) The scheduled time arrives; review recent ${AT_UNIT} logs."
  read -p "  lab@lab233:~$ " cmd6
  if [[ "$cmd6" == "journalctl -u atd -n 3 --no-pager" || "$cmd6" == "sudo journalctl -u atd -n 3 --no-pager" ]]; then
    echo "  Jul 22 13:45:00 lab233 atd[672]: Executing job 'a000010123.0'; mail to: ${SIM_USER}"
    echo "  Jul 22 13:45:00 lab233 atd[672]: Job 'a000010123.0' started"
    echo "  Jul 22 13:45:00 lab233 atd[672]: Job 'a000010123.0' done"
  else
    print_error "Hint: View the last few journal lines for the at daemon."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Verify output file exists and contains a date line (SIMULATED)
  echo "  Step 7: Verify ${OUT_FILE} was written."
  read -p "  lab@lab233:~$ " cmd7
  if [[ "$cmd7" == "cat /tmp/date.out" ]]; then
    echo "Tue Jul 22 13:45:00 UTC 2025"
  elif [[ "$cmd7" == "ls -l /tmp/date.out" ]]; then
    echo "-rw-r--r-- 1 ${SIM_USER} ${SIM_USER} 29 Jul 22 13:45 /tmp/date.out"
  elif [[ "$cmd7" == "tail -n1 /tmp/date.out" ]]; then
    echo "Tue Jul 22 13:45:00 UTC 2025"
  else
    print_error "Hint: Use a command that proves ${OUT_FILE} exists (and shows its contents or metadata)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Confirm the at queue is empty now (SIMULATED)
  echo "  Step 8: Check the at queue again."
  read -p "  lab@lab233:~$ " cmd8
  [[ "$cmd8" != "atq" ]] && {
    print_error "Hint: Re-list the at queue after execution."
    read -p "Press Enter to try again..." _
    continue
  }
  # (no output when empty)
  echo

  print_success "Great job! You scheduled a one-time at job under ${SIM_USER} and verified output at ${OUT_FILE} (simulated)."
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
