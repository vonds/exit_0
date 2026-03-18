#!/bin/bash

# Lab 541V: Manage Processes and Adjust Priority (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541V: Manage Processes and Adjust Priority"
LAB_ID="lab541v"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "A long-running background process has been started on ServerA."
  center_text "You must identify the process, adjust its scheduling priority,"
  center_text "and terminate it when finished."
  echo
  center_text "Tasks:"
  center_text "- Start a background sleep process"
  center_text "- Identify its PID"
  center_text "- Adjust its niceness to +5"
  center_text "- Kill the process"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Start a background process that sleeps for 1000 seconds."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sleep 1000 &" ]]; then
    print_error "Incorrect. Use: sleep 1000 &"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [1] 23841"
  echo


  echo "  Step 2: Identify the PID of the running sleep process."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "ps aux | grep sleep" ]]; then
    print_error "Incorrect. Use: ps aux | grep sleep"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  examuser   23841  0.0  0.1  2312  620 pts/0    S    10:22   0:00 sleep 1000"
  echo "  examuser   23845  0.0  0.0  2228  336 pts/0    S+   10:22   0:00 grep --color=auto sleep"
  echo


  echo "  Step 3: Adjust the niceness of the sleep process to +5."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "renice 5 -p 23841" ]]; then
    print_error "Incorrect. Use: renice 5 -p 23841"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  23841 (process ID) old priority 0, new priority 5"
  echo


  echo "  Step 4: Verify the updated process priority."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "ps -o pid,ni,cmd -p 23841" ]]; then
    print_error "Incorrect. Use: ps -o pid,ni,cmd -p 23841"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "    PID  NI CMD"
  echo "  23841   5 sleep 1000"
  echo


  echo "  Step 5: Terminate the running sleep process."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "kill 23841" ]]; then
    print_error "Incorrect. Use: kill 23841"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [1]+  Terminated              sleep 1000"
  echo


  echo "  Step 6: Confirm the process is no longer running."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "ps aux | grep sleep" ]]; then
    print_error "Incorrect. Use: ps aux | grep sleep"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  examuser   23890  0.0  0.0  2228  336 pts/0    S+   10:23   0:00 grep --color=auto sleep"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- started a background process"
  print_info "- identified the process ID"
  print_info "- adjusted process niceness"
  print_info "- verified process scheduling"
  print_info "- terminated the process"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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