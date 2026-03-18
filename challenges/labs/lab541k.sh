#!/bin/bash

# Lab 541K: Create a Shell Script that Flips Arguments (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541K: Create a Script that Flips Arguments"
LAB_ID="lab541k"
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
  center_text "ServerA needs a small utility script that flips the order"
  center_text "of two arguments passed on the command line."
  echo

  center_text "Requirements:"
  center_text "- Script location: /usr/local/bin/flipargs.sh"
  center_text "- Accept exactly two arguments"
  center_text "- Output: second argument first, then first argument"
  echo

  center_text "Example:"
  center_text "./flipargs.sh red blue  ->  blue red"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect the directory where administrative scripts are typically stored."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "ls /usr/local/bin" ]]; then
    print_error "Incorrect. Use: ls /usr/local/bin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Create the flipargs.sh script that prints the second argument followed by the first."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "echo -e '#!/bin/bash\necho \"\$2 \$1\"' | sudo tee /usr/local/bin/flipargs.sh > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo -e '#!/bin/bash\necho \"\$2 \$1\"' | sudo tee /usr/local/bin/flipargs.sh > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Make the script executable by all users."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo chmod 755 /usr/local/bin/flipargs.sh" ]]; then
    print_error "Incorrect. Use: sudo chmod 755 /usr/local/bin/flipargs.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 4: Verify the script permissions."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "ls -l /usr/local/bin/flipargs.sh" ]]; then
    print_error "Incorrect. Use: ls -l /usr/local/bin/flipargs.sh"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  -rwxr-xr-x 1 root root 26 Mar 14 12:15 /usr/local/bin/flipargs.sh"
  echo


  echo "  Step 5: Test the script using two example arguments."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "/usr/local/bin/flipargs.sh red blue" ]]; then
    print_error "Incorrect. Use: /usr/local/bin/flipargs.sh red blue"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  blue red"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created a shell script in /usr/local/bin"
  print_info "- used positional parameters \$1 and \$2"
  print_info "- ensured the script is executable by all users"
  print_info "- verified the script output"
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