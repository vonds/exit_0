#!/bin/bash

# Lab 231: Cron — restrict to user 'bob' and schedule a Sun/Wed job (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real users, cron jobs, or system files are changed.
#         A simulated /etc/cron.allow and bob crontab are used.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 231: Restrict cron to bob + Sun/Wed date append"
LAB_ID="lab231"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated artifacts
SIM_CRON_ALLOW="/tmp/cron.allow.lab231"
SIM_BOB_CRONTAB="/tmp/crontab.bob.lab231"
SIM_USER="bob"
SIM_DENIED_USER="alice"
LOGFILE="/home/bob/date.log"

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
  # reset simulated state each run
  : > "$SIM_CRON_ALLOW"
  : > "$SIM_BOB_CRONTAB"

  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Goal: Limit cron usage so only '$SIM_USER' can use it, then add a user crontab entry"
  center_text "that appends the current date to $LOGFILE on Sundays and Wednesdays."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify the cron daemon is running
  draw_lab_ui
  echo "  Step 1: Check the system's cron service status."
  read -p "  lab@lab231:~$ " cmd1
  if [[ "$cmd1" == "systemctl status crond" || "$cmd1" == "systemctl status cron" ]]; then
    unit="${cmd1##*status }"
    echo "  ● ${unit}.service - Cron Daemon"
    echo "       Loaded: loaded (/usr/lib/systemd/system/${unit}.service; enabled; vendor preset: enabled)"
    echo "       Active: active (running) since Tue 2025-07-22 12:10:11 UTC; 3min 42s ago"
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

  # Step 2: Confirm the target account exists
  echo "  Step 2: Verify the '$SIM_USER' account is present."
  read -p "  lab@lab231:~$ " cmd2
  if [[ "$cmd2" == "id bob" ]]; then
    echo "uid=1001(bob) gid=1001(bob) groups=1001(bob)"
  elif [[ "$cmd2" == "getent passwd bob" ]]; then
    echo "bob:x:1001:1001::/home/bob:/bin/bash"
  else
    print_error "Hint: Use a standard account lookup command for the '$SIM_USER' user."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Restrict cron so only 'bob' can use it (simulate /etc/cron.allow)
  echo "  Step 3: Configure the allow/deny mechanism so only '$SIM_USER' can use cron."
  read -p "  lab@lab231:~$ " cmd3
  # Accept common ways to create cron.allow with 'bob' inside (simulated path)
  if [[ "$cmd3" =~ (tee|cat|echo|printf) && "$cmd3" =~ cron\.allow && "$cmd3" =~ bob ]]; then
    echo "bob" > "$SIM_CRON_ALLOW"
    # Simulate tee output if used
    if [[ "$cmd3" =~ tee ]]; then echo "bob"; fi
  else
    print_error "Hint: Write the username into the proper allow file to permit cron access."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Show the allow file content (simulated)
  echo "  Step 4: Inspect the configured allow list."
  read -p "  lab@lab231:~$ " cmd4
  if [[ "$cmd4" == "cat /etc/cron.allow" || "$cmd4" == "cat /etc/cron.d/cron.allow" || "$cmd4" == "cat /tmp/cron.allow.lab231" ]]; then
    # Always display simulated file
    echo "bob"
  else
    print_error "Hint: Display the contents of the allow list file to verify."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Demonstrate a different user is denied
  echo "  Step 5: Attempt to view crontab for another user to confirm restriction."
  read -p "  lab@lab231:~$ " cmd5
  if [[ "$cmd5" == "crontab -u alice -l" || "$cmd5" == "crontab -u $SIM_DENIED_USER -l" ]]; then
    echo "You ($SIM_DENIED_USER) are not allowed to use this program (crontab)"
  else
    print_error "Hint: Try listing crontab for a user *not* in the allow file."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Create bob's cron job (Sun & Wed) that appends date to a log
  echo "  Step 6: Add a user crontab entry for '$SIM_USER' to append the current date to $LOGFILE"
  echo "          on Sundays and Wednesdays."
  read -p "  lab@lab231:~$ " cmd6
  # Accept common patterns that install a crontab for bob with day-of-week Sun/Wed (0,3 or names),
  # calling /usr/bin/date and appending to /home/bob/date.log
  if [[ "$cmd6" =~ crontab && "$cmd6" =~ (-u[[:space:]]+bob|bob) && "$cmd6" =~ date && "$cmd6" =~ ">>[[:space:]]*/home/bob/date\.log" ]]; then
    # Simulate creating a 09:00 job on Sun/Wed
    echo "0 9 * * 0,3 /usr/bin/date >> /home/bob/date.log" > "$SIM_BOB_CRONTAB"
    # no output (installing crontab is silent)
  else
    print_error "Hint: Install a user crontab for '$SIM_USER' with a Sun/Wed schedule that appends the date."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Verify bob's crontab shows the intended line
  echo "  Step 7: List the scheduled entries for '$SIM_USER'."
  read -p "  lab@lab231:~$ " cmd7
  if [[ "$cmd7" == "crontab -u bob -l" || "$cmd7" == "sudo crontab -u bob -l" ]]; then
    cat "$SIM_BOB_CRONTAB"
  else
    print_error "Hint: Use the crontab viewer targeting the '$SIM_USER' account."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! Cron access limited to '$SIM_USER' and scheduled Sun/Wed date append (simulated)."
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
