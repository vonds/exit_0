#!/bin/bash

# Lab 193: Script — Backup small files from /usr → /root/backup (Shell Scripting)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 193: Backup Small Files from /usr"
LAB_ID="lab193"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SCRIPT_PATH="/root/backup.sh"

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
  center_text "Goal: Write /root/backup.sh that copies files <2M from /usr into /root/backup, preserving paths."
  center_text "Hint: find /usr -xdev -type f -size -2M -print0 | xargs -0 -I{} cp --parents -a \"{}\" /root/backup"
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create the script file (silent)
  draw_lab_ui
  echo "  Step 1: Create the script at $SCRIPT_PATH (use: cat > $SCRIPT_PATH) with lines:"
  echo "#!/bin/bash"
  echo 'set -e'
  echo 'DEST="/root/backup"'
  echo 'mkdir -p "$DEST"'
  echo 'find /usr -xdev -type f -size -2M -print0 | xargs -0 -I{} cp --parents -a "{}" "$DEST"'
  echo 'echo "Backup complete: $(date +%F)"'
  read -p "  lab@lab193:~$ " s1
  [[ "$s1" != "cat > /root/backup.sh" ]] && { print_error "Use exactly: cat > /root/backup.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Make executable (silent)
  echo "  Step 2: Make the script executable."
  echo "          Expected: chmod +x $SCRIPT_PATH"
  read -p "  lab@lab193:~$ " s2
  [[ "$s2" != "chmod +x /root/backup.sh" ]] && { print_error "Use: chmod +x /root/backup.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Show script content (real cat output via echo lines)
  echo "  Step 3: Display the script."
  echo "          Expected: cat $SCRIPT_PATH"
  read -p "  lab@lab193:~$ " s3
  [[ "$s3" != "cat /root/backup.sh" ]] && { print_error "Use: cat /root/backup.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "#!/bin/bash"
  echo "set -e"
  echo 'DEST="/root/backup"'
  echo 'mkdir -p "$DEST"'
  echo 'find /usr -xdev -type f -size -2M -print0 | xargs -0 -I{} cp --parents -a "{}" "$DEST"'
  echo 'echo "Backup complete: $(date +%F)"'
  echo

  # Step 4: Run the script (shows its own echo output)
  echo "  Step 4: Execute the script."
  echo "          Expected: /root/backup.sh"
  read -p "  lab@lab193:~$ " s4
  [[ "$s4" != "/root/backup.sh" ]] && { print_error "Use: /root/backup.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "Backup complete: $(date +%F)"
  echo

  # Step 5: Verify backup paths (realistic sample lines)
  echo "  Step 5: Show a few files that were copied (preserved under /root/backup/usr/...)."
  echo "          Expected: find /root/backup | head -n 5"
  read -p "  lab@lab193:~$ " s5
  [[ "$s5" != "find /root/backup | head -n 5" ]] && { print_error "Use: find /root/backup | head -n 5"; read -p "Press Enter to try again..." _; continue; }
  echo "/root/backup"
  echo "/root/backup/usr"
  echo "/root/backup/usr/bin"
  echo "/root/backup/usr/bin/locale"
  echo "/root/backup/usr/lib/charset.alias"
  echo

  # Step 6: Size of backup directory
  echo "  Step 6: Show total size of /root/backup."
  echo "          Expected: du -sh /root/backup"
  read -p "  lab@lab193:~$ " s6
  [[ "$s6" != "du -sh /root/backup" ]] && { print_error "Use: du -sh /root/backup"; read -p "Press Enter to try again..." _; continue; }
  echo "68M	/root/backup"
  echo

  # Step 7: Count files copied
  echo "  Step 7: Count copied files."
  echo "          Expected: find /root/backup -type f | wc -l"
  read -p "  lab@lab193:~$ " s7
  [[ "$s7" != "find /root/backup -type f | wc -l" ]] && { print_error "Use: find /root/backup -type f | wc -l"; read -p "Press Enter to try again..." _; continue; }
  echo "1350"
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
