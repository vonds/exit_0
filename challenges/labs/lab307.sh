#!/bin/bash

# Lab 307: Scheduling System Jobs with Cron & Anacron – Objective 107.2
# LPIC-1 focus: /etc/crontab (7 fields incl. user), /etc/cron.d, cron.{hourly,daily,weekly,monthly},
# anacron basics (/etc/anacrontab, /var/spool/anacron), and cron access control files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 307"
LAB_ID="lab307"
LAB_XP=35200
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

PROMPT="student@lab307:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Objective 107.2 — System Cron & Anacron"
  center_text "Interactive: examine /etc/crontab, /etc/cron.d, periodical dirs, anacron, and access controls."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1: Show system crontab (realistic output)
  echo "  Step 1: Display the system-wide cron table."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "cat /etc/crontab" ]]; then
    print_error "Incorrect. Use: cat /etc/crontab"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "# /etc/crontab: system-wide crontab"
  echo "SHELL=/bin/sh"
  echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
  echo ""
  echo "# m  h  dom mon dow  user   command"
  echo "17 *   *   *   *    root    cd / && run-parts --report /etc/cron.hourly"
  echo "25 6   *   *   *    root    test -x /usr/sbin/anacron || run-parts --report /etc/cron.daily"
  echo "47 6   *   *   7    root    test -x /usr/sbin/anacron || run-parts --report /etc/cron.weekly"
  echo "52 6   1   *   *    root    test -x /usr/sbin/anacron || run-parts --report /etc/cron.monthly"

  # STEP 2: Identify field layout difference (no output expected)
  echo
  echo "  Step 2: Enter the number of fields in a system crontab job line (just the number)."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "7" ]]; then
    print_error "Incorrect. Hint: system entries include a user field."
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 3: List cron periodic directories (realistic output)
  echo
  echo "  Step 3: List the standard periodic cron directories."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "ls /etc/cron.*" && "$cmd3" != "ls /etc/cron.* /etc/cron.d" && "$cmd3" != "ls /etc/cron.* /etc/cron.d/" ]]; then
    print_error "Try listing /etc/cron.* (you may also include /etc/cron.d)."
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "/etc/cron.d"
  echo "/etc/cron.daily"
  echo "/etc/cron.hourly"
  echo "/etc/cron.monthly"
  echo "/etc/cron.weekly"

  # STEP 4: Show the contents of /etc/cron.d (realistic output sample; may vary by distro)
  echo
  echo "  Step 4: List files inside the directory for packaged system cron snippets."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "ls /etc/cron.d" && "$cmd4" != "ls /etc/cron.d/" ]]; then
    print_error "Incorrect. Use: ls /etc/cron.d"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "0hourly"
  echo "sysstat"
  echo

  # STEP 5: Display a packaged cron snippet (realistic output)
  echo "  Step 5: Display one cron snippet file under /etc/cron.d."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "cat /etc/cron.d/0hourly" && "$cmd5" != "cat /etc/cron.d/sysstat" ]]; then
    print_error "Try: cat /etc/cron.d/0hourly   or   cat /etc/cron.d/sysstat"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd5" == *"0hourly" ]]; then
    echo "# Run hourly jobs"
    echo "SHELL=/bin/sh"
    echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
    echo "01 * * * * root run-parts /etc/cron.hourly"
  else
    echo "# sysstat: Collect system activity reports"
    echo "*/10 * * * * root /usr/lib/sysstat/sa1 1 1"
    echo "53 23 * * * root /usr/lib/sysstat/sa2 -A"
  fi

  # STEP 6: View Anacron configuration (realistic output)
  echo
  echo "  Step 6: Display the Anacron configuration file."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "cat /etc/anacrontab" ]]; then
    print_error "Incorrect. Use: cat /etc/anacrontab"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "# /etc/anacrontab: configuration file for anacron"
  echo "SHELL=/bin/sh"
  echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
  echo ""
  echo "# period  delay  job-identifier   command"
  echo "1         5      cron.daily       nice run-parts --report /etc/cron.daily"
  echo "7         10     cron.weekly      nice run-parts --report /etc/cron.weekly"
  echo "@monthly  15     cron.monthly     nice run-parts --report /etc/cron.monthly"

  # STEP 7: Show Anacron timestamp spool (realistic output)
  echo
  echo "  Step 7: List the directory where Anacron keeps its timestamps."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "ls /var/spool/anacron" && "$cmd7" != "ls /var/spool/anacron/" ]]; then
    print_error "Incorrect. Use: ls /var/spool/anacron"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "cron.daily"
  echo "cron.weekly"
  echo "cron.monthly"

  # STEP 8: Display access-control files for cron (realistic output)
  echo
  echo "  Step 8: Show cron access-control files in /etc."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "ls /etc/cron.*" && "$cmd8" != "ls /etc/cron.allow /etc/cron.deny" && "$cmd8" != "ls /etc/cron.allow /etc/cron.deny 2>/dev/null" ]]; then
    print_error "Try listing /etc/cron.allow and /etc/cron.deny."
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "/etc/cron.allow"
  echo "/etc/cron.deny"

  # STEP 9: View cron.allow or cron.deny (realistic output; empty is common)
  echo
  echo "  Step 9: Display one of the cron access-control files."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "cat /etc/cron.allow" && "$cmd9" != "cat /etc/cron.deny" ]]; then
    print_error "Use: cat /etc/cron.allow   or   cat /etc/cron.deny"
    read -p "Press Enter to continue..." _
    continue
  fi
  # Many systems ship with empty files by default
  # If no content, print nothing (no spaces or extra newlines)
  # Simulate an empty file by printing nothing.

  # STEP 10: Confirm understanding of user field in /etc/crontab (no output expected)
  echo
  echo "  Step 10: Enter the name of the field that appears in /etc/crontab but not in user crontabs."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "user" && "$cmd10" != "username" && "$cmd10" != "account" ]]; then
    print_error "Answer should indicate the extra 'user' field present in system crontab lines."
    read -p "Press Enter to continue..." _
    continue
  fi

  print_success "Excellent work!"
  print_info "You earned $LAB_XP XP for completing this lab!"
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

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done

