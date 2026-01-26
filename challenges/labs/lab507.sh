#!/bin/bash

# Lab 507: Create and Configure set-GID Directories for Collaboration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 507: set-GID Collaboration Directories"
LAB_ID="lab507"
LAB_XP=50700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab507:~$ "

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
  center_text "Your team needs a shared directory where multiple users can collaborate."
  center_text "All files created must inherit the same group ownership automatically."
  echo
  center_text "Targets:"
  center_text "- Group: projectgroup"
  center_text "- Users: alice, bob"
  center_text "- Shared directory: /shared/project"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create the group projectgroup."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo groupadd projectgroup" ]]; then
    print_error "Incorrect. Use: sudo groupadd projectgroup"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Add users alice and bob to projectgroup."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo usermod -aG projectgroup alice && sudo usermod -aG projectgroup bob" ]]; then
    print_error "Incorrect. Use: sudo usermod -aG projectgroup alice && sudo usermod -aG projectgroup bob"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Verify group membership for alice."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "groups alice" ]]; then
    print_error "Incorrect. Use: groups alice"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  alice : alice projectgroup"
  echo

  echo "  Step 4: Verify group membership for bob."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "groups bob" ]]; then
    print_error "Incorrect. Use: groups bob"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  bob : bob projectgroup"
  echo

  echo "  Step 5: Create the shared directory /shared/project."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo mkdir -p /shared/project" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /shared/project"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Change group ownership of the directory."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo chgrp projectgroup /shared/project" ]]; then
    print_error "Incorrect. Use: sudo chgrp projectgroup /shared/project"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Set permissions and enable the set-GID bit."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo chmod 2775 /shared/project" ]]; then
    print_error "Incorrect. Use: sudo chmod 2775 /shared/project"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Verify directory permissions."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "ls -ld /shared/project" ]]; then
    print_error "Incorrect. Use: ls -ld /shared/project"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  drwxrwsr-x 2 root projectgroup 4096 /shared/project"
  echo

  echo "  Step 9: Switch to user alice."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo su - alice" ]]; then
    print_error "Incorrect. Use: sudo su - alice"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Create a file in the shared directory."
  read -p "  alice@rhel-lab507:~$ " cmd10
  echo
  if [[ "$cmd10" != "touch /shared/project/alicefile" ]]; then
    print_error "Incorrect. Use: touch /shared/project/alicefile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 11: Verify file ownership."
  read -p "  alice@rhel-lab507:~$ " cmd11
  echo
  if [[ "$cmd11" != "ls -l /shared/project/alicefile" ]]; then
    print_error "Incorrect. Use: ls -l /shared/project/alicefile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-rw-r-- 1 alice projectgroup 0 /shared/project/alicefile"
  echo

  echo "  Step 12: Exit alice shell."
  read -p "  alice@rhel-lab507:~$ " cmd12
  echo
  if [[ "$cmd12" != "exit" ]]; then
    print_error "Incorrect. Use: exit"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 13: Switch to user bob."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo su - bob" ]]; then
    print_error "Incorrect. Use: sudo su - bob"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 14: Create a file in the shared directory."
  read -p "  bob@rhel-lab507:~$ " cmd14
  echo
  if [[ "$cmd14" != "touch /shared/project/bobfile" ]]; then
    print_error "Incorrect. Use: touch /shared/project/bobfile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 15: Verify file ownership."
  read -p "  bob@rhel-lab507:~$ " cmd15
  echo
  if [[ "$cmd15" != "ls -l /shared/project/bobfile" ]]; then
    print_error "Incorrect. Use: ls -l /shared/project/bobfile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-rw-r-- 1 bob projectgroup 0 /shared/project/bobfile"
  echo

  echo "  Step 16: Exit bob shell."
  read -p "  bob@rhel-lab507:~$ " cmd16
  echo
  if [[ "$cmd16" != "exit" ]]; then
    print_error "Incorrect. Use: exit"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created a collaboration group"
  print_info "- assigned users to the group"
  print_info "- configured a set-GID directory"
  print_info "- validated group inheritance behavior"
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
