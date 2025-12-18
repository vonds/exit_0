#!/bin/bash

# Lab 199: Background jobs (dd), nice/renice, kill (Operate Running Systems)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 199: Jobs, Nice/Renice, Kill"
LAB_ID="lab199"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated PIDs for the three dd jobs
PID1=4011
PID2=4012
PID3=4013

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
  center_text "Goal: Start 3 background dd jobs, adjust niceness with renice (incl. -15), then kill them."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Start dd #1 in background
  draw_lab_ui
  echo "  Step 1: Start first dd job in background."
  echo "          Expected: dd if=/dev/zero of=/dev/null &"
  read -p "  lab@lab199:~$ " s1
  [[ "$s1" != "dd if=/dev/zero of=/dev/null &" ]] && { print_error "Use: dd if=/dev/zero of=/dev/null &"; read -p "Press Enter to try again..." _; continue; }
  echo "[1] $PID1"
  echo

  # Step 2: Start dd #2 in background
  echo "  Step 2: Start second dd job in background."
  echo "          Expected: dd if=/dev/zero of=/dev/null &"
  read -p "  lab@lab199:~$ " s2
  [[ "$s2" != "dd if=/dev/zero of=/dev/null &" ]] && { print_error "Use: dd if=/dev/zero of=/dev/null &"; read -p "Press Enter to try again..." _; continue; }
  echo "[2] $PID2"
  echo

  # Step 3: Start dd #3 in background
  echo "  Step 3: Start third dd job in background."
  echo "          Expected: dd if=/dev/zero of=/dev/null &"
  read -p "  lab@lab199:~$ " s3
  [[ "$s3" != "dd if=/dev/zero of=/dev/null &" ]] && { print_error "Use: dd if=/dev/zero of=/dev/null &"; read -p "Press Enter to try again..." _; continue; }
  echo "[3] $PID3"
  echo

  # Step 4: Show dd processes with niceness
  echo "  Step 4: List dd PIDs with niceness."
  echo "          Expected: ps -o pid,ni,comm -C dd"
  read -p "  lab@lab199:~$ " s4
  [[ "$s4" != "ps -o pid,ni,comm -C dd" ]] && { print_error "Use: ps -o pid,ni,comm -C dd"; read -p "Press Enter to try again..." _; continue; }
  echo "  PID  NI COMMAND"
  echo " $PID1   0 dd"
  echo " $PID2   0 dd"
  echo " $PID3   0 dd"
  echo

  # Step 5: Increase niceness (lower priority) of one process
  echo "  Step 5: Increase niceness of $PID2 by 10."
  echo "          Expected: renice -n 10 -p $PID2"
  read -p "  lab@lab199:~$ " s5
  [[ "$s5" != "renice -n 10 -p $PID2" ]] && { print_error "Use: renice -n 10 -p $PID2"; read -p "Press Enter to try again..." _; continue; }
  echo "$PID2 (process ID) old priority 0, new priority 10"
  echo

  # Step 6: Verify niceness applied
  echo "  Step 6: Confirm new niceness."
  echo "          Expected: ps -o pid,ni,comm -C dd"
  read -p "  lab@lab199:~$ " s6
  [[ "$s6" != "ps -o pid,ni,comm -C dd" ]] && { print_error "Use: ps -o pid,ni,comm -C dd"; read -p "Press Enter to try again..." _; continue; }
  echo "  PID  NI COMMAND"
  echo " $PID1   0 dd"
  echo " $PID2  10 dd"
  echo " $PID3   0 dd"
  echo

  # Step 7: Change priority to -15 (higher priority) on same PID
  echo "  Step 7: Change niceness of $PID2 to -15."
  echo "          Expected: renice -n -15 -p $PID2"
  read -p "  lab@lab199:~$ " s7
  [[ "$s7" != "renice -n -15 -p $PID2" ]] && { print_error "Use: renice -n -15 -p $PID2"; read -p "Press Enter to try again..." _; continue; }
  echo "$PID2 (process ID) old priority 10, new priority -15"
  echo

  # Step 8: Verify again
  echo "  Step 8: Confirm niceness is now -15."
  echo "          Expected: ps -o pid,ni,comm -C dd"
  read -p "  lab@lab199:~$ " s8
  [[ "$s8" != "ps -o pid,ni,comm -C dd" ]] && { print_error "Use: ps -o pid,ni,comm -C dd"; read -p "Press Enter to try again..." _; continue; }
  echo "  PID  NI COMMAND"
  echo " $PID1   0 dd"
  echo " $PID2 -15 dd"
  echo " $PID3   0 dd"
  echo

  # Step 9: Kill all dd processes
  echo "  Step 9: Kill all dd processes."
  echo "          Expected: killall dd"
  read -p "  lab@lab199:~$ " s9
  [[ "$s9" != "killall dd" ]] && { print_error "Use: killall dd"; read -p "Press Enter to try again..." _; continue; }
  # (killall dd typically prints nothing on success)
  echo

  # Step 10: Optional check (no output expected if none remain)
  echo "  Step 10: Check for remaining dd PIDs (no output expected)."
  echo "           Expected: pgrep dd"
  read -p "  lab@lab199:~$ " s10
  [[ "$s10" != "pgrep dd" ]] && { print_error "Use: pgrep dd"; read -p "Press Enter to try again..." _; continue; }
  # (no output if none running)
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
