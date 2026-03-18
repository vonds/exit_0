#!/bin/bash

# Lab 541Y: Search and Extract SSH Configuration Entries (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541Y: Search and Extract SSH Configuration Entries"
LAB_ID="lab541y"
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
  center_text "You must search the SSH server configuration and extract"
  center_text "specific configuration directives."
  echo
  center_text "Requirements:"
  center_text "- Search /etc/ssh/sshd_config"
  center_text "- Find lines beginning with 'Host' (case-insensitive)"
  center_text "- Ignore commented lines"
  center_text "- Save the results to /root/ssh_hosts.txt"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Search for lines starting with Host (case-insensitive) and ignore commented lines."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "grep -i '^host' /etc/ssh/sshd_config" ]]; then
    print_error "Incorrect. Use: grep -i '^host' /etc/ssh/sshd_config"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  HostKey /etc/ssh/ssh_host_rsa_key"
  echo "  HostKey /etc/ssh/ssh_host_ecdsa_key"
  echo "  HostKey /etc/ssh/ssh_host_ed25519_key"
  echo


  echo "  Step 2: Save the matching lines to /root/ssh_hosts.txt."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "grep -i '^host' /etc/ssh/sshd_config | sudo tee /root/ssh_hosts.txt > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: grep -i '^host' /etc/ssh/sshd_config | sudo tee /root/ssh_hosts.txt > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Verify the file was created."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "ls -l /root/ssh_hosts.txt" ]]; then
    print_error "Incorrect. Use: ls -l /root/ssh_hosts.txt"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  -rw-r--r--. 1 root root 129 Mar 15 13:02 /root/ssh_hosts.txt"
  echo


  echo "  Step 4: Inspect the contents of the output file."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo cat /root/ssh_hosts.txt" ]]; then
    print_error "Incorrect. Use: sudo cat /root/ssh_hosts.txt"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  HostKey /etc/ssh/ssh_host_rsa_key"
  echo "  HostKey /etc/ssh/ssh_host_ecdsa_key"
  echo "  HostKey /etc/ssh/ssh_host_ed25519_key"
  echo


  echo "  Step 5: Confirm no commented lines were included."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "grep '^#' /root/ssh_hosts.txt" ]]; then
    print_error "Incorrect. Use: grep '^#' /root/ssh_hosts.txt"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  [no output]"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- searched sshd_config using grep"
  print_info "- used a regular expression to match lines starting with Host"
  print_info "- performed a case-insensitive search"
  print_info "- redirected results to /root/ssh_hosts.txt"
  print_info "- confirmed commented lines were excluded"
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