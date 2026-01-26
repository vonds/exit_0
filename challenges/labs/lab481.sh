#!/bin/bash

# Lab 481: RHCSA Networking — Access Remote Systems Using SSH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 481: Access Remote Systems Using SSH"
LAB_ID="lab481"
LAB_XP=48100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab481:~$ "

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
  center_text "You are administering remote Linux systems over SSH."
  center_text "You must connect securely, configure key-based access,"
  center_text "transfer files, harden SSH, and troubleshoot access issues."
  echo
  center_text "Remote host: 192.168.1.10"
  center_text "User: examuser"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Basic SSH connection
  echo "  Step 1: Connect to the remote host using SSH."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ssh examuser@192.168.1.10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  examuser@192.168.1.10's password:"
  echo "  Last login: Tue Jan 21 10:12:04 2026 from 192.168.1.20"
  echo

  # STEP 2: SSH on a non-standard port
  echo "  Step 2: Connect to the same host using SSH on port 2222."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ssh -p 2222 examuser@192.168.1.10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  examuser@192.168.1.10's password:"
  echo

  # STEP 3: Generate an SSH key pair
  echo "  Step 3: Generate an SSH key pair for examuser."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ssh-keygen" && "$cmd3" != "ssh-keygen -t rsa" && "$cmd3" != "ssh-keygen -t ed25519" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Generating public/private key pair."
  echo "  Enter file in which to save the key (/home/examuser/.ssh/id_rsa):"
  echo "  Enter passphrase (empty for no passphrase):"
  echo "  Your identification has been saved."
  echo

  # STEP 4: Copy SSH key to remote host
  echo "  Step 4: Copy your public SSH key to the remote host."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ssh-copy-id examuser@192.168.1.10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Number of key(s) added: 1"
  echo

  # STEP 5: Verify passwordless SSH
  echo "  Step 5: SSH into the remote host without a password."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ssh examuser@192.168.1.10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last login: Tue Jan 21 10:22:41 2026 from 192.168.1.20"
  echo

  # STEP 6: Start ssh-agent and add key
  echo "  Step 6: Start ssh-agent and add your private key."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "eval \$(ssh-agent)" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Agent pid 2142"
  echo
  read -p "$PROMPT" cmd6b
  echo
  if [[ "$cmd6b" != "ssh-add ~/.ssh/id_rsa" && "$cmd6b" != "ssh-add" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Identity added: /home/examuser/.ssh/id_rsa"
  echo

  # STEP 7: Copy a file using scp
  echo "  Step 7: Copy example.txt to the remote host home directory."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "scp example.txt examuser@192.168.1.10:/home/examuser/" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  example.txt                                100%   42KB  1.2MB/s   00:00"
  echo

  # STEP 8: Specify a custom identity file
  echo "  Step 8: SSH using a non-default private key."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "ssh -i /home/examuser/.ssh/exam_key examuser@192.168.1.10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last login: Tue Jan 21 10:31:10 2026 from 192.168.1.20"
  echo

  # STEP 9: Restrict SSH access to examuser
  echo "  Step 9: Edit SSH configuration to allow only examuser."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo vim /etc/ssh/sshd_config" && "$cmd9" != "sudo nano /etc/ssh/sshd_config" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  AllowUsers examuser"
  echo

  echo "  Restart the SSH service."
  read -p "$PROMPT" cmd9b
  echo
  if [[ "$cmd9b" != "sudo systemctl restart sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 10: Troubleshoot SSH access
  echo "  Step 10: Verify SSH service and firewall configuration."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo systemctl status sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Active: active (running)"
  echo

  read -p "$PROMPT" cmd10b
  echo
  if [[ "$cmd10b" != "sudo firewall-cmd --list-services" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ssh dhcpv6-client"
  echo

  print_success "Well done."
  print_info "You demonstrated RHCSA-critical SSH skills by:"
  print_info "- connecting to remote systems using SSH"
  print_info "- using non-standard ports and identity files"
  print_info "- configuring key-based authentication"
  print_info "- managing keys with ssh-agent"
  print_info "- transferring files with scp"
  print_info "- hardening and troubleshooting SSH access"
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
