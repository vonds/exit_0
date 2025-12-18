#!/bin/bash

# Lab 302: Writing and Using Functions in Bash – Objective 105.1 (Interactive)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 302"
LAB_ID="lab302"
LAB_XP=55200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
}

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

PROMPT="student@lab302:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Objective 105.1 — Writing and Using Functions in Bash"
  center_text "Tasks use terminal commands only—no written sentences."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # Step 1
  echo "  Step 1: Declare a function named 'show_date' using the form with a keyword and braces (single line, minimal structure)."
  read -p "  $PROMPT" cmd1
  echo
  if [[ "$cmd1" != "function show_date { }" ]]; then
    print_error "Follow the keyword-based function form with the given name and braces."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Accepted."
  echo

  # Step 2
  echo "  Step 2: Declare the same function using the form without the keyword (single line, minimal structure)."
  read -p "  $PROMPT" cmd2
  echo
  if [[ "$cmd2" != "show_date() { }" ]]; then
    print_error "Follow the name-with-parentheses form and braces."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Accepted."
  echo

  # Step 3
  echo "  Step 3: Invoke the function named 'show_date'."
  read -p "  $PROMPT" cmd3
  echo
  if [[ "$cmd3" != "show_date" ]]; then
    print_error "Invoke by typing only the function name."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Function call recognized."
  echo

  # Step 4
  echo "  Step 4: Print the exit status of the previously executed command."
  read -p "  $PROMPT" cmd4
  echo
  if [[ "$cmd4" != "echo \$?" ]]; then
    print_error "Print the special variable that holds the last command's status."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  0"
  echo

  # Step 5
  echo "  Step 5: Inside a function, output the first two positional parameters on one line (in order)."
  read -p "  $PROMPT" cmd5
  echo
  if [[ "$cmd5" != "echo \$1 \$2" ]]; then
    print_error "Use the first two positional parameters separated by a space."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Output: arg1 arg2"
  echo

  # Step 6
  echo "  Step 6: List the functions currently defined in the shell."
  read -p "  $PROMPT" cmd6
  echo
  if [[ "$cmd6" != "declare -f" && "$cmd6" != "declare -F" ]]; then
    print_error "Use a built-in that lists defined functions."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  show_date  ()"
  echo "  backup_home  ()"
  echo

  # Step 7
  echo "  Step 7: Provide one absolute path under /etc used for system-wide shell initialization (valid locations only)."
  read -p "  $PROMPT" cmd7
  echo
  # Accept common global init locations without revealing them in prompts/errors
  if [[ "$cmd7" != "/etc/profile" && "$cmd7" != "/etc/bashrc" && "$cmd7" != "/etc/bash.bashrc" && "$cmd7" != "/etc/profile.d" ]]; then
    print_error "Provide a valid absolute path under /etc used for shell startup."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Accepted."
  echo

  # Step 8
  echo "  Step 8: Show the contents of the user's Bash initialization file in the home directory."
  read -p "  $PROMPT" cmd8
  echo
  if [[ "$cmd8" != "cat ~/.bashrc" ]]; then
    print_error "Display the file contents using an appropriate command."
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  function greet_user() {"
  echo "    echo 'Welcome back, $USER!'"
  echo "  }"
  echo

  print_success "Excellent work!"
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done
