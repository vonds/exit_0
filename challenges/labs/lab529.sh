#!/bin/bash

# Lab 529: Manage SELinux Port Labels (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 529: Manage SELinux Port Labels"
LAB_ID="lab529"
LAB_XP=52900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab529:~$ "

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
  center_text "A web service must listen on a nonstandard port."
  center_text "SELinux is blocking the bind because the port is not labeled for HTTP."
  center_text "You must inspect current labels, add a new label, verify it,"
  center_text "attempt an invalid operation safely, then remove the label cleanly."
  echo
  center_text "Targets:"
  center_text "- semanage port -l (list SELinux port labels)"
  center_text "- semanage port -a (add label)"
  center_text "- semanage port -m (modify label)"
  center_text "- semanage port -d (delete label)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Confirm SELinux is enabled and note current mode."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sestatus" ]]; then
    print_error "Incorrect. Use: sestatus"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  SELinux status:                 enabled"
  echo "  Current mode:                   enforcing"
  echo

  echo "  Step 2: Ensure the semanage command is available (package: policycoreutils-python-utils)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "rpm -q policycoreutils-python-utils || sudo dnf install -y policycoreutils-python-utils" ]]; then
    print_error "Incorrect. Use: rpm -q policycoreutils-python-utils || sudo dnf install -y policycoreutils-python-utils"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  policycoreutils-python-utils-<version>"
  echo

  echo "  Step 3: List HTTP-related SELinux port labels (http_port_t)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo semanage port -l | grep http_port_t" ]]; then
    print_error "Incorrect. Use: sudo semanage port -l | grep http_port_t"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  http_port_t                    tcp      80, 443, 488, 8008, 8009, 8443"
  echo

  echo "  Step 4: Check whether TCP port 8081 is already labeled for anything."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo semanage port -l | grep '8081'" ]]; then
    print_error "Incorrect. Use: sudo semanage port -l | grep '8081'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (no output)"
  echo

  echo "  Step 5: Add an SELinux port label so HTTP can bind to TCP 8081."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo semanage port -a -t http_port_t -p tcp 8081" ]]; then
    print_error "Incorrect. Use: sudo semanage port -a -t http_port_t -p tcp 8081"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Verify TCP 8081 is now labeled as http_port_t."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo semanage port -l | grep 'http_port_t' | grep '8081'" ]]; then
    print_error "Incorrect. Use: sudo semanage port -l | grep 'http_port_t' | grep '8081'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  http_port_t                    tcp      8081"
  echo

  echo "  Step 7: Try to add the same label again (this should fail because it already exists)."
  echo "          This is an exam-style sanity check so you learn the error and the fix."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo semanage port -a -t http_port_t -p tcp 8081" ]]; then
    print_error "Incorrect. Use: sudo semanage port -a -t http_port_t -p tcp 8081"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ValueError: Port tcp/8081 already defined"
  echo

  echo "  Step 8: Fix that situation the correct way by modifying the existing record (use -m)."
  echo "          Keep it labeled for http_port_t on tcp 8081."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo semanage port -m -t http_port_t -p tcp 8081" ]]; then
    print_error "Incorrect. Use: sudo semanage port -m -t http_port_t -p tcp 8081"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Verify the port is still labeled correctly."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo semanage port -l | grep 'http_port_t' | grep '8081'" ]]; then
    print_error "Incorrect. Use: sudo semanage port -l | grep 'http_port_t' | grep '8081'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  http_port_t                    tcp      8081"
  echo

  echo "  Step 10: Remove the custom SELinux port label for TCP 8081."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo semanage port -d -t http_port_t -p tcp 8081" ]]; then
    print_error "Incorrect. Use: sudo semanage port -d -t http_port_t -p tcp 8081"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 11: Confirm TCP 8081 no longer appears in SELinux port labels."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo semanage port -l | grep '8081'" ]]; then
    print_error "Incorrect. Use: sudo semanage port -l | grep '8081'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (no output)"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- listed current SELinux port labels"
  print_info "- added a custom http_port_t label for a nonstandard port"
  print_info "- verified it with semanage output filtering"
  print_info "- handled the 'already defined' error and used -m correctly"
  print_info "- removed the custom port label cleanly"
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
