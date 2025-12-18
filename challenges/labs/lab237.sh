#!/bin/bash

# Lab 237: Package Group Management — "System Tools" — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real changes occur.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 237: Package Group Management (System Tools)"
LAB_ID="lab237"
LAB_XP=20750
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

GROUP_NAME="System Tools"

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
  center_text "Goal: List groups, inspect \"${GROUP_NAME}\", install it, verify, then remove it (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: List available groups
  draw_lab_ui
  echo "  Step 1: List package groups."
  read -p "  lab@lab237:~$ " cmd1
  if [[ "$cmd1" == "dnf group list" || "$cmd1" == "yum group list" ]]; then
    echo "  Available Environment Groups:"
    echo "     Server with GUI"
    echo "     Minimal Install"
    echo "  Installed Environment Groups:"
    echo "     (none)"
    echo "  Installed Groups:"
    echo "     Core"
    echo "  Available Groups:"
    echo "     ${GROUP_NAME}"
    echo "     Development Tools"
    echo "  Done!"
  else
    print_error "Hint: Use your package manager to list groups."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Show info for System Tools group
  echo "  Step 2: Show details for the \"${GROUP_NAME}\" group."
  read -p "  lab@lab237:~$ " cmd2
  if [[ "$cmd2" == "dnf group info \"${GROUP_NAME}\"" || "$cmd2" == "yum group info \"${GROUP_NAME}\"" ]]; then
    echo "  Group: ${GROUP_NAME}"
    echo "   Description: Common utilities useful for system administration."
    echo "   Mandatory Packages:"
    echo "     lsof"
    echo "     psmisc"
    echo "   Default Packages:"
    echo "     tree"
    echo "     tmux"
    echo "     screen"
    echo "     strace"
    echo "     wget"
    echo "     rsync"
  else
    print_error "Hint: Use the group info subcommand with the group name."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Install System Tools group
  echo "  Step 3: Install the \"${GROUP_NAME}\" group."
  read -p "  lab@lab237:~$ " cmd3
  if [[ "$cmd3" == "dnf group install -y \"${GROUP_NAME}\"" || "$cmd3" == "dnf group install \"${GROUP_NAME}\"" || \
        "$cmd3" == "yum groupinstall -y \"${GROUP_NAME}\"" || "$cmd3" == "yum groupinstall \"${GROUP_NAME}\"" ]]; then
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Group            Packages                                         Size"
    echo "  ================================================================================"
    echo "  Installing group:"
    echo "   ${GROUP_NAME}    lsof, psmisc, tree, tmux, screen, strace, wget, rsync"
    echo
    echo "  Installed:"
    echo "    lsof-4.93.x86_64"
    echo "    psmisc-23.x86_64"
    echo "    tree-1.8.x86_64"
    echo "    tmux-3.1.x86_64"
    echo "    screen-4.8.x86_64"
    echo "    strace-5.x86_64"
    echo "    wget-1.20.x86_64"
    echo "    rsync-3.1.x86_64"
  else
    print_error "Hint: Use group install/groupinstall with the group name."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify group shows as installed (or verify a key package)
  echo "  Step 4: Verify installation."
  read -p "  lab@lab237:~$ " cmd4
  if [[ "$cmd4" == "dnf group list --installed" || "$cmd4" == "yum group list installed" ]]; then
    echo "  Installed Groups:"
    echo "     Core"
    echo "     ${GROUP_NAME}"
  elif [[ "$cmd4" == "rpm -q lsof" ]]; then
    echo "  lsof-4.93.x86_64"
  else
    print_error "Hint: List installed groups or query a package like 'lsof'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Remove the System Tools group
  echo "  Step 5: Remove the \"${GROUP_NAME}\" group."
  read -p "  lab@lab237:~$ " cmd5
  if [[ "$cmd5" == "dnf group remove -y \"${GROUP_NAME}\"" || "$cmd5" == "dnf group remove \"${GROUP_NAME}\"" || \
        "$cmd5" == "yum groupremove -y \"${GROUP_NAME}\"" || "$cmd5" == "yum groupremove \"${GROUP_NAME}\"" ]]; then
    echo "  Resolving group removal:"
    echo "   ${GROUP_NAME} -> lsof, psmisc, tree, tmux, screen, strace, wget, rsync"
    echo "  Removed:"
    echo "    lsof-4.93.x86_64"
    echo "    psmisc-23.x86_64"
    echo "    tree-1.8.x86_64"
    echo "    tmux-3.1.x86_64"
    echo "    screen-4.8.x86_64"
    echo "    strace-5.x86_64"
    echo "    wget-1.20.x86_64"
    echo "    rsync-3.1.x86_64"
  else
    print_error "Hint: Use group remove/groupremove with the group name."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Confirm removal
  echo "  Step 6: Confirm the group/packages are gone."
  read -p "  lab@lab237:~$ " cmd6
  if [[ "$cmd6" == "dnf group list --installed" || "$cmd6" == "yum group list installed" ]]; then
    echo "  Installed Groups:"
    echo "     Core"
  elif [[ "$cmd6" == "rpm -q lsof" ]]; then
    echo "  package lsof is not installed"
  else
    print_error "Hint: List installed groups again or query a package from the group."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You listed, inspected, installed, verified, and removed the \"${GROUP_NAME}\" group (simulated)."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
