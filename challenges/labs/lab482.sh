#!/bin/bash

# Lab 482: RHCSA Users & Access — Log In and Switch Users in Multiuser Targets

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 482: Log In and Switch Users in Multiuser Targets"
LAB_ID="lab482"
LAB_XP=48200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab482:~$ "

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
  center_text "This system is running in a multi-user environment."
  center_text "You must verify the active target, log in, switch users,"
  center_text "manage root access, and inspect active sessions safely."
  echo
  center_text "User accounts present:"
  center_text "- examuser (standard user)"
  center_text "- root"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Check current default target
  echo "  Step 1: Check the system's default systemd target."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl get-default" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  multi-user.target"
  echo

  # STEP 2: Switch to multi-user.target
  echo "  Step 2: Switch the system to multi-user.target now."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl isolate multi-user.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 3: Make multi-user.target the default
  echo "  Step 3: Set multi-user.target as the default boot target."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl set-default multi-user.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Removed /etc/systemd/system/default.target."
  echo "  Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/multi-user.target."
  echo

  # STEP 4: Switch to root using su
  echo "  Step 4: Switch to the root user using su."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "su -" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Password:"
  echo "  root@rhel-lab482:~#"
  echo

  # STEP 5: Switch back to examuser
  echo "  Step 5: Switch back to examuser using su."
  read -p "  root@rhel-lab482:~# " cmd5
  echo
  if [[ "$cmd5" != "su - examuser" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  examuser@rhel-lab482:~$"
  echo

  # STEP 6: Run a root command using sudo
  echo "  Step 6: Restart sshd using sudo."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl restart sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 7: Edit sudoers to grant examuser sudo access
  echo "  Step 7: Edit sudoers to ensure examuser has sudo privileges."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo visudo" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  examuser ALL=(ALL) ALL"
  echo

  # STEP 8: Lock and unlock examuser
  echo "  Step 8: Lock the examuser account."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo passwd -l examuser" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Locking password for user examuser."
  echo

  echo "  Step 9: Unlock the examuser account."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo passwd -u examuser" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Unlocking password for user examuser."
  echo

  # STEP 10: View logged-in users
  echo "  Step 10: View currently logged-in users."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "who" && "$cmd10" != "w" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd10" == "who" ]]; then
    echo "  examuser  pts/0  2026-01-21 10:44 (192.168.1.20)"
  else
    echo "  USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT"
    echo "  examuser pts/0    192.168.1.20     10:44    1.00s  0.05s  0.02s -bash"
  fi
  echo

  # STEP 11: Log out of the session
  echo "  Step 11: Log out of the current session."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "exit" && "$cmd11" != "logout" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA-critical multiuser skills by:"
  print_info "- verifying and switching systemd targets"
  print_info "- logging in and switching users with su and sudo"
  print_info "- managing sudo privileges safely"
  print_info "- locking and unlocking user accounts"
  print_info "- monitoring logged-in users"
  print_info "- exiting sessions cleanly"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
