#!/bin/bash

# Lab 198: tuned — install, enable, list, switch, recommend, off/on (Operate Running Systems)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 198: tuned Profiles"
LAB_ID="lab198"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
  center_text "Goal: Install tuned, enable it, list/switch profiles, use recommended, turn off and back on."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Install tuned (dnf shows output)
  draw_lab_ui
  echo "  Step 1: Install tuned."
  echo "          Expected: dnf install -y tuned"
  read -p "  lab@lab198:~$ " s1
  [[ "$s1" != "dnf install -y tuned" ]] && { print_error "Use: dnf install -y tuned"; read -p "Press Enter to try again..." _; continue; }
  echo "Last metadata expiration check: 0:12:34 ago on $(date +'%a %b %d %Y %H:%M:%S')."
  echo "Dependencies resolved."
  echo "==========================================================================="
  echo " Package         Arch   Version                         Repo           Size"
  echo "==========================================================================="
  echo "Installing:"
  echo " tuned           noarch 2.21.0-1.el9                    baseos         78 k"
  echo ""
  echo "Transaction Summary"
  echo "Install  1 Package"
  echo ""
  echo "Installed:"
  echo "  tuned-2.21.0-1.el9.noarch"
  echo

  # Step 2: Enable and start tuned (systemctl shows symlink lines)
  echo "  Step 2: Enable and start the service."
  echo "          Expected: systemctl enable --now tuned"
  read -p "  lab@lab198:~$ " s2
  [[ "$s2" != "systemctl enable --now tuned" ]] && { print_error "Use: systemctl enable --now tuned"; read -p "Press Enter to try again..." _; continue; }
  echo "Created symlink /etc/systemd/system/multi-user.target.wants/tuned.service → /usr/lib/systemd/system/tuned.service."
  echo

  # Step 3: Verify enabled state (prints 'enabled')
  echo "  Step 3: Verify service is enabled."
  echo "          Expected: systemctl is-enabled tuned"
  read -p "  lab@lab198:~$ " s3
  [[ "$s3" != "systemctl is-enabled tuned" ]] && { print_error "Use: systemctl is-enabled tuned"; read -p "Press Enter to try again..." _; continue; }
  echo "enabled"
  echo

  # Step 4: List available profiles (tuned-adm list)
  echo "  Step 4: List available profiles."
  echo "          Expected: tuned-adm list"
  read -p "  lab@lab198:~$ " s4
  [[ "$s4" != "tuned-adm list" ]] && { print_error "Use: tuned-adm list"; read -p "Press Enter to try again..." _; continue; }
  echo "Available profiles:"
  echo "- balanced"
  echo "- powersave"
  echo "- throughput-performance"
  echo "- latency-performance"
  echo "- network-latency"
  echo "- network-throughput"
  echo "- virtual-guest"
  echo "- virtual-host"
  echo "Current active profile: balanced"
  echo

  # Step 5: Show active profile explicitly
  echo "  Step 5: Show current active profile."
  echo "          Expected: tuned-adm active"
  read -p "  lab@lab198:~$ " s5
  [[ "$s5" != "tuned-adm active" ]] && { print_error "Use: tuned-adm active"; read -p "Press Enter to try again..." _; continue; }
  echo "Current active profile: balanced"
  echo

  # Step 6: Switch to throughput-performance (prints status lines)
  echo "  Step 6: Switch to throughput-performance."
  echo "          Expected: tuned-adm profile throughput-performance"
  read -p "  lab@lab198:~$ " s6
  [[ "$s6" != "tuned-adm profile throughput-performance" ]] && { print_error "Use: tuned-adm profile throughput-performance"; read -p "Press Enter to try again..." _; continue; }
  echo "Applying profile: throughput-performance"
  echo "Profile was applied successfully."
  echo

  # Step 7: Confirm new active profile
  echo "  Step 7: Confirm profile changed."
  echo "          Expected: tuned-adm active"
  read -p "  lab@lab198:~$ " s7
  [[ "$s7" != "tuned-adm active" ]] && { print_error "Use: tuned-adm active"; read -p "Press Enter to try again..." _; continue; }
  echo "Current active profile: throughput-performance"
  echo

  # Step 8: Show recommended profile for this system
  echo "  Step 8: Show recommended profile."
  echo "          Expected: tuned-adm recommend"
  read -p "  lab@lab198:~$ " s8
  [[ "$s8" != "tuned-adm recommend" ]] && { print_error "Use: tuned-adm recommend"; read -p "Press Enter to try again..." _; continue; }
  echo "virtual-guest"
  echo

  # Step 9: Switch to the recommended profile
  echo "  Step 9: Switch to the recommended profile."
  echo "          Expected: tuned-adm profile virtual-guest"
  read -p "  lab@lab198:~$ " s9
  [[ "$s9" != "tuned-adm profile virtual-guest" ]] && { print_error "Use: tuned-adm profile virtual-guest"; read -p "Press Enter to try again..." _; continue; }
  echo "Applying profile: virtual-guest"
  echo "Profile was applied successfully."
  echo

  # Step 10: Turn tuning off (prints deactivation notice)
  echo "  Step 10: Turn tuning off."
  echo "           Expected: tuned-adm off"
  read -p "  lab@lab198:~$ " s10
  [[ "$s10" != "tuned-adm off" ]] && { print_error "Use: tuned-adm off"; read -p "Press Enter to try again..." _; continue; }
  echo "Deactivating current profile."
  echo "All tuning disabled."
  echo

  # Step 11: Reactivate a profile (balanced)
  echo "  Step 11: Reactivate balanced."
  echo "           Expected: tuned-adm profile balanced"
  read -p "  lab@lab198:~$ " s11
  [[ "$s11" != "tuned-adm profile balanced" ]] && { print_error "Use: tuned-adm profile balanced"; read -p "Press Enter to try again..." _; continue; }
  echo "Applying profile: balanced"
  echo "Profile was applied successfully."
  echo

  print_success "Nice work!"
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
