#!/bin/bash

# Lab 190: Script — Count & List Arguments, Show PID (Shell Scripting)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 190: Argument Script"
LAB_ID="lab190"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SCRIPT_PATH="/root/bin/argsinfo.sh"

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
  center_text "Goal: Create an executable script that shows argument count, first argument, PID, and all args."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create /root/bin directory (silent)
  draw_lab_ui
  echo "  Step 1: Create /root/bin if it doesn't exist."
  echo "          Expected: mkdir -p /root/bin"
  read -p "  lab@lab190:~$ " s1
  [[ "$s1" != "mkdir -p /root/bin" ]] && { print_error "Use: mkdir -p /root/bin"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Create script via heredoc (silent)
  echo "  Step 2: Create the script at $SCRIPT_PATH with this content:"
  echo "          #!/bin/bash"
  echo "          echo \"Argument count: \$#\""
  echo "          echo \"First argument: \$1\""
  echo "          echo \"Script PID: \$$\""
  echo "          echo \"All arguments: \$@\""
  echo "          Use heredoc to write file."
  read -p "  lab@lab190:~$ " s2
  [[ "$s2" != "cat > /root/bin/argsinfo.sh <<'EOF'" ]] && { print_error "Begin heredoc exactly: cat > /root/bin/argsinfo.sh <<'EOF'"; read -p "Press Enter to try again..." _; continue; }
  # Read heredoc lines
  read l1; read l2; read l3; read l4; read l5
  [[ "$l1" != "#!/bin/bash" || "$l2" != "echo \"Argument count: \$#\"" || "$l3" != "echo \"First argument: \$1\"" || "$l4" != "echo \"Script PID: \$$\"" || "$l5" != "echo \"All arguments: \$@\"" ]] && {
    print_error "Script lines must match exactly as shown.";
    read -p "Press Enter to try again..." _; continue; }
  read l6
  [[ "$l6" != "EOF" ]] && { print_error "Close heredoc with: EOF"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: chmod +x (silent)
  echo "  Step 3: Make script executable."
  echo "          Expected: chmod +x $SCRIPT_PATH"
  read -p "  lab@lab190:~$ " s3
  [[ "$s3" != "chmod +x /root/bin/argsinfo.sh" ]] && { print_error "Use: chmod +x /root/bin/argsinfo.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Show script content (realistic cat)
  echo "  Step 4: Display script content."
  echo "          Expected: cat $SCRIPT_PATH"
  read -p "  lab@lab190:~$ " s4
  [[ "$s4" != "cat /root/bin/argsinfo.sh" ]] && { print_error "Use: cat /root/bin/argsinfo.sh"; read -p "Press Enter to try again..." _; continue; }
  cat <<'EOS'
#!/bin/bash
echo "Argument count: $#"
echo "First argument: $1"
echo "Script PID: $$"
echo "All arguments: $@"
EOS
  echo

  # Step 5: Run script with 3 arguments (shows output)
  echo "  Step 5: Run the script with arguments: red blue green"
  echo "          Expected: /root/bin/argsinfo.sh red blue green"
  read -p "  lab@lab190:~$ " s5
  [[ "$s5" != "/root/bin/argsinfo.sh red blue green" ]] && { print_error "Use: /root/bin/argsinfo.sh red blue green"; read -p "Press Enter to try again..." _; continue; }
  echo "Argument count: 3"
  echo "First argument: red"
  echo "Script PID: 4321"
  echo "All arguments: red blue green"
  echo

  # Step 6: Run script with 1 argument (shows output)
  echo "  Step 6: Run script with one argument: hello"
  echo "          Expected: /root/bin/argsinfo.sh hello"
  read -p "  lab@lab190:~$ " s6
  [[ "$s6" != "/root/bin/argsinfo.sh hello" ]] && { print_error "Use: /root/bin/argsinfo.sh hello"; read -p "Press Enter to try again..." _; continue; }
  echo "Argument count: 1"
  echo "First argument: hello"
  echo "Script PID: 4322"
  echo "All arguments: hello"
  echo

  # Step 7: Run script with no arguments (shows output)
  echo "  Step 7: Run script with no arguments."
  echo "          Expected: /root/bin/argsinfo.sh"
  read -p "  lab@lab190:~$ " s7
  [[ "$s7" != "/root/bin/argsinfo.sh" ]] && { print_error "Use: /root/bin/argsinfo.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "Argument count: 0"
  echo "First argument: "
  echo "Script PID: 4323"
  echo "All arguments: "
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
