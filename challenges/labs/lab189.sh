#!/bin/bash

# Lab 189: Script — Show hostname, system info, logged-in users (Shell Scripting)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 189: Sysinfo Script"
LAB_ID="lab189"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SCRIPT_PATH="/root/bin/sysinfo.sh"

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
  center_text "Goal: Create an executable script that prints hostname, kernel version, and logged-in users."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Make directory (silent)
  draw_lab_ui
  echo "  Step 1: Create /root/bin if needed."
  echo "          Expected: mkdir -p /root/bin"
  read -p "  lab@lab189:~$ " s1
  [[ "$s1" != "mkdir -p /root/bin" ]] && { print_error "Use: mkdir -p /root/bin"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Create the script via heredoc (silent)
  echo "  Step 2: Create the script at $SCRIPT_PATH with this content:"
  echo "          #!/bin/bash"
  echo "          echo \"Hostname: \$(hostname)\""
  echo "          echo \"Kernel: \$(uname -r)\""
  echo "          echo \"Logged-in users:\""
  echo "          who"
  echo "          Use a heredoc, e.g.: cat > $SCRIPT_PATH <<'EOF' ... EOF"
  read -p "  lab@lab189:~$ " s2
  [[ "$s2" != "cat > /root/bin/sysinfo.sh <<'EOF'" ]] && { print_error "Begin heredoc exactly: cat > /root/bin/sysinfo.sh <<'EOF'"; read -p "Press Enter to try again..." _; continue; }
  # Read the heredoc body lines
  read body1; read body2; read body3; read body4
  [[ "$body1" != "#!/bin/bash" || "$body2" != "echo \"Hostname: \$(hostname)\"" || "$body3" != "echo \"Kernel: \$(uname -r)\"" || "$body4" != "echo \"Logged-in users:\"" ]] && {
    print_error "Script lines must match the shown content (first 4 lines).";
    read -p "Press Enter to try again..." _; continue; }
  read body5
  [[ "$body5" != "who" ]] && { print_error "Fifth line must be: who"; read -p "Press Enter to try again..." _; continue; }
  # Expect EOF to close
  read eofline
  [[ "$eofline" != "EOF" ]] && { print_error "Close heredoc with: EOF"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Make executable (silent)
  echo "  Step 3: Make the script executable."
  echo "          Expected: chmod +x $SCRIPT_PATH"
  read -p "  lab@lab189:~$ " s3
  [[ "$s3" != "chmod +x /root/bin/sysinfo.sh" ]] && { print_error "Use: chmod +x /root/bin/sysinfo.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Show script content (outputs the file)
  echo "  Step 4: Display the script to verify content."
  echo "          Expected: cat $SCRIPT_PATH"
  read -p "  lab@lab189:~$ " s4
  [[ "$s4" != "cat /root/bin/sysinfo.sh" ]] && { print_error "Use: cat /root/bin/sysinfo.sh"; read -p "Press Enter to try again..." _; continue; }
  cat <<'EOS'
#!/bin/bash
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Logged-in users:"
who
EOS
  echo

  # Step 5: Run the script (show realistic output)
  echo "  Step 5: Execute the script."
  echo "          Expected: /root/bin/sysinfo.sh"
  read -p "  lab@lab189:~$ " s5
  [[ "$s5" != "/root/bin/sysinfo.sh" ]] && { print_error "Use: /root/bin/sysinfo.sh"; read -p "Press Enter to try again..." _; continue; }
  # Simulated terminal-like output
  echo "Hostname: server1.example.com"
  echo "Kernel: 5.14.0-427.24.1.el9_4.x86_64"
  echo "Logged-in users:"
  echo "root     pts/0        $(date +'%b %e %H:%M') (10.0.2.2)"
  echo

  # Step 6 (bonus): Run via bash (outputs again)
  echo "  Step 6 (bonus): Run it via bash."
  echo "          Expected: bash $SCRIPT_PATH"
  read -p "  lab@lab189:~$ " s6
  [[ "$s6" != "bash /root/bin/sysinfo.sh" ]] && { print_error "Use: bash /root/bin/sysinfo.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "Hostname: server1.example.com"
  echo "Kernel: 5.14.0-427.24.1.el9_4.x86_64"
  echo "Logged-in users:"
  echo "root     pts/0        $(date +'%b %e %H:%M') (10.0.2.2)"
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
