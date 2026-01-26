#!/bin/bash

# Lab 490: Identify CPU / Memory Intensive Processes and Kill Them

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 490: Identify and Kill Resource-Intensive Processes"
LAB_ID="lab490"
LAB_XP=49000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab490:~$ "

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
  center_text "The system feels sluggish and unresponsive."
  center_text "Users report high CPU usage and memory pressure."
  center_text "You must identify the offending process and stop it."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Launch top
  echo "  Step 1: Launch a real-time process viewer."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "top" ]]; then
    print_error "Incorrect. Use top."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "top - 14:32:11 up 2 days,  3:41,  2 users,  load average: 2.91, 2.44, 1.87"
  echo "Tasks: 198 total,   2 running, 196 sleeping"
  echo "%Cpu(s): 92.3 us,  5.1 sy,  0.0 ni,  2.1 id"
  echo
  echo "  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND"
  echo " 2387 root      20   0  227156  17224   2496 R  91.8   4.3   2:11.09 stress"
  echo " 1421 examuser  20   0  614532  21832   3212 S   3.1   0.5   0:08.44 firefox"
  echo

  # STEP 2: Identify PID
  echo "  Step 2: Identify the PID of the CPU-intensive process."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "2387" ]]; then
    print_error "Incorrect. The stress process is PID 2387."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "PID 2387 identified."
  echo

  # STEP 3: Use ps to confirm CPU usage
  echo "  Step 3: Use ps to list top CPU-consuming processes."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6" ]]; then
    print_error "Incorrect command."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PID COMMAND         %CPU"
  echo " 2387 stress          91.8"
  echo " 1421 firefox          3.1"
  echo "  812 gnome-shell      2.4"
  echo "  402 Xorg             1.9"
  echo

  # STEP 4: Attempt graceful termination
  echo "  Step 4: Gracefully terminate the offending process."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo kill 2387" && "$cmd4" != "kill 2387" ]]; then
    print_error "Incorrect. Use kill <PID>."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Sent SIGTERM to process 2387."
  echo

  # STEP 5: Verify process still running
  echo "  Step 5: Verify whether the process is still running."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ps -p 2387" ]]; then
    print_error "Incorrect. Use ps -p <PID>."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PID TTY          TIME CMD"
  echo " 2387 ?        00:02:14 stress"
  echo

  # STEP 6: Force kill
  echo "  Step 6: Forcefully terminate the process."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo kill -9 2387" && "$cmd6" != "kill -9 2387" ]]; then
    print_error "Incorrect. Use kill -9 <PID>."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Process 2387 terminated with SIGKILL."
  echo

  # STEP 7: Confirm termination
  echo "  Step 7: Confirm the process is no longer running."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ps -p 2387" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PID TTY          TIME CMD"
  echo "  <no output>"
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA-critical performance skills:"
  print_info "- identifying CPU-heavy processes using top"
  print_info "- validating with ps and sorting"
  print_info "- terminating processes safely and forcefully"
  print_info "- understanding SIGTERM vs SIGKILL behavior"
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
