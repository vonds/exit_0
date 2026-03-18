#!/bin/bash

# Lab 541ZD: Create a Conditional File Check Script (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541ZD: Create a Conditional File Check Script"
LAB_ID="lab541zd"
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
  center_text "You need a simple administrative script that checks whether"
  center_text "a file exists before performing operations on it."
  echo
  center_text "Requirements:"
  center_text "- Script name: /usr/local/bin/checkfile.sh"
  center_text "- Accept one argument (filename)"
  center_text "- If file exists: print 'File exists.'"
  center_text "- If file does not exist: print 'File missing.'"
  center_text "- Make the script executable"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Create the script file."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo touch /usr/local/bin/checkfile.sh" ]]; then
    print_error "Incorrect. Use: sudo touch /usr/local/bin/checkfile.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Add the script content using a here-document."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo tee /usr/local/bin/checkfile.sh << 'EOF'" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo tee /usr/local/bin/checkfile.sh << 'EOF'"
    read -p "Press Enter to retry..." _
    continue
  fi

cat << 'EOF'
#!/bin/bash

if [ -e "$1" ]; then
  echo "File exists."
else
  echo "File missing."
fi
EOF

  echo "EOF"
  echo


  echo "  Step 3: Make the script executable."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo chmod +x /usr/local/bin/checkfile.sh" ]]; then
    print_error "Incorrect. Use: sudo chmod +x /usr/local/bin/checkfile.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 4: Test the script with an existing file."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "/usr/local/bin/checkfile.sh /etc/passwd" ]]; then
    print_error "Incorrect. Use: /usr/local/bin/checkfile.sh /etc/passwd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  File exists."
  echo


  echo "  Step 5: Test the script with a missing file."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "/usr/local/bin/checkfile.sh /tmp/not_a_real_file" ]]; then
    print_error "Incorrect. Use: /usr/local/bin/checkfile.sh /tmp/not_a_real_file"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  File missing."
  echo


  echo "  Step 6: Inspect the script contents."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "cat /usr/local/bin/checkfile.sh" ]]; then
    print_error "Incorrect. Use: cat /usr/local/bin/checkfile.sh"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  #!/bin/bash"
  echo
  echo "  if [ -e \"\$1\" ]; then"
  echo "    echo \"File exists.\""
  echo "  else"
  echo "    echo \"File missing.\""
  echo "  fi"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created a shell script"
  print_info "- used a conditional test to check file existence"
  print_info "- handled user input arguments"
  print_info "- made the script executable"
  print_info "- validated both success and failure cases"
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