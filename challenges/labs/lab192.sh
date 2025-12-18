#!/bin/bash

# Lab 192: Script — Find files owned by new_user (30KB–50KB) → /tmp (Shell Scripting)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 192: Find Files by Owner & Size"
LAB_ID="lab192"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SCRIPT_PATH="/root/bin/find_user_files.sh"
OUT="/tmp/new_user_files.txt"

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
  center_text "Goal: Write a script that finds all files owned by new_user sized >30KB and <50KB and saves the list to $OUT."
  center_text "Hint: find / -xdev -type f -user new_user -size +30k -size -50k 2>/dev/null | sort > $OUT"
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Ensure /root/bin exists (silent)
  draw_lab_ui
  echo "  Step 1: Create /root/bin if needed."
  echo "          Expected: mkdir -p /root/bin"
  read -p "  lab@lab192:~$ " s1
  [[ "$s1" != "mkdir -p /root/bin" ]] && { print_error "Use: mkdir -p /root/bin"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Create script (content preview via echo; write with cat > …)
  echo "  Step 2: Create the script at $SCRIPT_PATH with these lines (use: cat > $SCRIPT_PATH):"
  echo "#!/bin/bash"
  echo 'USER_NAME=${1:-new_user}'
  echo 'OUT="/tmp/new_user_files.txt"'
  echo 'find / -xdev -type f -user "$USER_NAME" -size +30k -size -50k 2>/dev/null | sort > "$OUT"'
  echo 'echo "Saved $OUT"'
  read -p "  lab@lab192:~$ " s2
  [[ "$s2" != "cat > /root/bin/find_user_files.sh" ]] && { print_error "Use exactly: cat > /root/bin/find_user_files.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Make executable (silent)
  echo "  Step 3: Make it executable."
  echo "          Expected: chmod +x $SCRIPT_PATH"
  read -p "  lab@lab192:~$ " s3
  [[ "$s3" != "chmod +x /root/bin/find_user_files.sh" ]] && { print_error "Use: chmod +x /root/bin/find_user_files.sh"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Show script (display expected content)
  echo "  Step 4: Display the script content."
  echo "          Expected: cat $SCRIPT_PATH"
  read -p "  lab@lab192:~$ " s4
  [[ "$s4" != "cat /root/bin/find_user_files.sh" ]] && { print_error "Use: cat /root/bin/find_user_files.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "#!/bin/bash"
  echo 'USER_NAME=${1:-new_user}'
  echo 'OUT="/tmp/new_user_files.txt"'
  echo 'find / -xdev -type f -user "$USER_NAME" -size +30k -size -50k 2>/dev/null | sort > "$OUT"'
  echo 'echo "Saved $OUT"'
  echo

  # Step 5: Run script (shows its own echo output)
  echo "  Step 5: Execute the script for default user (new_user)."
  echo "          Expected: /root/bin/find_user_files.sh"
  read -p "  lab@lab192:~$ " s5
  [[ "$s5" != "/root/bin/find_user_files.sh" ]] && { print_error "Use: /root/bin/find_user_files.sh"; read -p "Press Enter to try again..." _; continue; }
  echo "Saved /tmp/new_user_files.txt"
  echo

  # Step 6: Show first few matches (realistic sample output)
  echo "  Step 6: Show the first 5 lines of $OUT."
  echo "          Expected: head -n 5 $OUT"
  read -p "  lab@lab192:~$ " s6
  [[ "$s6" != "head -n 5 /tmp/new_user_files.txt" ]] && { print_error "Use: head -n 5 /tmp/new_user_files.txt"; read -p "Press Enter to try again..." _; continue; }
  echo "/home/new_user/docs/report.txt"
  echo "/home/new_user/downloads/archive.bin"
  echo "/home/new_user/projects/readme.md"
  echo "/home/new_user/tmp/data.chunk"
  echo "/home/new_user/notes/todo.list"
  echo

  # Step 7: Count matches (prints a number)
  echo "  Step 7: Print total matches."
  echo "          Expected: wc -l $OUT"
  read -p "  lab@lab192:~$ " s7
  [[ "$s7" != "wc -l /tmp/new_user_files.txt" ]] && { print_error "Use: wc -l /tmp/new_user_files.txt"; read -p "Press Enter to try again..." _; continue; }
  echo "42 /tmp/new_user_files.txt"
  echo

  # Step 8 (bonus): Run for a specific user (e.g., user100)
  echo "  Step 8 (bonus): Run for user100 and save again to $OUT."
  echo "          Expected: /root/bin/find_user_files.sh user100"
  read -p "  lab@lab192:~$ " s8
  [[ "$s8" != "/root/bin/find_user_files.sh user100" ]] && { print_error "Use: /root/bin/find_user_files.sh user100"; read -p "Press Enter to try again..." _; continue; }
  echo "Saved /tmp/new_user_files.txt"
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
