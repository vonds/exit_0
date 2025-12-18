#!/bin/bash

# Lab 229: at — delayed script creation (/testresults/Hello.sh) (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real jobs, files, or services are changed. A simulated flow is shown.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 229: One-time scheduling with at — create /testresults/Hello.sh"
LAB_ID="lab229"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

AT_SVC="atd"
TARGET_DIR="/testresults"
TARGET_FILE="/testresults/Hello.sh"
SIM_USER="labuser"
SIM_JOB_ID="9"
SIM_AT_TIME="Tue Jul 22 13:05:00 2025"

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
  center_text "Goal: Queue a one-time job that, after a short delay, creates ${TARGET_FILE} (simulated)."
  center_text "Then inspect the queue, review the job’s script, and verify the file appears."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Ensure the scheduler daemon is running
  draw_lab_ui
  echo "  Step 1: Check the ${AT_SVC} service status."
  read -p "  lab@lab229:~$ " cmd1
  [[ "$cmd1" != "systemctl status atd" ]] && {
    print_error "Hint: Use the system service status tool for the at daemon."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  ● atd.service - Deferred execution scheduler"
  echo "       Loaded: loaded (/lib/systemd/system/atd.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 12:58:37 UTC; 1min 23s ago"
  echo "         Docs: man:atd(8)"
  echo "     Main PID: 672 (atd)"
  echo "        Tasks: 1 (limit: 32768)"
  echo "       Memory: 1.1M"
  echo "          CPU: 14ms"
  echo "       CGroup: /system.slice/atd.service"
  echo "               └─672 /usr/sbin/atd -f"
  echo

  # Step 2: Prepare destination directory
  echo "  Step 2: Create the destination directory for the future script."
  read -p "  lab@lab229:~$ " cmd2
  if [[ "$cmd2" != "sudo mkdir -p /testresults" && "$cmd2" != "mkdir -p /testresults" ]]; then
    print_error "Hint: Ensure ${TARGET_DIR} exists before the job runs."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Queue a one-time job that will create the script later
  echo "  Step 3: Queue a one-time job in the near future to create ${TARGET_FILE}."
  read -p "  lab@lab229:~$ " cmd3
  # Accept any variant that pipes a command containing Hello.sh into `at` with a future time
  if [[ "$cmd3" =~ \|[[:space:]]*at[[:space:]]+now[[:space:]]+\+ && "$cmd3" == *"Hello.sh"* ]]; then
    echo "job ${SIM_JOB_ID} at ${SIM_AT_TIME}"
  else
    print_error "Hint: Pipe a command into the scheduler for a time like: now + 1 minute (ensure it references Hello.sh)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify the job is queued
  echo "  Step 4: List queued one-time jobs."
  read -p "  lab@lab229:~$ " cmd4
  [[ "$cmd4" != "atq" ]] && {
    print_error "Hint: Use the queue viewer for one-time jobs."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  ${SIM_JOB_ID}  ${SIM_AT_TIME} a ${SIM_USER}"
  echo

  # Step 5: Inspect the queued job’s script
  echo "  Step 5: Show the full queued job content."
  read -p "  lab@lab229:~$ " cmd5
  [[ "$cmd5" != "at -c 9" && "$cmd5" != "at -c ${SIM_JOB_ID}" ]] && {
    print_error "Hint: Use the command that dumps the queued job’s shell script."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "#!/bin/sh"
  echo "# atrun uid=1000 gid=1000"
  echo "# mail ${SIM_USER} 0"
  echo "umask 22"
  echo "cd /home/${SIM_USER} || { echo 'Execution directory inaccessible'; exit 1; }"
  echo "mkdir -p ${TARGET_DIR}"
  echo "printf '#!/bin/bash\necho Hello from at\n' > ${TARGET_FILE}"
  echo "chmod +x ${TARGET_FILE}"
  echo

  # Step 6: (Simulate time passing) Show scheduler log lines for job execution
  echo "  Step 6: (Fast-forward) The scheduled time arrives; the daemon executes the job."
  read -p "  lab@lab229:~$ " cmd6
  [[ "$cmd6" != "journalctl -u atd -n 3 --no-pager" && "$cmd6" != "sudo journalctl -u atd -n 3 --no-pager" ]] && {
    print_error "Hint: Review recent service log lines for the scheduler."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Jul 22 13:05:00 lab229 atd[672]: Executing job 'a000009123.0'; mail to: ${SIM_USER}"
  echo "  Jul 22 13:05:00 lab229 atd[672]: Job 'a000009123.0' started"
  echo "  Jul 22 13:05:00 lab229 atd[672]: Job 'a000009123.0' done"
  echo

  # Step 7: Verify the script file now exists
  echo "  Step 7: Verify the created script is present and executable."
  read -p "  lab@lab229:~$ " cmd7
  if [[ "$cmd7" == "ls -l /testresults/Hello.sh" ]]; then
    echo "-rwxr-xr-x 1 ${SIM_USER} ${SIM_USER} 34 Jul 22 13:05 /testresults/Hello.sh"
  elif [[ "$cmd7" == "file /testresults/Hello.sh" ]]; then
    echo "/testresults/Hello.sh: Bourne-Again shell script, ASCII text executable"
  else
    print_error "Hint: Use a command to check presence/permissions of ${TARGET_FILE}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Execute the script
  echo "  Step 8: Run the script to confirm its behavior."
  read -p "  lab@lab229:~$ " cmd8
  if [[ "$cmd8" == "/testresults/Hello.sh" || "$cmd8" == "bash /testresults/Hello.sh" ]]; then
    echo "Hello from at"
  else
    print_error "Hint: Execute the newly created script."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 9: Confirm the queue is now empty (job consumed)
  echo "  Step 9: Check the one-time job queue again."
  read -p "  lab@lab229:~$ " cmd9
  [[ "$cmd9" != "atq" ]] && {
    print_error "Hint: Re-list the at queue."
    read -p "Press Enter to try again..." _
    continue
  }
  # (No output when no jobs are queued)
  echo

  print_success "Great job! You scheduled a one-time job with at, inspected it, and verified it ran (simulated)."
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
