#!/bin/bash

# Lab 368: RHEL Troubleshooting — a script works interactively but fails in cron
# Focus: diagnosing cron’s minimal environment, PATH differences, missing variables, and safe logging
# Key skills: crontab -l, /var/log/cron or journalctl, absolute paths, SHELL/PATH in crontab,
# redirecting output, and verifying with a controlled test run.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 368: Script Works Interactively but Fails in cron"
LAB_ID="lab368"
LAB_XP=36800
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
  center_text "Scenario:"
  center_text "User 'bob' has a maintenance script that succeeds when run manually:"
  center_text "  /home/bob/bin/report.sh"
  center_text "But the same script fails when run from cron."
  center_text "The cron job is supposed to generate a report file every minute."
  echo
  center_text "Goal: identify why it fails under cron and fix it safely."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm the script works interactively
  echo "  Step 1: Run the script interactively and confirm it succeeds."
  read -p "  lab@rhel-lab368:~$ " cmd1
  echo
  if [[ "$cmd1" != "/home/bob/bin/report.sh" && "$cmd1" != "bash /home/bob/bin/report.sh" && "$cmd1" != "./bin/report.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Report generated: /home/bob/reports/daily.txt"
  echo

  # STEP 2: Inspect the cron job
  echo "  Step 2: Inspect bob's crontab to see how the job is configured."
  read -p "  lab@rhel-lab368:~$ " cmd2
  echo
  if [[ "$cmd2" != "crontab -l" && "$cmd2" != "sudo -iu bob crontab -l" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  * * * * * /home/bob/bin/report.sh"
  echo

  # STEP 3: Check cron logs for the failure symptom
  echo "  Step 3: Check cron logs to find the error generated during cron execution."
  read -p "  lab@rhel-lab368:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo journalctl -u crond --since '10 min ago' --no-pager" && \
        "$cmd3" != "sudo journalctl -u crond --since \"10 min ago\" --no-pager" && \
        "$cmd3" != "sudo grep CRON /var/log/cron | tail -n 20" && \
        "$cmd3" != "sudo tail -n 50 /var/log/cron" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Jan 01 20:14:01 rhel-lab368 CRON[21452]: (bob) CMD (/home/bob/bin/report.sh)"
  echo "  Jan 01 20:14:01 rhel-lab368 CRON[21453]: (bob) (CRON) info (No MTA installed, discarding output)"
  echo "  Jan 01 20:14:01 rhel-lab368 CRON[21452]: (bob) CMDOUT (/home/bob/bin/report.sh: line 7: jq: command not found)"
  echo

  # STEP 4: Identify the root cause: cron PATH is minimal
  echo "  Step 4: Confirm where 'jq' lives on disk (the script depends on it)."
  read -p "  lab@rhel-lab368:~$ " cmd4
  echo
  if [[ "$cmd4" != "command -v jq" && "$cmd4" != "which jq" && "$cmd4" != "type -a jq" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /usr/bin/jq"
  echo

  echo "  Step 5: Show the PATH cron typically uses by default (compare with your interactive shell)."
  read -p "  lab@rhel-lab368:~$ " cmd5
  echo
  if [[ "$cmd5" != "echo \$PATH" && "$cmd5" != "env | grep '^PATH='" && "$cmd5" != "printf '%s\n' \"\$PATH\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  echo
  echo "  (cron jobs often run with a much smaller PATH and no profile scripts.)"
  echo

  # STEP 5: Fix option A: make the script cron-safe using absolute paths
  echo "  Step 6: Edit the script to use an absolute path for jq (replace 'jq' with '/usr/bin/jq')."
  read -p "  lab@rhel-lab368:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo sed -i 's/^jq /\\/usr\\/bin\\/jq /' /home/bob/bin/report.sh" && \
        "$cmd6" != "sudo sed -i 's/\\<jq\\>/\\/usr\\/bin\\/jq/g' /home/bob/bin/report.sh" && \
        "$cmd6" != "sudo vim /home/bob/bin/report.sh" && \
        "$cmd6" != "sudo nano /home/bob/bin/report.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Updated /home/bob/bin/report.sh"
  echo

  # STEP 6: Improve observability: redirect cron output to a log file
  echo "  Step 7: Update the crontab entry to log stdout/stderr to /home/bob/reports/cron.log."
  read -p "  lab@rhel-lab368:~$ " cmd7
  echo
  if [[ "$cmd7" != "crontab -e" && "$cmd7" != "sudo -iu bob crontab -e" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (crontab opened)"
  echo "  Change the line to:"
  echo "  * * * * * /home/bob/bin/report.sh >> /home/bob/reports/cron.log 2>&1"
  echo "  (saved and exited)"
  echo

  # STEP 7: Verify cron runs now and report file updates
  echo "  Step 8: Wait briefly, then verify the report file timestamp updates and cron.log shows success."
  read -p "  lab@rhel-lab368:~$ " cmd8
  echo
  if [[ "$cmd8" != "ls -l /home/bob/reports/daily.txt" && \
        "$cmd8" != "stat /home/bob/reports/daily.txt" && \
        "$cmd8" != "tail -n 20 /home/bob/reports/cron.log" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd8" == "tail -n 20 /home/bob/reports/cron.log" ]]; then
    echo "  [OK] report.sh: wrote /home/bob/reports/daily.txt"
  else
    echo "  -rw-r--r--. 1 bob bob 842 Jan 01 20:15 /home/bob/reports/daily.txt"
  fi
  echo

  print_success "Great job."
  print_info "You diagnosed why a script worked interactively but failed in cron:"
  print_info "- cron ran with a minimal environment and did not reliably find required commands"
  print_info "- logs showed: 'jq: command not found'"
  print_info "You fixed the script using absolute command paths and added cron logging for visibility."
  print_info "You earned $LAB_XP XP for completing this lab."
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
