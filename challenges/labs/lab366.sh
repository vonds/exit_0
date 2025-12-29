#!/bin/bash

# Lab 366: RHEL Troubleshooting — a login shell behaves differently for one user
# Focus: diagnosing login-shell initialization, default shells, and per-user dotfiles
# Key skills: getent/passwd, usermod/chsh, bash login vs interactive behavior,
# ~/.bash_profile vs ~/.bashrc, sudo -iu, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 366: Login Shell Behaves Differently for One User"
LAB_ID="lab366"
LAB_XP=36600
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
  center_text "User 'analyst1' reports that after SSH login their environment is wrong:"
  center_text "- PATH is missing expected entries"
  center_text "- expected aliases (like ll) are missing"
  center_text "- prompt looks basic"
  center_text "Another user (bob) is not affected."
  echo
  center_text "Goal: identify why analyst1's login shell behaves differently and fix it."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm what shell is configured for the user
  echo "  Step 1: Check the configured login shell for analyst1."
  read -p "  lab@rhel-lab366:~$ " cmd1
  echo
  if [[ "$cmd1" != "getent passwd analyst1" && "$cmd1" != "getent passwd analyst1 | cut -d: -f1,7" && "$cmd1" != "getent passwd analyst1 | awk -F: '{print \$1\":\"\$7}'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  analyst1:x:1007:1007:Analyst User:/home/analyst1:/bin/sh"
  echo

  # STEP 2: Confirm bash vs sh init behavior (login shell vs bash)
  echo "  Step 2: As analyst1, confirm which shell is running on login."
  read -p "  lab@rhel-lab366:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo -iu analyst1 sh -lc 'echo \$0'" && \
        "$cmd2" != "sudo -iu analyst1 sh -lc \"echo \\$0\"" && \
        "$cmd2" != "sudo -iu analyst1 bash -lc 'echo \$SHELL'" && \
        "$cmd2" != "sudo -iu analyst1 bash -lc \"echo \\$SHELL\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sh"
  echo

  # STEP 3: Fix the configured login shell (set to bash)
  echo "  Step 3: Set analyst1's login shell to /bin/bash."
  read -p "  lab@rhel-lab366:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo usermod -s /bin/bash analyst1" && "$cmd3" != "sudo chsh -s /bin/bash analyst1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  usermod: shell changed for analyst1"
  echo

  # STEP 4: Verify the change in /etc/passwd view
  echo "  Step 4: Verify analyst1 now has /bin/bash as the login shell."
  read -p "  lab@rhel-lab366:~$ " cmd4
  echo
  if [[ "$cmd4" != "getent passwd analyst1 | cut -d: -f7" && "$cmd4" != "getent passwd analyst1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd4" == "getent passwd analyst1" ]]; then
    echo "  analyst1:x:1007:1007:Analyst User:/home/analyst1:/bin/bash"
  else
    echo "  /bin/bash"
  fi
  echo

  # STEP 5: Diagnose remaining difference: login shell loads ~/.bash_profile, not ~/.bashrc
  echo "  Step 5: Inspect analyst1's ~/.bash_profile to see if it sources ~/.bashrc."
  read -p "  lab@rhel-lab366:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo -iu analyst1 cat ~/.bash_profile" && \
        "$cmd5" != "sudo -iu analyst1 sed -n '1,120p' ~/.bash_profile" && \
        "$cmd5" != "sudo -iu analyst1 grep -n bashrc ~/.bash_profile" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  # .bash_profile for analyst1"
  echo "  PATH=/usr/bin:/bin"
  echo "  export PATH"
  echo "  # Note: does not source ~/.bashrc"
  echo

  # STEP 6: Fix: ensure ~/.bash_profile sources ~/.bashrc for login shells
  echo "  Step 6: Update analyst1's ~/.bash_profile to source ~/.bashrc when present."
  read -p "  lab@rhel-lab366:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo -iu analyst1 bash -lc \"grep -q '\\. ~/.bashrc' ~/.bash_profile || printf '\\n# Load interactive shell settings\\nif [ -f ~/.bashrc ]; then\\n  . ~/.bashrc\\nfi\\n' >> ~/.bash_profile\"" && \
        "$cmd6" != "sudo -iu analyst1 bash -lc \"grep -q 'source ~/.bashrc' ~/.bash_profile || printf '\\n# Load interactive shell settings\\nif [ -f ~/.bashrc ]; then\\n  source ~/.bashrc\\nfi\\n' >> ~/.bash_profile\"" && \
        "$cmd6" != "sudo -iu analyst1 bash -lc \"printf '\\n# Load interactive shell settings\\nif [ -f ~/.bashrc ]; then\\n  . ~/.bashrc\\nfi\\n' >> ~/.bash_profile\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Updated /home/analyst1/.bash_profile"
  echo

  # STEP 7: Verify: simulate a fresh login and confirm expected settings appear
  echo "  Step 7: Simulate a fresh login shell for analyst1 and confirm aliases/settings load."
  read -p "  lab@rhel-lab366:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo -iu analyst1 bash -lc 'alias ll'" && \
        "$cmd7" != "sudo -iu analyst1 bash -lc \"alias ll\"" && \
        "$cmd7" != "sudo -iu analyst1 bash -lc 'echo \$PATH'" && \
        "$cmd7" != "sudo -iu analyst1 bash -lc \"echo \\$PATH\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd7" == *"alias ll"* ]]; then
    echo "  alias ll='ls -alF'"
  else
    echo "  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  fi
  echo

  print_success "Great job."
  print_info "You diagnosed why a single user's login shell behaved differently:"
  print_info "- analyst1 had /bin/sh as the login shell"
  print_info "- bash login shells read ~/.bash_profile; interactive shells read ~/.bashrc"
  print_info "You corrected the shell and ensured ~/.bash_profile sources ~/.bashrc."
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
