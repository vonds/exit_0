#!/bin/bash

# Lab 496: Securely Transfer Files Between Systems (scp, rsync over SSH, sftp)
# Focus: Secure file transfer using scp, rsync (over SSH), and sftp; optional key-based auth setup.
#
# RHCSA Objective:
# - Securely transfer files between systems
#
# Key skills validated:
# - Copy a file to a remote host with scp
# - Copy a directory recursively with scp -r
# - Copy a file from remote to local with scp
# - Sync directories efficiently with rsync -avz over SSH
# - Perform interactive transfers with sftp (put/get)
# - (Optional) Set up SSH keys for passwordless transfers
#
# Difficulty: Intermediate
# XP: 49600

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 496: Secure File Transfers (scp/rsync/sftp)"
LAB_ID="lab496"
LAB_XP=49600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab496:~$ "

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
  center_text "You are staging a config bundle for a remote host and need to"
  center_text "transfer files securely using SSH-based tools."
  center_text "You must use scp, rsync over SSH, and sftp to move files safely."
  echo
  center_text "Lab assumptions (simulated):"
  center_text "- Remote host: server.example.com"
  center_text "- Remote user: remoteuser"
  center_text "- SSH reachable on port 22"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: scp local -> remote file
  echo "  Step 1: Copy a local file to the remote user's home directory using scp."
  echo "  (Source file exists: /home/examuser/testfile.txt)"
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "scp /home/examuser/testfile.txt remoteuser@server.example.com:/home/remoteuser/" ]]; then
    print_error "Incorrect. Use: scp /home/examuser/testfile.txt remoteuser@server.example.com:/home/remoteuser/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  The authenticity of host 'server.example.com (203.0.113.10)' can't be established."
  echo "  ED25519 key fingerprint is SHA256:Qm5fXGmWQk2n5Zg8h8nU0f5xjV5g0e8cQm3bT2b1qJQ."
  echo "  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes"
  echo "  Warning: Permanently added 'server.example.com,203.0.113.10' (ED25519) to the list of known hosts."
  echo "  remoteuser@server.example.com's password:"
  echo "  testfile.txt                                      100%   36     1.2KB/s   00:00"
  echo

  # STEP 2: scp -r local -> remote directory
  echo "  Step 2: Copy a local directory recursively to the remote host using scp -r."
  echo "  (Directory exists: /home/examuser/docs/)"
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "scp -r /home/examuser/docs/ remoteuser@server.example.com:/home/remoteuser/" ]]; then
    print_error "Incorrect. Use: scp -r /home/examuser/docs/ remoteuser@server.example.com:/home/remoteuser/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  remoteuser@server.example.com's password:"
  echo "  notes.txt                                         100%  212     4.8KB/s   00:00"
  echo "  inventory.csv                                     100%  1.9KB   38.5KB/s  00:00"
  echo "  README                                            100%  98      2.2KB/s   00:00"
  echo

  # STEP 3: scp remote -> local file
  echo "  Step 3: Download a remote file to /tmp using scp."
  echo "  (Remote file exists: /home/remoteuser/log.txt)"
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "scp remoteuser@server.example.com:/home/remoteuser/log.txt /tmp/" ]]; then
    print_error "Incorrect. Use: scp remoteuser@server.example.com:/home/remoteuser/log.txt /tmp/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  remoteuser@server.example.com's password:"
  echo "  log.txt                                           100%  8.3KB  144.0KB/s  00:00"
  echo

  # STEP 4: rsync local -> remote directory
  echo "  Step 4: Sync a local directory to the remote host using rsync -avz (over SSH)."
  echo "  (Local dir exists: /home/examuser/data/  Remote dest: /home/remoteuser/data/)"
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "rsync -avz /home/examuser/data/ remoteuser@server.example.com:/home/remoteuser/data/" ]]; then
    print_error "Incorrect. Use: rsync -avz /home/examuser/data/ remoteuser@server.example.com:/home/remoteuser/data/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  remoteuser@server.example.com's password:"
  echo "  sending incremental file list"
  echo "  ./"
  echo "  app.conf"
  echo "  hosts.allow"
  echo "  scripts/"
  echo "  scripts/deploy.sh"
  echo
  echo "  sent 6,482 bytes  received 152 bytes  1,326.80 bytes/sec"
  echo "  total size is 9,104  speedup is 1.37"
  echo

  # STEP 5: rsync remote -> local directory
  echo "  Step 5: Sync a remote directory down to the local system using rsync -avz."
  echo "  (Remote dir exists: /home/remoteuser/logs/  Local dest: /home/examuser/logs/)"
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "rsync -avz remoteuser@server.example.com:/home/remoteuser/logs/ /home/examuser/logs/" ]]; then
    print_error "Incorrect. Use: rsync -avz remoteuser@server.example.com:/home/remoteuser/logs/ /home/examuser/logs/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  remoteuser@server.example.com's password:"
  echo "  receiving incremental file list"
  echo "  ./"
  echo "  auth.log"
  echo "  app.log"
  echo "  rotated/"
  echo "  rotated/app.log.1"
  echo
  echo "  received 18,220 bytes  sent 124 bytes  3,668.80 bytes/sec"
  echo "  total size is 41,992  speedup is 2.28"
  echo

  # STEP 6: sftp connect (interactive session start)
  echo "  Step 6: Start an interactive sftp session to the remote host."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sftp remoteuser@server.example.com" ]]; then
    print_error "Incorrect. Use: sftp remoteuser@server.example.com"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  remoteuser@server.example.com's password:"
  echo "  Connected to server.example.com."
  echo "  sftp> "
  echo

  # STEP 7: sftp cd
  echo "  Step 7: In sftp, change to /home/remoteuser/."
  read -p "  sftp> " cmd7
  echo
  if [[ "$cmd7" != "cd /home/remoteuser/" && "$cmd7" != "cd /home/remoteuser" ]]; then
    print_error "Incorrect. Use: cd /home/remoteuser/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  sftp> "
  echo

  # STEP 8: sftp put upload
  echo "  Step 8: In sftp, upload /home/examuser/testfile.txt using put."
  read -p "  sftp> " cmd8
  echo
  if [[ "$cmd8" != "put /home/examuser/testfile.txt" ]]; then
    print_error "Incorrect. Use: put /home/examuser/testfile.txt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Uploading /home/examuser/testfile.txt to /home/remoteuser/testfile.txt"
  echo "  /home/examuser/testfile.txt                        100%   36     2.1KB/s   00:00"
  echo "  sftp> "
  echo

  # STEP 9: sftp get download
  echo "  Step 9: In sftp, download /home/remoteuser/log.txt to /home/examuser/log.txt using get."
  read -p "  sftp> " cmd9
  echo
  if [[ "$cmd9" != "get /home/remoteuser/log.txt /home/examuser/log.txt" ]]; then
    print_error "Incorrect. Use: get /home/remoteuser/log.txt /home/examuser/log.txt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Fetching /home/remoteuser/log.txt to /home/examuser/log.txt"
  echo "  /home/remoteuser/log.txt                           100%  8.3KB  167.0KB/s  00:00"
  echo "  sftp> "
  echo

  # STEP 10: exit sftp
  echo "  Step 10: Exit the sftp session."
  read -p "  sftp> " cmd10
  echo
  if [[ "$cmd10" != "exit" && "$cmd10" != "bye" && "$cmd10" != "quit" ]]; then
    print_error "Incorrect. Use: exit"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (connection closed)"
  echo

  # STEP 11 (Optional): key-based auth
  echo "  Step 11: Generate an SSH keypair for passwordless transfers."
  echo "  (If you already have ~/.ssh/id_ed25519, this will still be accepted for practice.)"
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "ssh-keygen -t ed25519" && "$cmd11" != "ssh-keygen -t rsa" ]]; then
    print_error "Incorrect. Use: ssh-keygen -t ed25519"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Generating public/private ed25519 key pair."
  echo "  Enter file in which to save the key (/home/examuser/.ssh/id_ed25519):"
  echo "  Enter passphrase (empty for no passphrase):"
  echo "  Enter same passphrase again:"
  echo "  Your identification has been saved in /home/examuser/.ssh/id_ed25519"
  echo "  Your public key has been saved in /home/examuser/.ssh/id_ed25519.pub"
  echo "  The key fingerprint is:"
  echo "  SHA256:ZbZx2qgKq0r0y4mW7mB8kqP9mQ3bq9mQ0wP8mXnQp0o examuser@rhel-lab496"
  echo

  # STEP 12 (Optional): ssh-copy-id
  echo "  Step 12: Install your public key on the remote host using ssh-copy-id."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "ssh-copy-id remoteuser@server.example.com" && "$cmd12" != "sudo ssh-copy-id remoteuser@server.example.com" ]]; then
    print_error "Incorrect. Use: ssh-copy-id remoteuser@server.example.com"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: \"/home/examuser/.ssh/id_ed25519.pub\""
  echo "  /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed"
  echo "  remoteuser@server.example.com's password:"
  echo "  Number of key(s) added: 1"
  echo
  echo "  Now try logging into the machine, with:   \"ssh 'remoteuser@server.example.com'\""
  echo "  and check to make sure that only the key(s) you wanted were added."
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- transferred files securely with scp"
  print_info "- synchronized data efficiently with rsync over SSH"
  print_info "- performed interactive transfers with sftp (put/get)"
  print_info "- practiced key-based authentication setup"
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
