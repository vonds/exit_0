#!/bin/bash

# Lab 541U: Preserve systemd Journals and Extract sshd Logs Since Boot (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541U: Preserve Journals and Extract sshd Logs"
LAB_ID="lab541u"
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
  center_text "ServerA currently stores system journals only in memory."
  center_text "Configure systemd-journald so logs persist across reboots."
  echo
  center_text "Then extract all sshd journal entries since the last boot"
  center_text "and save them to /var/log/ssh_boot.log."
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Create the persistent journal directory."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo mkdir -p /var/log/journal" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /var/log/journal"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Restart systemd-journald to enable persistent logging."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo systemctl restart systemd-journald" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart systemd-journald"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [no output]"
  echo


  echo "  Step 3: Verify that persistent journal storage now exists."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "ls /var/log/journal" ]]; then
    print_error "Incorrect. Use: ls /var/log/journal"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  4f92e4c8d0e9420b8f9a1d6e4cfd5c12"
  echo


  echo "  Step 4: Locate sshd journal entries from the current boot."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "journalctl -u sshd -b" ]]; then
    print_error "Incorrect. Use: journalctl -u sshd -b"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Mar 15 09:01:02 servera systemd[1]: Starting OpenSSH server daemon..."
  echo "  Mar 15 09:01:02 servera sshd[742]: Server listening on 0.0.0.0 port 22."
  echo "  Mar 15 09:01:02 servera sshd[742]: Server listening on :: port 22."
  echo "  Mar 15 09:05:11 servera sshd[983]: Accepted publickey for examuser from 192.168.1.55"
  echo


  echo "  Step 5: Save sshd entries since the last boot to /var/log/ssh_boot.log."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "journalctl -u sshd -b | sudo tee /var/log/ssh_boot.log > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: journalctl -u sshd -b | sudo tee /var/log/ssh_boot.log > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 6: Confirm the log file was created."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo cat /var/log/ssh_boot.log" ]]; then
    print_error "Incorrect. Use: sudo cat /var/log/ssh_boot.log"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Mar 15 09:01:02 servera systemd[1]: Starting OpenSSH server daemon..."
  echo "  Mar 15 09:01:02 servera sshd[742]: Server listening on 0.0.0.0 port 22."
  echo "  Mar 15 09:05:11 servera sshd[983]: Accepted publickey for examuser from 192.168.1.55"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- enabled persistent systemd journal storage"
  print_info "- restarted systemd-journald"
  print_info "- verified the persistent journal directory"
  print_info "- filtered journal entries for sshd since the last boot"
  print_info "- saved the logs to /var/log/ssh_boot.log"
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