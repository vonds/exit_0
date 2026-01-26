#!/bin/bash

# Lab 493: Locate and Interpret System Log Files and Journals
# Focus: /var/log files, journalctl filtering, real-time monitoring, searching, and interpretation
#
# RHCSA Objective:
# - Locate and interpret system log files and journals
#
# Key skills validated:
# - /var/log/messages, /var/log/secure, /var/log/boot.log, /var/log/dmesg
# - journalctl: filtering by service, time, priority, real-time following
# - grep searching inside logs
# - journal disk usage
#
# Difficulty: Intermediate
# XP: 49300

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 493: Locate and Interpret System Logs & Journals"
LAB_ID="lab493"
LAB_XP=49300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab493:~$ "

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
  center_text "A production system is showing intermittent performance issues."
  center_text "You must inspect traditional logs and the systemd journal"
  center_text "to identify recent activity, authentication events, and errors."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: View system messages
  echo "  Step 1: View recent system messages from /var/log/messages."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo tail /var/log/messages" && "$cmd1" != "tail /var/log/messages" ]]; then
    print_error "Incorrect. Use: sudo tail /var/log/messages"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Jan 25 21:34:41 rhel-lab493 kernel: CPU0: Core temperature above threshold"
  echo "Jan 25 21:34:42 rhel-lab493 systemd: Started Session 7 of user examuser."
  echo "Jan 25 21:34:47 rhel-lab493 sshd[2413]: Accepted password for examuser from 192.168.56.1 port 52314 ssh2"
  echo

  # STEP 2: View authentication logs
  echo "  Step 2: View authentication logs in /var/log/secure."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo cat /var/log/secure" && "$cmd2" != "cat /var/log/secure" ]]; then
    print_error "Incorrect. Use: sudo cat /var/log/secure"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Jan 25 21:34:47 rhel-lab493 sshd[2413]: Accepted password for examuser from 192.168.56.1 port 52314 ssh2"
  echo "Jan 25 21:35:02 rhel-lab493 sudo: examuser : TTY=pts/0 ; PWD=/home/examuser ; USER=root ; COMMAND=/bin/systemctl status sshd"
  echo

  # STEP 3: Kernel messages
  echo "  Step 3: Display kernel ring buffer messages."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "dmesg | less" && "$cmd3" != "sudo dmesg | less" ]]; then
    print_error "Incorrect. Use: dmesg | less"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "[    0.000000] Linux version 5.14.0-362.el9.x86_64"
  echo "[    1.421098] ACPI: PCI Root Bridge"
  echo "[    2.132441] ata1: SATA link up 6.0 Gbps"
  echo

  # STEP 4: View entire journal
  echo "  Step 4: Display full systemd journal."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo journalctl" && "$cmd4" != "journalctl" ]]; then
    print_error "Incorrect. Use: sudo journalctl"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "-- Logs begin at Sun 2026-01-25 20:42:17 EST, end at Sun 2026-01-25 21:38:01 EST. --"
  echo "Jan 25 21:34:47 rhel-lab493 sshd[2413]: Accepted password for examuser"
  echo "Jan 25 21:35:02 rhel-lab493 sudo[2451]: examuser : COMMAND=/bin/systemctl status sshd"
  echo

  # STEP 5: Filter logs by service
  echo "  Step 5: Display only sshd logs."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo journalctl -u sshd" && "$cmd5" != "journalctl -u sshd" ]]; then
    print_error "Incorrect. Use: sudo journalctl -u sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Jan 25 21:34:47 rhel-lab493 sshd[2413]: Accepted password for examuser"
  echo "Jan 25 21:37:11 rhel-lab493 sshd[2511]: Connection closed by 192.168.56.1"
  echo

  # STEP 6: View last boot logs
  echo "  Step 6: Display logs from the current boot."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo journalctl -b" && "$cmd6" != "journalctl -b" ]]; then
    print_error "Incorrect. Use: sudo journalctl -b"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "-- Boot ID: 76c2d9bb1f4b48bdbbcae9a0c3ff10ad --"
  echo "Jan 25 21:31:55 rhel-lab493 kernel: Initializing cgroup subsys cpu"
  echo "Jan 25 21:31:58 rhel-lab493 systemd: Started Network Manager."
  echo

  # STEP 7: View error-priority logs
  echo "  Step 7: Display only error and higher priority logs."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo journalctl -p err" && "$cmd7" != "journalctl -p err" ]]; then
    print_error "Incorrect. Use: sudo journalctl -p err"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Jan 25 21:34:41 rhel-lab493 kernel: CPU overheating detected"
  echo

  # STEP 8: Search log file for errors
  echo "  Step 8: Search /var/log/messages for error entries."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo grep error /var/log/messages" && "$cmd8" != "grep error /var/log/messages" ]]; then
    print_error "Incorrect. Use: sudo grep error /var/log/messages"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Jan 25 21:34:41 rhel-lab493 kernel: CPU overheating detected"
  echo

  # STEP 9: Follow logs in real time
  echo "  Step 9: Follow sshd logs in real-time."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo journalctl -u sshd -f" && "$cmd9" != "journalctl -u sshd -f" ]]; then
    print_error "Incorrect. Use: sudo journalctl -u sshd -f"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "-- Realtime log follow started --"
  echo "Jan 25 21:39:01 rhel-lab493 sshd[2611]: Accepted password for examuser"
  echo

  # STEP 10: Check journal disk usage
  echo "  Step 10: Check journal disk usage."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo journalctl --disk-usage" && "$cmd10" != "journalctl --disk-usage" ]]; then
    print_error "Incorrect. Use: sudo journalctl --disk-usage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Archived and active journals take up 184.3M on disk."
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- located traditional system logs"
  print_info "- interpreted authentication and kernel events"
  print_info "- filtered systemd journals by service, boot, and priority"
  print_info "- monitored logs in real time"
  print_info "- analyzed journal disk usage"
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
