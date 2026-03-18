#!/bin/bash

# Lab 541X: Create a User Audit Script with a Loop (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541X: Create a User Audit Script"
LAB_ID="lab541x"
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
  center_text "You must create a shell script that audits user IDs."
  center_text "The script will iterate through several usernames and"
  center_text "print each username with its UID."
  echo
  center_text "Requirements:"
  center_text "- Script location: /usr/local/bin/user_audit.sh"
  center_text "- Iterate through users: root adm ftp"
  center_text "- Use the id command to obtain each UID"
  center_text "- Output format: User [username] has ID [uid]"
  center_text "- Ensure the script is executable"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Create the script file."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo touch /usr/local/bin/user_audit.sh" ]]; then
    print_error "Incorrect. Use: sudo touch /usr/local/bin/user_audit.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Add the script content using a here-document."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo tee /usr/local/bin/user_audit.sh << 'EOF'" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo tee /usr/local/bin/user_audit.sh << 'EOF'"
    read -p "Press Enter to retry..." _
    continue
  fi

cat << 'EOF'
#!/bin/bash

for user in root adm ftp
do
  uid=$(id -u $user)
  echo "User $user has ID $uid"
done
EOF

  echo "EOF"
  echo


  echo "  Step 3: Make the script executable."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo chmod +x /usr/local/bin/user_audit.sh" ]]; then
    print_error "Incorrect. Use: sudo chmod +x /usr/local/bin/user_audit.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 4: Execute the script to verify output."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "/usr/local/bin/user_audit.sh" ]]; then
    print_error "Incorrect. Use: /usr/local/bin/user_audit.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  User root has ID 0"
  echo "  User adm has ID 3"
  echo "  User ftp has ID 14"
  echo


  echo "  Step 5: Inspect the script to confirm it uses a loop."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "cat /usr/local/bin/user_audit.sh" ]]; then
    print_error "Incorrect. Use: cat /usr/local/bin/user_audit.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  #!/bin/bash"
  echo
  echo "  for user in root adm ftp"
  echo "  do"
  echo "    uid=\$(id -u \$user)"
  echo "    echo \"User \$user has ID \$uid\""
  echo "  done"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created a shell script in /usr/local/bin"
  print_info "- used a loop to iterate through multiple users"
  print_info "- retrieved UIDs programmatically with id"
  print_info "- produced formatted output"
  print_info "- made the script executable"
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