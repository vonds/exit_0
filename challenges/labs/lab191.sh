#!/bin/bash

# Lab 191: Script — Batch Create Users with Password=Username (Shell Scripting)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 191: Batch User Creation Script"
LAB_ID="lab191"
LAB_XP=26000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SCRIPT_PATH="/root/bin/create_users.sh"

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
  center_text "Goal: Write a script that creates users user10, user20, user30 with passwords equal to their names."
  center_text "Script must exit if any user creation fails."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create /root/bin (silent)
  draw_lab_ui
  echo "  Step 1: Ensure /root/bin exists."
  echo "          Expected: mkdir -p /root/bin"
  read -p "  lab@lab191:~$ " s1
  [[ "$s1" != "mkdir -p /root/bin" ]] && { print_error "Use: mkdir -p /root/bin"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Write script (show content with echo, not heredoc)
  echo "  Step 2: Create script at $SCRIPT_PATH with the following lines:"
  echo "          #!/bin/bash"
  echo "          for u in user10 user20 user30; do"
  echo "            if useradd \$u; then"
  echo "              echo \"\$u\" | passwd --stdin \$u"
  echo "              echo \"The account \$u is created successfully.\""
  echo "            else"
  echo "              echo \"Failed to create \$u\""
  echo "              exit 1"
  echo "            fi"
  echo "          done"
  echo "          Use: cat > $SCRIPT_PATH"
  read -p "  lab@lab191:~$ " s2
  [[ "$s2" != "cat > /root/bin/create_users.sh" ]] && { print_error "Use: cat > /root/bin/create_users.sh"; read -p "Press Enter to try again..." _; continue; }
  # Simulate writing lines (skip validation for brevity)
  echo

  # Step 3: chmod +x (silent)
  echo "  Step 3: Make the script executable."
  echo "          Expected: chmod +x $SCRIPT_PATH"
  read -p "  lab@lab191:~$ " s3
  [[ "$s3" != "chmod +x /root/bin/create_users.sh" ]] && { print_error "Use: chmod +x /root/bin/create_users.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Display script (use echo instead of EOS heredoc)
  echo "  Step 4: Verify script content with cat."
  echo "          Expected: cat $SCRIPT_PATH"
  read -p "  lab@lab191:~$ " s4
  [[ "$s4" != "cat /root/bin/create_users.sh" ]] && { print_error "Use: cat /root/bin/create_users.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "#!/bin/bash"
  echo "for u in user10 user20 user30; do"
  echo "  if useradd \$u; then"
  echo "    echo \"\$u\" | passwd --stdin \$u"
  echo "    echo \"The account \$u is created successfully.\""
  echo "  else"
  echo "    echo \"Failed to create \$u\""
  echo "    exit 1"
  echo "  fi"
  echo "done"
  echo

  # Step 5: Run the script (simulate realistic output)
  echo "  Step 5: Execute the script."
  echo "          Expected: /root/bin/create_users.sh"
  read -p "  lab@lab191:~$ " s5
  [[ "$s5" != "/root/bin/create_users.sh" ]] && { print_error "Use: /root/bin/create_users.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "Changing password for user user10."
  echo "passwd: all authentication tokens updated successfully."
  echo "The account user10 is created successfully."
  echo "Changing password for user user20."
  echo "passwd: all authentication tokens updated successfully."
  echo "The account user20 is created successfully."
  echo "Changing password for user user30."
  echo "passwd: all authentication tokens updated successfully."
  echo "The account user30 is created successfully."
  echo

  # Step 6: Verify users exist (output from getent)
  echo "  Step 6: Confirm accounts exist."
  echo "          Expected: getent passwd user10 user20 user30"
  read -p "  lab@lab191:~$ " s6
  [[ "$s6" != "getent passwd user10 user20 user30" ]] && { print_error "Use: getent passwd user10 user20 user30"; read -p "Press Enter to try again..." _; continue; }
  echo "user10:x:1001:1001::/home/user10:/bin/bash"
  echo "user20:x:1002:1002::/home/user20:/bin/bash"
  echo "user30:x:1003:1003::/home/user30:/bin/bash"
  echo

  print_success "Nice work!"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
