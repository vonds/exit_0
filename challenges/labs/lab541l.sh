#!/bin/bash

# Lab 541L: Configure User Environment and Password Policies (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541L: Configure User Environment and Password Policies"
LAB_ID="lab541l"
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
  center_text "ServerA must enforce consistent defaults for new users."
  center_text "Configure the skeleton directory so new users receive a"
  center_text "Welcome.txt file, then configure password aging and minimum"
  center_text "password length requirements."
  echo

  center_text "Requirements:"
  center_text "- New users get Welcome.txt in their home directory"
  center_text "- Passwords must be changed every 90 days"
  center_text "- New passwords must be at least 8 characters long"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect the skeleton directory used for new user home directories."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "ls /etc/skel" ]]; then
    print_error "Incorrect. Use: ls /etc/skel"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Create /etc/skel/Welcome.txt so every new user receives it."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "echo 'Welcome to ServerA' | sudo tee /etc/skel/Welcome.txt > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'Welcome to ServerA' | sudo tee /etc/skel/Welcome.txt > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Verify the Welcome.txt file exists in /etc/skel."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "ls /etc/skel" ]]; then
    print_error "Incorrect. Use: ls /etc/skel"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Welcome.txt"
  echo


  echo "  Step 4: Inspect the default password aging settings."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "grep '^PASS_MAX_DAYS' /etc/login.defs" ]]; then
    print_error "Incorrect. Use: grep '^PASS_MAX_DAYS' /etc/login.defs"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  PASS_MAX_DAYS   99999"
  echo


  echo "  Step 5: Configure the default maximum password age to 90 days."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs" ]]; then
    print_error "Incorrect. Use: sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 6: Verify the password aging setting was updated."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "grep '^PASS_MAX_DAYS' /etc/login.defs" ]]; then
    print_error "Incorrect. Use: grep '^PASS_MAX_DAYS' /etc/login.defs"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  PASS_MAX_DAYS   90"
  echo


  echo "  Step 7: Inspect the current password quality minimum length setting."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "grep '^minlen' /etc/security/pwquality.conf" ]]; then
    print_error "Incorrect. Use: grep '^minlen' /etc/security/pwquality.conf"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  # no active minlen setting found"
  echo


  echo "  Step 8: Configure the minimum password length to 8 characters."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "echo 'minlen = 8' | sudo tee -a /etc/security/pwquality.conf > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'minlen = 8' | sudo tee -a /etc/security/pwquality.conf > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 9: Verify the password minimum length setting."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "grep '^minlen' /etc/security/pwquality.conf" ]]; then
    print_error "Incorrect. Use: grep '^minlen' /etc/security/pwquality.conf"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  minlen = 8"
  echo


  echo "  Step 10: Create a test user to verify the skeleton directory behavior."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "sudo useradd testuser1" ]]; then
    print_error "Incorrect. Use: sudo useradd testuser1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 11: Verify the new user received Welcome.txt in the home directory."
  read -p "$PROMPT" cmd11
  echo

  if [[ "$cmd11" != "ls /home/testuser1" ]]; then
    print_error "Incorrect. Use: ls /home/testuser1"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Welcome.txt"
  echo


  echo "  Step 12: Verify the new user's maximum password age is 90 days."
  read -p "$PROMPT" cmd12
  echo

  if [[ "$cmd12" != "sudo chage -l testuser1" ]]; then
    print_error "Incorrect. Use: sudo chage -l testuser1"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Last password change                                    : never"
  echo "  Password expires                                        : 90 days after password is set"
  echo "  Password inactive                                       : never"
  echo "  Account expires                                         : never"
  echo "  Minimum number of days between password change          : 0"
  echo "  Maximum number of days between password change          : 90"
  echo "  Number of days of warning before password expires       : 7"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- configured the skeleton directory for new users"
  print_info "- ensured Welcome.txt is copied into new home directories"
  print_info "- set the default password maximum age to 90 days"
  print_info "- configured minimum password length to 8 characters"
  print_info "- verified the settings with a test user"
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