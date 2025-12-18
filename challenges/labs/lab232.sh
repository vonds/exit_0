#!/bin/bash

# Lab 232: Cron — daily job for Derek at 16:27 to create a release file (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real users, cron jobs, or system files are changed.
#         A simulated per-user crontab is used for Derek.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 232: Derek's daily release cron (16:27)"
LAB_ID="lab232"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated artifacts
SIM_DEREK_CRONTAB="/tmp/crontab.derek.lab232"
SIM_USER="derek"
RELEASE_FILE="/home/derek/release.flag"

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
  : > "$SIM_DEREK_CRONTAB"
}

while true; do
  reset_state

  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Goal: Schedule a daily job for '$SIM_USER' at 16:27 that creates a release file."
  center_text "Then verify the crontab entry, simulate execution, and confirm the file."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify cron daemon status
  draw_lab_ui
  echo "  Step 1: Check the system's cron service status."
  read -p "  lab@lab232:~$ " cmd1
  if [[ "$cmd1" == "systemctl status crond" || "$cmd1" == "systemctl status cron" ]]; then
    unit="${cmd1##*status }"
    echo "  ● ${unit}.service - Cron Daemon"
    echo "       Loaded: loaded (/usr/lib/systemd/system/${unit}.service; enabled; vendor preset: enabled)"
    echo "       Active: active (running) since Tue 2025-07-22 13:10:11 UTC; 2min 41s ago"
    echo "     Main PID: 1321 (${unit})"
    echo "        Tasks: 1 (limit: 32768)"
    echo "       Memory: 1.9M"
    echo "          CPU: 23ms"
    echo "       CGroup: /system.slice/${unit}.service"
    echo "               └─1321 /usr/sbin/${unit} -n"
  else
    print_error "Hint: Use the system service manager to view the cron daemon's status."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Confirm Derek account exists
  echo "  Step 2: Verify the '$SIM_USER' account."
  read -p "  lab@lab232:~$ " cmd2
  if [[ "$cmd2" == "id derek" ]]; then
    echo "uid=1002(derek) gid=1002(derek) groups=1002(derek)"
  elif [[ "$cmd2" == "getent passwd derek" ]]; then
    echo "derek:x:1002:1002::/home/derek:/bin/bash"
  else
    print_error "Hint: Use a standard user lookup command for '$SIM_USER'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Install Derek's daily 16:27 job that creates the release file
  echo "  Step 3: Add a user crontab entry for '$SIM_USER' that runs every day at 16:27"
  echo "          and creates (or touches) ${RELEASE_FILE}."
  read -p "  lab@lab232:~$ " cmd3
  # Accept common ways to install a per-user crontab containing minute=27 hour=16 entry that
  # creates/touches the target release file.
  if [[ "$cmd3" =~ crontab && "$cmd3" =~ (-u[[:space:]]+derek|derek) && "$cmd3" =~ (^|[[:space:]])27[[:space:]]+16[[:space:]]+\* && "$cmd3" =~ (/home/derek/release|touch|printf|echo) ]]; then
    # Write a canonical entry into the simulated crontab
    echo "27 16 * * * /usr/bin/touch ${RELEASE_FILE}" > "$SIM_DEREK_CRONTAB"
    # Simulate no output from crontab install
  else
    print_error "Hint: Install a per-user crontab for '$SIM_USER' with minute=27, hour=16, daily; it should create ${RELEASE_FILE}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify the crontab entry
  echo "  Step 4: List the scheduled entries for '$SIM_USER'."
  read -p "  lab@lab232:~$ " cmd4
  if [[ "$cmd4" == "crontab -u derek -l" || "$cmd4" == "sudo crontab -u derek -l" ]]; then
    cat "$SIM_DEREK_CRONTAB"
  else
    print_error "Hint: Use the crontab viewer targeting the '$SIM_USER' account."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: (Simulate time passing) Show cron logs when the job runs
  echo "  Step 5: (Fast-forward) The scheduled time arrives; review recent cron logs."
  read -p "  lab@lab232:~$ " cmd5
  if [[ "$cmd5" == "journalctl -u crond -n 3 --no-pager" || "$cmd5" == "journalctl -u cron -n 3 --no-pager" || "$cmd5" == "sudo journalctl -u crond -n 3 --no-pager" || "$cmd5" == "sudo journalctl -u cron -n 3 --no-pager" ]]; then
    unit="crond"
    [[ "$cmd5" == *" cron "* ]] && unit="cron"
    echo "  Jul 22 16:27:00 lab232 ${unit}[3321]: (derek) RELOAD (/var/spool/cron/derek)"
    echo "  Jul 22 16:27:00 lab232 ${unit}[3323]: (derek) CMD (/usr/bin/touch /home/derek/release.flag)"
    echo "  Jul 22 16:27:00 lab232 ${unit}[3324]: (derek) EXIT (status 0)"
  else
    print_error "Hint: Use the journal to view recent log lines for the cron unit."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Verify the release file exists
  echo "  Step 6: Confirm the release file was created."
  read -p "  lab@lab232:~$ " cmd6
  if [[ "$cmd6" == "ls -l /home/derek/release.flag" ]]; then
    echo "-rw-r--r-- 1 derek derek 0 Jul 22 16:27 /home/derek/release.flag"
  elif [[ "$cmd6" == "file /home/derek/release.flag" ]]; then
    echo "/home/derek/release.flag: empty"
  else
    print_error "Hint: Use a command that proves ${RELEASE_FILE} now exists."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # (Optional) Step 7: Remove the job
  echo "  Step 7 (optional): Remove the scheduled entry for '$SIM_USER'."
  read -p "  lab@lab232:~$ " cmd7
  if [[ "$cmd7" =~ crontab && "$cmd7" =~ (-u[[:space:]]+derek|derek) && "$cmd7" =~ -r ]]; then
    # Simulate removal
    : > "$SIM_DEREK_CRONTAB"
    # (crontab -r is silent)
  else
    print_error "Hint: Use the per-user crontab removal option to clear Derek's entries."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! Derek's daily 16:27 release cron installed, verified in logs, and confirmed the file (simulated)."
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
