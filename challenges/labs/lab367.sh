#!/bin/bash

# Lab 367: RHEL Troubleshooting — a command works for root but not via sudo
# Focus: diagnosing sudo environment differences (secure_path, env_reset) and fixing sudo PATH behavior safely
# Key skills: sudo -l, command -v/which, sudo env, secure_path in sudoers, visudo, and verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 367: Command Works for Root but Not via sudo"
LAB_ID="lab367"
LAB_XP=36700
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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "User 'bob' reports a strange issue:"
  center_text "- As root, the command 'backupctl' runs normally"
  center_text "- But when bob runs 'sudo backupctl', sudo says the command is not found"
  center_text "This breaks a scheduled admin workflow that requires sudo."
  echo
  center_text "Goal: identify why the command works for root but fails via sudo, then fix it safely."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Reproduce the failure as bob using sudo
  echo "  Step 1: Reproduce the reported issue from bob's account."
  read -p "  lab@rhel-lab367:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo backupctl --status" && "$cmd1" != "sudo backupctl -s" && "$cmd1" != "sudo backupctl" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sudo: backupctl: command not found"
  echo

  # STEP 2: Confirm bob is allowed to run it (and observe sudo policies like secure_path)
  echo "  Step 2: Inspect bob's sudo configuration for environment/path clues."
  read -p "  lab@rhel-lab367:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo -l" && "$cmd2" != "sudo -l -U bob" && "$cmd2" != "sudo -l | sed -n '1,200p'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Matching Defaults entries for bob on rhel-lab367:"
  echo "      env_reset, secure_path=/usr/sbin:/usr/bin:/sbin:/bin"
  echo
  echo "  User bob may run the following commands on rhel-lab367:"
  echo "      (ALL) ALL"
  echo

  # STEP 3: As root, show that the command exists and runs, and reveal where it lives
  echo "  Step 3: Become root and locate the real path of the backupctl binary."
  read -p "  lab@rhel-lab367:~$ " cmd3
  echo
  if [[ "$cmd3" != "su -" && "$cmd3" != "sudo -i" && "$cmd3" != "sudo su -" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root@rhel-lab367:~#"
  echo

  echo "  Step 4: Find where 'backupctl' lives on disk."
  read -p "  root@rhel-lab367:~# " cmd4
  echo
  if [[ "$cmd4" != "command -v backupctl" && "$cmd4" != "which backupctl" && "$cmd4" != "type -a backupctl" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /usr/local/sbin/backupctl"
  echo

  # STEP 4: Compare root PATH vs sudo PATH to pinpoint secure_path impact
  echo "  Step 5: Show root's PATH and confirm it includes /usr/local/sbin."
  read -p "  root@rhel-lab367:~# " cmd5
  echo
  if [[ "$cmd5" != "echo \$PATH" && "$cmd5" != "printf '%s\n' \"\$PATH\"" && "$cmd5" != "env | grep '^PATH='" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  echo

  echo "  Step 6: From root, show what PATH sudo uses (secure_path) when running commands."
  read -p "  root@rhel-lab367:~# " cmd6
  echo
  if [[ "$cmd6" != "sudo env | grep '^PATH='" && \
        "$cmd6" != "sudo -n env | grep '^PATH='" && \
        "$cmd6" != "sudo -H env | grep '^PATH='" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PATH=/usr/sbin:/usr/bin:/sbin:/bin"
  echo

  # STEP 5: Immediate workaround: run with full path to prove the diagnosis
  echo "  Step 7: Prove the diagnosis by running backupctl with its full path under sudo."
  read -p "  root@rhel-lab367:~# " cmd7
  echo
  if [[ "$cmd7" != "sudo /usr/local/sbin/backupctl --status" && \
        "$cmd7" != "sudo /usr/local/sbin/backupctl -s" && \
        "$cmd7" != "sudo /usr/local/sbin/backupctl" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  backupctl: status: OK"
  echo

  # STEP 6: Permanent fix: update secure_path safely using visudo
  echo "  Step 8: Fix sudo's secure_path so /usr/local/sbin is included (use visudo)."
  read -p "  root@rhel-lab367:~# " cmd8
  echo
  if [[ "$cmd8" != "visudo" && "$cmd8" != "EDITOR=vim visudo" && "$cmd8" != "EDITOR=nano visudo" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (visudo opened)"
  echo "  Update the Defaults secure_path to include /usr/local/sbin:"
  echo "  Defaults    secure_path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  echo "  (saved and exited)"
  echo

  # STEP 7: Validate sudoers syntax
  echo "  Step 9: Validate the sudoers configuration after your change."
  read -p "  root@rhel-lab367:~# " cmd9
  echo
  if [[ "$cmd9" != "visudo -c" && "$cmd9" != "sudo visudo -c" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /etc/sudoers: parsed OK"
  echo "  /etc/sudoers.d: parsed OK"
  echo

  # STEP 8: Verify as bob that sudo can now find the command without full path
  echo "  Step 10: Return to bob and verify 'sudo backupctl' now works."
  read -p "  root@rhel-lab367:~# " cmd10
  echo
  if [[ "$cmd10" != "exit" && "$cmd10" != "logout" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  lab@rhel-lab367:~$"
  echo

  echo "  Step 11: Run the command again via sudo (without a full path)."
  read -p "  lab@rhel-lab367:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo backupctl --status" && "$cmd11" != "sudo backupctl -s" && "$cmd11" != "sudo backupctl" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  backupctl: status: OK"
  echo

  print_success "Great job."
  print_info "You diagnosed why a command worked for root but failed via sudo:"
  print_info "- backupctl lived in /usr/local/sbin"
  print_info "- sudo used a restricted secure_path that excluded /usr/local/sbin"
  print_info "You verified the workaround (full path) and applied a safe fix via visudo."
  print_info "You earned $LAB_XP XP for completing this lab."
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

  [[ "$choice" == "2" ]] && exit 0
done
