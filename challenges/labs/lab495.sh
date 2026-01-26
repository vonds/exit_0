#!/bin/bash

# Lab 495: Start, Stop, and Check the Status of Network Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 495: Network Services Control"
LAB_ID="lab495"
LAB_XP=49500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab495:~$ "

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
  center_text "Users report they cannot SSH into this host and network changes"
  center_text "are not applying reliably after reboots."
  center_text "You must verify and control core network services using systemctl,"
  center_text "reload firewall rules, and confirm service logs."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Check the status of NetworkManager."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl status NetworkManager" && "$cmd1" != "sudo systemctl status NetworkManager" ]]; then
    print_error "Incorrect. Use: systemctl status NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● NetworkManager.service - Network Manager"
  echo "       Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; disabled; vendor preset: enabled)"
  echo "       Active: inactive (dead)"
  echo "         Docs: man:NetworkManager(8)"
  echo

  # STEP 2
  echo "  Step 2: Start NetworkManager now."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl start NetworkManager" ]]; then
    print_error "Incorrect. Use: sudo systemctl start NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 3
  echo "  Step 3: Enable NetworkManager to start automatically on boot."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl enable NetworkManager" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service → /usr/lib/systemd/system/NetworkManager.service."
  echo

  # STEP 4
  echo "  Step 4: Confirm NetworkManager is now active (running)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "systemctl status NetworkManager" && "$cmd4" != "sudo systemctl status NetworkManager" ]]; then
    print_error "Incorrect. Use: systemctl status NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● NetworkManager.service - Network Manager"
  echo "       Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Sun 2026-01-25 14:22:10 EST; 7s ago"
  echo "     Main PID: 1058 (NetworkManager)"
  echo "        Tasks: 3"
  echo "       Memory: 23.8M"
  echo "          CPU: 162ms"
  echo

  # STEP 5
  echo "  Step 5: Check the status of the SSH service (sshd)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "systemctl status sshd" && "$cmd5" != "sudo systemctl status sshd" ]]; then
    print_error "Incorrect. Use: systemctl status sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● sshd.service - OpenSSH server daemon"
  echo "       Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled)"
  echo "       Active: active (running)"
  echo "     Main PID: 812 (sshd)"
  echo

  # STEP 6
  echo "  Step 6: Stop firewalld."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl stop firewalld" ]]; then
    print_error "Incorrect. Use: sudo systemctl stop firewalld"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 7
  echo "  Step 7: Disable firewalld at boot."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl disable firewalld" ]]; then
    print_error "Incorrect. Use: sudo systemctl disable firewalld"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service."
  echo

  # STEP 8
  echo "  Step 8: Reload firewall rules."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --reload"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 9
  echo "  Step 9: Mask NetworkManager."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo systemctl mask NetworkManager" ]]; then
    print_error "Incorrect. Use: sudo systemctl mask NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/NetworkManager.service → /dev/null."
  echo

  # STEP 10
  echo "  Step 10: Unmask NetworkManager."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo systemctl unmask NetworkManager" ]]; then
    print_error "Incorrect. Use: sudo systemctl unmask NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed /etc/systemd/system/NetworkManager.service."
  echo

  # STEP 11
  echo "  Step 11: View recent NetworkManager logs."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "journalctl -u NetworkManager -n 5" && "$cmd11" != "sudo journalctl -u NetworkManager -n 5" ]]; then
    print_error "Incorrect. Use: journalctl -u NetworkManager -n 5"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Jan 25 14:22:10 rhel-lab495 systemd[1]: Starting Network Manager..."
  echo "  Jan 25 14:22:10 rhel-lab495 NetworkManager[1058]: startup complete"
  echo "  Jan 25 14:22:10 rhel-lab495 systemd[1]: Started Network Manager."
  echo

  print_success "Excellent work."
  print_info "You successfully managed network services."
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
