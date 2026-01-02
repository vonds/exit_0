#!/bin/bash

# Lab 115: Systemd Targets & Runlevels (default target, isolate, verification)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 115: Systemd Targets & Runlevels"
LAB_ID="lab115"
LAB_XP=18120
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
  center_text "Check the default systemd target, switch (isolate) between targets safely,"
  center_text "and verify the default via the /etc/systemd/system/default.target symlink."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Show current default target
  echo "  Step 1: Show the current default systemd target."
  read -p "  lab@lpic-lab115:~$ " cmd1
  echo
  if [[ "$cmd1" != "systemctl get-default" && "$cmd1" != "sudo systemctl get-default" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  graphical.target"
  echo

  # STEP 2: List active targets (overview)
  echo "  Step 2: List currently active targets (show first ~10 lines)."
  read -p "  lab@lpic-lab115:~$ " cmd2
  echo
  if [[ "$cmd2" != "systemctl list-units --type=target --state=active | head -n 10" && \
        "$cmd2" != "systemctl list-units --type=target --state=active | head -10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  UNIT                  LOAD   ACTIVE SUB    DESCRIPTION"
  echo "  basic.target          loaded active active Basic System"
  echo "  sockets.target        loaded active active Sockets"
  echo "  multi-user.target     loaded active active Multi-User System"
  echo "  graphical.target      loaded active active Graphical Interface"
  echo "  timers.target         loaded active active Timers"
  echo

  # STEP 3: Temporarily switch (isolate) to multi-user (no reboot)
  echo "  Step 3: Switch to multi-user mode WITHOUT changing the default target."
  read -p "  lab@lpic-lab115:~$ " cmd3
  echo
  if [[ "$cmd3" != "systemctl isolate multi-user.target" && "$cmd3" != "sudo systemctl isolate multi-user.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (switched to multi-user.target; graphical sessions would stop if present)"
  echo

  # STEP 4: Verify active target includes multi-user
  echo "  Step 4: Verify multi-user.target is active."
  read -p "  lab@lpic-lab115:~$ " cmd4
  echo
  if [[ "$cmd4" != "systemctl list-units --type=target | grep multi-user.target" && \
        "$cmd4" != "systemctl list-units --type=target --state=active | grep multi-user.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  multi-user.target     loaded active active Multi-User System"
  echo

  # STEP 5: Make multi-user the default (persistent)
  echo "  Step 5: Set the default target to multi-user (persistent across reboots)."
  read -p "  lab@lpic-lab115:~$ " cmd5
  echo
  if [[ "$cmd5" != "systemctl set-default multi-user.target" && "$cmd5" != "sudo systemctl set-default multi-user.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/default.target → /lib/systemd/system/multi-user.target"
  echo

  # STEP 6: Inspect the default.target symlink
  echo "  Step 6: Show the default.target symlink path and destination."
  read -p "  lab@lpic-lab115:~$ " cmd6
  echo
  if [[ "$cmd6" != "ls -l /etc/systemd/system/default.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  lrwxrwxrwx 1 root root 46 Aug 19 12:40 /etc/systemd/system/default.target -> /lib/systemd/system/multi-user.target"
  echo

  # STEP 7: Restore graphical target as the default
  echo "  Step 7: Restore the default target back to graphical."
  read -p "  lab@lpic-lab115:~$ " cmd7
  echo
  if [[ "$cmd7" != "systemctl set-default graphical.target" && "$cmd7" != "sudo systemctl set-default graphical.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Removed symlink /etc/systemd/system/default.target."
  echo "  Created symlink /etc/systemd/system/default.target → /lib/systemd/system/graphical.target"
  echo

  # STEP 8: Verify the symlink now points to graphical.target
  echo "  Step 8: Confirm the new symlink destination."
  read -p "  lab@lpic-lab115:~$ " cmd8
  echo
  if [[ "$cmd8" != "ls -l /etc/systemd/system/default.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  lrwxrwxrwx 1 root root 45 Aug 19 12:42 /etc/systemd/system/default.target -> /lib/systemd/system/graphical.target"
  echo

  # STEP 9:Temporarily switch back to graphical now
  echo "  Step 9: Switch the *current* session back to graphical immediately."
  read -p "  lab@lpic-lab115:~$ " cmd9
  echo
  if [[ "$cmd9" != "systemctl isolate graphical.target" && "$cmd9" != "sudo systemctl isolate graphical.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (switched to graphical.target)"
  echo

  # STEP 10: Show runlevel-style view (mapping to targets)
  echo "  Step 10: Show the current runlevel-style status."
  read -p "  lab@lpic-lab115:~$ " cmd10
  echo
  if [[ "$cmd10" != "who -r" && "$cmd10" != "runlevel" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd10" == "who -r" ]]; then
    echo "   run-level 5  2025-08-19 12:43                   last=3"
  else
    echo "  N 5"
  fi
  echo

  print_success "Excellent!"
  print_info "You inspected the default target, listed active targets, isolated to multi-user,"
  print_info "changed and verified the persistent default via the default.target symlink,"
  print_info "returned to graphical, and viewed the runlevel mapping."
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

  [[ "$choice" == "2" ]] && exit 0
done
