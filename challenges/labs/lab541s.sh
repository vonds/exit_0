#!/bin/bash

# Lab 541S: Configure Restricted Passwordless sudo for dnf (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541S: Configure Restricted Passwordless sudo for dnf"
LAB_ID="lab541s"
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
  center_text "A junior administrator named alex needs limited elevated access"
  center_text "on ServerA so software packages can be managed with dnf."
  center_text "The access must be tightly restricted."
  echo
  center_text "Requirements:"
  center_text "- Create user: alex"
  center_text "- Allow passwordless sudo for /usr/bin/dnf only"
  center_text "- Do not allow alex to run any other sudo commands"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create the local user account alex."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo useradd alex" && "$cmd1" != "sudo useradd -m alex" ]]; then
    print_error "Incorrect. Use: sudo useradd alex"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [no output]"
  echo


  echo "  Step 2: Verify the account was created."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "id alex" ]]; then
    print_error "Incorrect. Use: id alex"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  uid=1007(alex) gid=1007(alex) groups=1007(alex)"
  echo


  echo "  Step 3: Safely create a sudoers drop-in file granting alex passwordless access to dnf only."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "echo 'alex ALL=(ALL) NOPASSWD: /usr/bin/dnf' | sudo tee /etc/sudoers.d/alex > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Expected exact command to create the sudoers drop-in file."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 4: Fix the permissions on the sudoers drop-in file."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo chmod 440 /etc/sudoers.d/alex" ]]; then
    print_error "Incorrect. Use: sudo chmod 440 /etc/sudoers.d/alex"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [no output]"
  echo


  echo "  Step 5: Validate the sudoers configuration syntax."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo visudo -c" ]]; then
    print_error "Incorrect. Use: sudo visudo -c"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /etc/sudoers: parsed OK"
  echo "  /etc/sudoers.d/alex: parsed OK"
  echo


  echo "  Step 6: Switch to the alex account."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "su - alex" ]]; then
    print_error "Incorrect. Use: su - alex"
    read -p "Press Enter to retry..." _
    continue
  fi
  PROMPT="  alex@servera:~$ "
  echo


  echo "  Step 7: Verify what sudo privileges alex has."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "sudo -l" ]]; then
    print_error "Incorrect. Use: sudo -l"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Matching Defaults entries for alex on servera:"
  echo "      env_reset, mail_badpass, secure_path=/sbin\\:/bin\\:/usr/sbin\\:/usr/bin"
  echo
  echo "  User alex may run the following commands on servera:"
  echo "      (ALL) NOPASSWD: /usr/bin/dnf"
  echo


  echo "  Step 8: Confirm alex can run dnf without being prompted for a password."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "sudo dnf repolist" ]]; then
    print_error "Incorrect. Use: sudo dnf repolist"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  repo id                             repo name"
  echo "  appstream                           Red Hat Enterprise Linux 9 - AppStream"
  echo "  baseos                              Red Hat Enterprise Linux 9 - BaseOS"
  echo


  echo "  Step 9: Confirm alex cannot run another command with sudo."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "sudo cat /etc/shadow" ]]; then
    print_error "Incorrect. Use: sudo cat /etc/shadow"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Sorry, user alex is not allowed to execute '/usr/bin/cat /etc/shadow' as root on servera."
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created the alex account"
  print_info "- created a sudoers drop-in file"
  print_info "- granted passwordless sudo access to /usr/bin/dnf only"
  print_info "- validated the sudoers syntax"
  print_info "- confirmed alex can use dnf with sudo"
  print_info "- confirmed alex cannot run other commands with sudo"
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

  PROMPT="  examuser@servera:~$ "
done