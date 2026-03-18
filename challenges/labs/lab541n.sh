#!/bin/bash

# Lab 541N: Create and Verify a Compressed Archive with tar and gzip (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541N: Create and Verify a Compressed Archive"
LAB_ID="lab541n"
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
  center_text "ServerA requires a backup of SSH configuration files."
  center_text "Create a gzip-compressed archive of /etc/ssh and verify"
  center_text "its contents without extracting it."
  echo

  center_text "Requirements:"
  center_text "- Archive name: /root/config_backup.tar.gz"
  center_text "- Source directory: /etc/ssh"
  center_text "- Compression: gzip"
  center_text "- Verify contents without extracting"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect the /etc/ssh directory."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "ls /etc/ssh" ]]; then
    print_error "Incorrect. Use: ls /etc/ssh"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  ssh_config"
  echo "  sshd_config"
  echo "  ssh_host_rsa_key"
  echo "  ssh_host_rsa_key.pub"
  echo


  echo "  Step 2: Create a gzip-compressed tar archive of /etc/ssh."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo tar -czf /root/config_backup.tar.gz /etc/ssh" ]]; then
    print_error "Incorrect. Use: sudo tar -czf /root/config_backup.tar.gz /etc/ssh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Verify the archive file exists."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "ls -l /root/config_backup.tar.gz" ]]; then
    print_error "Incorrect. Use: ls -l /root/config_backup.tar.gz"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  -rw-r--r--. 1 root root 20480 Mar 14 13:40 /root/config_backup.tar.gz"
  echo


  echo "  Step 4: View the contents of the archive without extracting it."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo tar -tzf /root/config_backup.tar.gz" ]]; then
    print_error "Incorrect. Use: sudo tar -tzf /root/config_backup.tar.gz"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  etc/ssh/"
  echo "  etc/ssh/ssh_config"
  echo "  etc/ssh/sshd_config"
  echo "  etc/ssh/ssh_host_rsa_key"
  echo "  etc/ssh/ssh_host_rsa_key.pub"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected the SSH configuration directory"
  print_info "- created a gzip compressed tar archive"
  print_info "- verified the archive file exists"
  print_info "- inspected the archive contents without extracting"
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