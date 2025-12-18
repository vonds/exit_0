#!/bin/bash

# Lab 52: Awk Essentials – Parsing, Filtering, and Formatting Text

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 52: Awk Essentials"
LAB_ID="lab52"
LAB_XP=18000
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

PROMPT="lab@lpic-lab52:~$ "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "In this lab, you’ll practice using awk to parse, filter, and format text."
  center_text "You'll extract fields, apply conditions, and produce custom output."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # ---- Step 1 ----
  echo "  Step 1: Display only the first column from /etc/passwd using awk."
  read -p "  $PROMPT" cmd1
  echo
  if [[ "$cmd1" != "awk -F: '{print \$1}' /etc/passwd" ]]; then
    print_error "  Incorrect. Use awk with -F: and print the first field."
    read -p "  Press Enter to retry the lab..." _
    continue
  fi
  echo "  root"
  echo "  daemon"
  echo "  sys"
  echo "  ..."
  echo

  # ---- Step 2 ----
  echo "  Step 2: Show only lines where UID (3rd field) equals 0."
  read -p "  $PROMPT" cmd2
  echo
  if [[ "$cmd2" != "awk -F: '\$3 == 0 {print \$0}' /etc/passwd" ]]; then
    print_error "  Incorrect. Use condition \$3 == 0 and print the whole line."
    read -p "  Press Enter to retry the lab..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo

  # ---- Step 3 (REPLACEMENT) ----
  echo "  Step 3: Print usernames and their shells in the format 'user -> shell'."
  read -r -p "  $PROMPT" cmd3
  echo

  if [[ "$cmd3" != "awk -F: -v sep=' -> ' '{print \$1 sep \$7}' /etc/passwd" && \
        "$cmd3" != "awk -v sep=' -> ' -F: '{print \$1 sep \$7}' /etc/passwd" ]]; then
      print_error "  Incorrect. Expected exactly one of the two commands shown above."
      read -p "  Press Enter to retry the lab..." _
      continue
  fi

  echo "  root -> /bin/bash"
  echo "  daemon -> /usr/sbin/nologin"
  echo "  sys -> /usr/sbin/nologin"
  echo "  ..."
  echo



  # ---- Step 4 ----
  echo "  Step 4: Count the number of users by piping /etc/passwd into awk."
  read -p "  $PROMPT" cmd4
  echo
  if [[ "$cmd4" != "cat /etc/passwd | awk 'END{print NR}'" ]]; then
    print_error "  Incorrect. Use NR in the END block to count records."
    read -p "  Press Enter to retry the lab..." _
    continue
  fi
  echo "  42"
  echo

  # ---- Step 5 ----
  echo "  Step 5: Print only users whose shell is /bin/bash."
  read -p "  $PROMPT" cmd5
  echo
  if [[ "$cmd5" != "awk -F: '\$7 == \"/bin/bash\" {print \$1}' /etc/passwd" ]]; then
    print_error "  Incorrect. Match field 7 to /bin/bash and print username."
    read -p "  Press Enter to retry the lab..." _
    continue
  fi
  echo "  root"
  echo "  student"
  echo

  print_success "Excellent work!"
  print_info "You’ve completed key awk exercises: field extraction, conditions, formatting, counting, and filtering."
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
