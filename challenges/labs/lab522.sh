#!/bin/bash

# Lab 522: Configure Default User Account Settings (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 522: Default User Account Settings (RHCSA)"
LAB_ID="lab522"
LAB_XP=52200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab522:~$ "

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
  center_text "Your team is onboarding multiple users. New accounts must follow a consistent"
  center_text "standard: correct defaults, correct skeleton files, and predictable results."
  center_text "You must inspect and change default account settings, validate them, then"
  center_text "create a user to prove the defaults were applied."
  echo
  center_text "Targets:"
  center_text "- /etc/login.defs (UMASK)"
  center_text "- /etc/default/useradd (defaults)"
  center_text "- /etc/skel (skeleton files)"
  center_text "- useradd -D (view defaults)"
  center_text "- verify results via ls, getent, and grep"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Display the current useradd default settings."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "useradd -D" ]]; then
    print_error "Incorrect. Use: useradd -D"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  GROUP=100"
  echo "  HOME=/home"
  echo "  INACTIVE=-1"
  echo "  EXPIRE="
  echo "  SHELL=/bin/bash"
  echo "  SKEL=/etc/skel"
  echo "  CREATE_MAIL_SPOOL=yes"
  echo

  echo "  Step 2: Open /etc/default/useradd in vim."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo vim /etc/default/useradd" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/default/useradd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Verify the system's default login UMASK setting in /etc/login.defs."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "grep -E '^UMASK' /etc/login.defs" ]]; then
    print_error "Incorrect. Use: grep -E '^UMASK' /etc/login.defs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  UMASK           022"
  echo

  echo "  Step 4: Open /etc/login.defs in vim."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo vim /etc/login.defs" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/login.defs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Create a standard onboarding message file in /etc/skel named WELCOME.txt."
  echo "          The file must contain a single line: 'Welcome to the system'."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "echo 'Welcome to the system' | sudo tee /etc/skel/WELCOME.txt" ]]; then
    print_error "Incorrect. Use: echo 'Welcome to the system' | sudo tee /etc/skel/WELCOME.txt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Welcome to the system"
  echo

  echo "  Step 6: Verify /etc/skel/WELCOME.txt exists and has the correct content."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo cat /etc/skel/WELCOME.txt" ]]; then
    print_error "Incorrect. Use: sudo cat /etc/skel/WELCOME.txt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Welcome to the system"
  echo

  echo "  Step 7: Create a new user named onboard1 with a home directory."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo useradd -m onboard1" ]]; then
    print_error "Incorrect. Use: sudo useradd -m onboard1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Verify onboard1 was created and confirm their home directory from /etc/passwd."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "getent passwd onboard1" ]]; then
    print_error "Incorrect. Use: getent passwd onboard1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  onboard1:x:1001:1001::/home/onboard1:/bin/bash"
  echo

  echo "  Step 9: Verify that WELCOME.txt was copied from /etc/skel into /home/onboard1."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo ls -l /home/onboard1/WELCOME.txt" ]]; then
    print_error "Incorrect. Use: sudo ls -l /home/onboard1/WELCOME.txt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-r--r-- 1 onboard1 onboard1 22 /home/onboard1/WELCOME.txt"
  echo

  echo "  Step 10: Confirm the content of /home/onboard1/WELCOME.txt."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo cat /home/onboard1/WELCOME.txt" ]]; then
    print_error "Incorrect. Use: sudo cat /home/onboard1/WELCOME.txt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Welcome to the system"
  echo

  echo "  Step 11: Lock the onboard1 account (do not set a password)."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo passwd -l onboard1" ]]; then
    print_error "Incorrect. Use: sudo passwd -l onboard1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Locking password for user onboard1."
  echo "  passwd: Success"
  echo

  echo "  Step 12: Verify the account is locked by checking the onboard1 entry in /etc/shadow."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo grep '^onboard1:' /etc/shadow" ]]; then
    print_error "Incorrect. Use: sudo grep '^onboard1:' /etc/shadow"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  onboard1:!!:20123:0:99999:7:::"
  echo

  echo "  Step 13: Clean up: delete onboard1 and remove their home directory."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo userdel -r onboard1" ]]; then
    print_error "Incorrect. Use: sudo userdel -r onboard1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected default useradd settings"
  print_info "- worked with /etc/default/useradd and /etc/login.defs (via vim)"
  print_info "- managed /etc/skel to enforce consistent new-user files"
  print_info "- verified new user creation and skeleton file copying"
  print_info "- locked an account and validated the /etc/shadow state"
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
