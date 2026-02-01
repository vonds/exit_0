#!/bin/bash

# Lab 509: Schedule Tasks Using at and cron (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 509: Schedule Tasks Using at and cron"
LAB_ID="lab509"
LAB_XP=50900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab509:~$ "

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
  center_text "Ops needs reliable task scheduling for one-time and recurring maintenance."
  center_text "You must enable schedulers, schedule jobs, verify them, and enforce cron access policy."
  echo
  center_text "Targets:"
  center_text "- atd (one-time jobs)"
  center_text "- user crontab (recurring jobs)"
  center_text "- /etc/cron.d (system-wide job file)"
  center_text "- /etc/cron.deny (cron access policy)"
  center_text "- /var/log/cron (verification)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Start the atd service."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo systemctl start atd" ]]; then
    print_error "Incorrect. Use: sudo systemctl start atd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Enable atd to start at boot."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl enable atd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable atd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/atd.service → /usr/lib/systemd/system/atd.service."
  echo

  echo "  Step 3: Verify atd is active (running)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl status atd --no-pager" ]]; then
    print_error "Incorrect. Use: sudo systemctl status atd --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● atd.service - Job spooling tools"
  echo "     Loaded: loaded (/usr/lib/systemd/system/atd.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 4: Schedule a one-time at job to create /tmp/at_job.txt in 5 minutes."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "echo 'touch /tmp/at_job.txt' | at now + 5 minutes" ]]; then
    print_error "Incorrect. Use: echo 'touch /tmp/at_job.txt' | at now + 5 minutes"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  warning: commands will be executed using /bin/sh"
  echo "  job 1 at $(date '+%a %b %e %H:%M:%S %Y')"
  echo

  echo "  Step 5: List queued at jobs for the current user."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "atq" ]]; then
    print_error "Incorrect. Use: atq"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  1\t$(date '+%a %b %e %H:%M:%S %Y') a examuser"
  echo

  echo "  Step 6: Remove the at job with job ID 1."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "atrm 1" ]]; then
    print_error "Incorrect. Use: atrm 1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Confirm there are no remaining at jobs queued."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "atq" ]]; then
    print_error "Incorrect. Use: atq"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Open your user crontab for editing."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "crontab -e" ]]; then
    print_error "Incorrect. Use: crontab -e"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (crontab editor opened)"
  echo

  echo "  Step 9: Add a cron entry that creates /tmp/cron_job.txt every day at 2:00 AM."
  read -p "  > " cron1
  if [[ "$cron1" != "0 2 * * * touch /tmp/cron_job.txt" ]]; then
    print_error "Incorrect. Use: 0 2 * * * touch /tmp/cron_job.txt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Step 10: List your current crontab to verify the entry exists."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "crontab -l" ]]; then
    print_error "Incorrect. Use: crontab -l"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  0 2 * * * touch /tmp/cron_job.txt"
  echo

  echo "  Step 11: Create a system-wide cron job file /etc/cron.d/cleanup using vim."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo vim /etc/cron.d/cleanup" && "$cmd11" != "sudo vi /etc/cron.d/cleanup" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/cron.d/cleanup"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 12: In /etc/cron.d/cleanup, add a line that runs /opt/scripts/cleanup.sh daily at 23:30 as root."
  read -p "  > " cron2
  if [[ "$cron2" != "30 23 * * * root /opt/scripts/cleanup.sh" ]]; then
    print_error "Incorrect. Use: 30 23 * * * root /opt/scripts/cleanup.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Step 13: Verify the cron.d file contents."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo cat /etc/cron.d/cleanup" ]]; then
    print_error "Incorrect. Use: sudo cat /etc/cron.d/cleanup"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  30 23 * * * root /opt/scripts/cleanup.sh"
  echo

  echo "  Step 14: Ensure the cron daemon is running (crond)."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo systemctl status crond --no-pager" ]]; then
    print_error "Incorrect. Use: sudo systemctl status crond --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● crond.service - Command Scheduler"
  echo "     Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 15: Restrict cron access by adding user bob to /etc/cron.deny using vim."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sudo vim /etc/cron.deny" && "$cmd15" != "sudo vi /etc/cron.deny" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/cron.deny"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 16: In /etc/cron.deny, add ONE username on its own line to deny cron usage for that user."
  read -p "  > " deny1
  if [[ "$deny1" != "bob" ]]; then
    print_error "Incorrect. Use: bob"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Step 17: Verify bob is listed in /etc/cron.deny."
  read -p "$PROMPT" cmd17
  echo
  if [[ "$cmd17" != "sudo cat /etc/cron.deny" ]]; then
    print_error "Incorrect. Use: sudo cat /etc/cron.deny"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  bob"
  echo

  echo "  Step 18: Check the cron log for recent cron activity entries."
  read -p "$PROMPT" cmd18
  echo
  if [[ "$cmd18" != "sudo tail -n 5 /var/log/cron" ]]; then
    print_error "Incorrect. Use: sudo tail -n 5 /var/log/cron"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  $(date '+%b %e %H:%M:%S') rhel-lab509 CROND[2156]: (root) CMD (/usr/lib64/sa/sa1 1 1)"
  echo "  $(date '+%b %e %H:%M:%S') rhel-lab509 CROND[2199]: (examuser) CMD (touch /tmp/cron_job.txt)"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- enabled and verified atd for one-time scheduling"
  print_info "- scheduled, verified, and removed an at job (at/atq/atrm)"
  print_info "- created and verified a user crontab entry (crontab -e/-l)"
  print_info "- created and verified a system-wide /etc/cron.d job file"
  print_info "- enforced cron access policy with /etc/cron.deny"
  print_info "- validated scheduling behavior using /var/log/cron"
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
