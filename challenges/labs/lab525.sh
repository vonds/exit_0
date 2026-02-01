#!/bin/bash

# Lab 525: Configure Key-Based Authentication for SSH (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 525: SSH Key-Based Authentication (RHCSA)"
LAB_ID="lab525"
LAB_XP=52500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab525:~$ "

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
  center_text "You must configure secure, passwordless SSH access using"
  center_text "public key authentication. This is required for automation,"
  center_text "administration, and secure access in production environments."
  echo
  center_text "Targets:"
  center_text "- ssh-keygen"
  center_text "- ssh-copy-id"
  center_text "- ~/.ssh permissions"
  center_text "- authorized_keys"
  center_text "- systemctl sshd"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Generate a 4096-bit RSA SSH key pair using default settings."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ssh-keygen -t rsa -b 4096" ]]; then
    print_error "Incorrect. Use: ssh-keygen -t rsa -b 4096"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Generating public/private rsa key pair."
  echo "  ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub created"
  echo

  echo "  Step 2: Copy the public SSH key to the remote server as user admin."
  echo "          Assume the remote server IP is 192.168.1.10."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ssh-copy-id admin@192.168.1.10" ]]; then
    print_error "Incorrect. Use: ssh-copy-id admin@192.168.1.10"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Number of key(s) added: 1"
  echo

  echo "  Step 3: Verify key-based authentication by logging into the remote server."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ssh admin@192.168.1.10" ]]; then
    print_error "Incorrect. Use: ssh admin@192.168.1.10"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Logged in without password prompt"
  echo

  echo "  Step 4: Secure the .ssh directory permissions on the remote server."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "chmod 700 ~/.ssh" ]]; then
    print_error "Incorrect. Use: chmod 700 ~/.ssh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Secure the authorized_keys file permissions."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "chmod 600 ~/.ssh/authorized_keys" ]]; then
    print_error "Incorrect. Use: chmod 600 ~/.ssh/authorized_keys"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Ensure the SSH daemon is enabled to start at boot."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl enable sshd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Ensure the SSH daemon is currently running."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl start sshd" ]]; then
    print_error "Incorrect. Use: sudo systemctl start sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Verify SSH daemon status."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "systemctl status sshd" ]]; then
    print_error "Incorrect. Use: systemctl status sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Active: active (running)"
  echo

  echo "  Step 9 (Optional Hardening): Disable password authentication in SSH config."
  echo "          Edit /etc/ssh/sshd_config and set PasswordAuthentication no."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo vi /etc/ssh/sshd_config" ]]; then
    print_error "Incorrect. Use: sudo vi /etc/ssh/sshd_config"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  PasswordAuthentication no"
  echo

  echo "  Step 10: Restart SSH to apply configuration changes."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo systemctl restart sshd" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- generated an SSH key pair"
  print_info "- deployed a public key to a remote system"
  print_info "- verified passwordless SSH login"
  print_info "- secured SSH key permissions"
  print_info "- ensured sshd persistence and runtime state"
  print_info "- optionally hardened SSH authentication"
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
