#!/bin/bash

# Lab 480: RHCSA Fundamentals — grep + Regular Expressions for Text Analysis
# Focus: basic grep, anchors (^ $), wildcards (.), character classes ([]),
#        case-insensitive search (-i), inverse match (-v), count (-c),
#        line numbers (-n), recursive search (-r), and extended regex (-E).
# Key skills: grep, grep -E, ps, pipes, basic regex thinking

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 480: grep + Regular Expressions"
LAB_ID="lab480"
LAB_XP=48000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab480:~$ "

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
  center_text "You are triaging a Linux host by searching config files, logs,"
  center_text "and command output. Use grep + regex to extract exactly what you need."
  echo
  center_text "Rules:"
  center_text "- Type the command exactly as prompted."
  center_text "- Outputs are simulated but match realistic patterns."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Basic grep search
  echo "  Step 1: Find lines containing 'root' in /etc/passwd."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "grep 'root' /etc/passwd" && "$cmd1" != "grep root /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo

  # STEP 2: Case-insensitive search
  echo "  Step 2: Search /etc/passwd for 'root' ignoring case."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "grep -i 'root' /etc/passwd" && "$cmd2" != "grep -i root /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo

  # STEP 3: Anchor to start of line
  echo "  Step 3: Show only the /etc/passwd line that STARTS with root."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "grep '^root' /etc/passwd" && "$cmd3" != "grep '^root' /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo

  # STEP 4: Anchor to end of line
  echo "  Step 4: Find /etc/passwd lines where the login shell ends in /bin/bash."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "grep '/bin/bash$' /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo "  student:x:1000:1000:Student User:/home/student:/bin/bash"
  echo

  # STEP 5: Wildcard "." pattern
  echo "  Step 5: Match lines where root is followed by ANY 3 characters (use dots)."
  echo "          (Hint: this is about pattern mechanics, not usefulness.)"
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "grep 'root...' /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo

  # STEP 6: Filter command output using grep
  echo "  Step 6: Filter running processes for sshd using a pipe."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ps aux | grep 'sshd'" && "$cmd6" != "ps aux | grep sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root       912  0.0  0.3  15492  6420 ?        Ss   09:12   0:00 /usr/sbin/sshd -D"
  echo "  root      1021  0.0  0.4  18640  8012 ?        Ss   09:12   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
  echo "  examuser   2487  0.0  0.0   6400  2240 pts/0    S+   09:44   0:00 grep sshd"
  echo

  # STEP 7: Recursive search in logs
  echo "  Step 7: Search recursively for the word 'error' under /var/log."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "grep -r 'error' /var/log" && "$cmd7" != "grep -r error /var/log" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /var/log/messages:Jan 21 09:31:12 host webapp[1442]: error: failed to connect to database"
  echo "  /var/log/secure:Jan 21 09:33:45 host sshd[1222]: error: PAM: Authentication failure for invalid user"
  echo

  # STEP 8: Inverse match
  echo "  Step 8: Show /etc/passwd lines that do NOT contain the word nologin."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "grep -v 'nologin' /etc/passwd" && "$cmd8" != "grep -v nologin /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo "  student:x:1000:1000:Student User:/home/student:/bin/bash"
  echo

  # STEP 9: Count matches
  echo "  Step 9: Count how many lines in /etc/passwd contain root."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "grep -c 'root' /etc/passwd" && "$cmd9" != "grep -c root /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  1"
  echo

  # STEP 10: Show line numbers
  echo "  Step 10: Search /etc/ssh/sshd_config for 'sshd' and show line numbers."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "grep -n 'sshd' /etc/ssh/sshd_config" && "$cmd10" != "grep -n sshd /etc/ssh/sshd_config" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  16:# This is the sshd server system-wide configuration file."
  echo

  # STEP 11: Extended regex OR
  echo "  Step 11: Using extended regex, match lines containing sshd OR ftp in /etc/services."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "grep -E 'sshd|ftp' /etc/services" && "$cmd11" != "grep -E sshd\\|ftp /etc/services" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ftp-data        20/tcp"
  echo "  ftp             21/tcp"
  echo "  ssh             22/tcp"
  echo

  print_success "Nice work."
  print_info "You demonstrated RHCSA-critical text analysis skills by:"
  print_info "- searching files with grep"
  print_info "- using anchors (^ and $) and wildcards (.)"
  print_info "- filtering command output with pipes"
  print_info "- searching recursively in logs"
  print_info "- using inverse match (-v), count (-c), and line numbers (-n)"
  print_info "- using extended regex (-E) for alternation"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
