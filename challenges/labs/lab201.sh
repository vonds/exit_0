#!/bin/bash

# Lab 201: tuned installation, activation, profile switching (Operate Running Systems)
# Output policy: Show real command outputs only. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 201: tuned profiles"
LAB_ID="lab201"
LAB_XP=22000
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
  center_text "Goal: Install tuned, list profiles, switch to one, and restore recommended profile."
  echo
  center_text "Press Enter to begin..."
  read _

  # === Install tuned ===
  draw_lab_ui
  echo "  Step 1: Install tuned (dnf)."
  echo "          Expected: dnf install -y tuned"
  read -p "  lab@lab201:~$ " s1
  [[ "$s1" != "dnf install -y tuned" ]] && { print_error "Use: dnf install -y tuned"; read -p "Press Enter to try again..." _; continue; }
  echo "Installed: tuned-2.19.0-1.el9.x86_64"
  echo

  echo "  Step 2: Enable and start tuned (silent)."
  echo "          Expected: systemctl enable --now tuned"
  read -p "  lab@lab201:~$ " s2
  [[ "$s2" != "systemctl enable --now tuned" ]] && { print_error "Use: systemctl enable --now tuned"; read -p "Press Enter to try again..." _; continue; }
  echo

  # === Profile listing ===
  echo "  Step 3: List tuned profiles."
  echo "          Expected: tuned-adm list"
  read -p "  lab@lab201:~$ " s3
  [[ "$s3" != "tuned-adm list" ]] && { print_error "Use: tuned-adm list"; read -p "Press Enter to try again..." _; continue; }
  echo "Available profiles:"
  echo "- balanced               - General non-specialized tuned profile"
  echo "- powersave              - Optimize for low power consumption"
  echo "- throughput-performance - Optimize for throughput performance"
  echo "- latency-performance    - Optimize for deterministic performance at the cost of increased power consumption"
  echo "- network-latency        - Optimize for deterministic performance of network latency"
  echo "- network-throughput     - Optimize for streaming network throughput"
  echo "- virtual-guest          - Optimize for running inside a virtual guest"
  echo "- virtual-host           - Optimize for running KVM guests"
  echo "Current active profile: balanced"
  echo

  # === Profile switching ===
  echo "  Step 4: Switch to throughput-performance."
  echo "          Expected: tuned-adm profile throughput-performance"
  read -p "  lab@lab201:~$ " s4
  [[ "$s4" != "tuned-adm profile throughput-performance" ]] && { print_error "Use: tuned-adm profile throughput-performance"; read -p "Press Enter to try again..." _; continue; }
  echo

  echo "  Step 5: Show active profile."
  echo "          Expected: tuned-adm active"
  read -p "  lab@lab201:~$ " s5
  [[ "$s5" != "tuned-adm active" ]] && { print_error "Use: tuned-adm active"; read -p "Press Enter to try again..." _; continue; }
  echo "Current active profile: throughput-performance"
  echo

  # === Recommended profile ===
  echo "  Step 6: Determine recommended profile."
  echo "          Expected: tuned-adm recommend"
  read -p "  lab@lab201:~$ " s6
  [[ "$s6" != "tuned-adm recommend" ]] && { print_error "Use: tuned-adm recommend"; read -p "Press Enter to try again..." _; continue; }
  echo "balanced"
  echo

  echo "  Step 7: Switch back to recommended profile."
  echo "          Expected: tuned-adm profile balanced"
  read -p "  lab@lab201:~$ " s7
  [[ "$s7" != "tuned-adm profile balanced" ]] && { print_error "Use: tuned-adm profile balanced"; read -p "Press Enter to try again..." _; continue; }
  echo

  echo "  Step 8: Confirm active profile again."
  echo "          Expected: tuned-adm active"
  read -p "  lab@lab201:~$ " s8
  [[ "$s8" != "tuned-adm active" ]] && { print_error "Use: tuned-adm active"; read -p "Press Enter to try again..." _; continue; }
  echo "Current active profile: balanced"
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
