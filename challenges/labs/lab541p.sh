#!/bin/bash

# Lab 541P: Configure SSH Key Authentication and Disable Password Login (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541P: Configure SSH Key Authentication and Disable Password Login"
LAB_ID="lab541p"
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
  center_text "ServerA must enforce secure SSH access using key-based"
  center_text "authentication. Generate a key pair for root, configure"
  center_text "key-based login to localhost, and disable password"
  center_text "authentication in the SSH server configuration."
  echo

  center_text "Requirements:"
  center_text "- Generate an SSH key pair for root"
  center_text "- Copy the key to localhost"
  center_text "- Disable password authentication"
  center_text "- Restart the SSH service"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Verify the root SSH directory exists."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "ls /root/.ssh" ]]; then
    print_error "Incorrect. Use: ls /root/.ssh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Generate an SSH key pair for the root user."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Generating public/private rsa key pair."
  echo "  Your identification has been saved in /root/.ssh/id_rsa"
  echo "  Your public key has been saved in /root/.ssh/id_rsa.pub"
  echo


  echo "  Step 3: Copy the public key to localhost for passwordless login."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo ssh-copy-id root@localhost" ]]; then
    print_error "Incorrect. Use: sudo ssh-copy-id root@localhost"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Number of key(s) added: 1"
  echo


  echo "  Step 4: Verify that root can SSH to localhost without a password."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo ssh root@localhost" ]]; then
    print_error "Incorrect. Use: sudo ssh root@localhost"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Last login: Tue Mar 14 14:20:00 from localhost"
  echo "  [root@servera ~]#"
  echo


  echo "  Step 5: Inspect the current SSH password authentication setting."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "grep '^PasswordAuthentication' /etc/ssh/sshd_config" ]]; then
    print_error "Incorrect. Use: grep '^PasswordAuthentication' /etc/ssh/sshd_config"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  PasswordAuthentication yes"
  echo


  echo "  Step 6: Disable password authentication in the SSH configuration."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "echo 'PasswordAuthentication no' | sudo tee -a /etc/ssh/sshd_config > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo 'PasswordAuthentication no' | sudo tee -a /etc/ssh/sshd_config > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 7: Restart the SSH service to apply changes."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "sudo systemctl restart sshd" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 8: Verify the SSH service is active."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "systemctl status sshd --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status sshd --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  ● sshd.service - OpenSSH server daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled)"
  echo "     Active: active (running)"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- generated an SSH key pair for root"
  print_info "- configured passwordless SSH login to localhost"
  print_info "- disabled password authentication"
  print_info "- restarted the SSH service"
  print_info "- verified the SSH service is running"
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