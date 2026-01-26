#!/bin/bash

# Lab 491: Adjust Process Scheduling (nice / renice)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 491: Adjust Process Scheduling (nice/renice)"
LAB_ID="lab491"
LAB_XP=49100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab491:~$ "

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
  center_text "Scenario:"
  center_text "A batch job is consuming CPU during business hours."
  center_text "You need to lower its priority so interactive services stay responsive."
  center_text "Then you must boost priority for a critical process."
  echo
  center_text "Policy:"
  center_text "- Use nice/renice only (no cgroups for this task)."
  center_text "- Verify using ps output (NI/PRI)."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Start a CPU load with low priority (nice 10)
  echo "  Step 1: Start a CPU-intensive job at LOWER priority (nice value 10)."
  echo "          (This simulates a background batch job.)"
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "nice -n 10 stress --cpu 2" ]]; then
    print_error "Incorrect. Use: nice -n 10 stress --cpu 2"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "stress: info: [3127] dispatching hogs: 2 cpu, 0 io, 0 vm, 0 hdd"
  echo

  # STEP 2: Verify with ps showing NI/PRI
  echo "  Step 2: Verify niceness and priority for the stress process (use ps)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ps -eo pid,comm,ni,pri --sort=-%cpu | head -n 10" && \
        "$cmd2" != "ps -eo pid,comm,ni,pri | grep stress" ]]; then
    print_error "Incorrect. Use a ps command that shows pid/comm/ni/pri (then confirm stress)."
    read -p "Press Enter to try again..." _
    continue
  fi

  # realistic ps snapshot (not perfect, but plausible on RHEL)
  echo "  PID COMMAND          NI PRI"
  echo " 3127 stress           10  30"
  echo " 3128 stress           10  30"
  echo

  # STEP 3: Identify PID of main stress worker to renice
  echo "  Step 3: You need to adjust the running job. Choose a PID to modify (use 3127)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "3127" ]]; then
    print_error "Incorrect. Use PID 3127 for this lab."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "PID 3127 selected."
  echo

  # STEP 4: Lower priority further (renice 15)
  echo "  Step 4: Lower the priority further by setting nice to 15 for PID 3127."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo renice 15 -p 3127" && "$cmd4" != "renice 15 -p 3127" ]]; then
    print_error "Incorrect. Use: sudo renice 15 -p 3127"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "3127 (process ID) old priority 30, new priority 35"
  echo

  # STEP 5: Verify new NI/PRI
  echo "  Step 5: Verify PID 3127 now has nice 15 (and updated PRI)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ps -p 3127 -o pid,comm,ni,pri" ]]; then
    print_error "Incorrect. Use: ps -p 3127 -o pid,comm,ni,pri"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PID COMMAND          NI PRI"
  echo " 3127 stress           15  35"
  echo

  # STEP 6: Start a critical job at higher priority (negative nice requires sudo)
  echo "  Step 6: Start a second CPU job at HIGHER priority (nice value -5)."
  echo "          (This simulates a critical service workload.)"
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo nice -n -5 stress --cpu 1" ]]; then
    print_error "Incorrect. Negative nice requires sudo: sudo nice -n -5 stress --cpu 1"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "stress: info: [3199] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd"
  echo

  # STEP 7: Verify both stress groups show different nice values
  echo "  Step 7: Verify both stress workloads show different NI values."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ps -C stress -o pid,comm,ni,pri --sort=ni" ]]; then
    print_error "Incorrect. Use: ps -C stress -o pid,comm,ni,pri --sort=ni"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PID COMMAND          NI PRI"
  echo " 3199 stress           -5  15"
  echo " 3127 stress           15  35"
  echo " 3128 stress           10  30"
  echo

  # STEP 8: Clean up - kill stress processes by name
  echo "  Step 8: Cleanup: terminate the stress processes."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo pkill stress" && "$cmd8" != "sudo killall stress" ]]; then
    print_error "Incorrect. Use: sudo pkill stress (or sudo killall stress)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "(no output)"
  echo

  # STEP 9: Verify stress is gone
  echo "  Step 9: Verify there are no stress processes left."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "pgrep -a stress" ]]; then
    print_error "Incorrect. Use: pgrep -a stress"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "(no output)"
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA scheduling control:"
  print_info "- started processes with custom niceness using nice"
  print_info "- changed priority of a running process using renice"
  print_info "- verified NI/PRI with ps"
  print_info "- used sudo correctly for negative nice values"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done
