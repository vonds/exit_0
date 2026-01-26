#!/bin/bash

# Lab 492: Manage Tuning Profiles (tuned / tuned-adm)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 492: Manage Tuning Profiles (tuned)"
LAB_ID="lab492"
LAB_XP=49200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab492:~$ "

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
  center_text "A server is being repurposed for a high-throughput workload."
  center_text "You must confirm tuned is running, switch to a throughput profile,"
  center_text "create a custom profile, and then disable tuning for troubleshooting."
  echo
  center_text "Policy:"
  center_text "- Use tuned-adm to manage profiles."
  center_text "- Custom profiles must live in /etc/tuned/."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Check tuned service status
  echo "  Step 1: Verify the tuned service is running."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo systemctl status tuned" && "$cmd1" != "systemctl status tuned" ]]; then
    print_error "Incorrect. Use: sudo systemctl status tuned"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "● tuned.service - Dynamic System Tuning Daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/tuned.service; enabled; preset: enabled)"
  echo "     Active: active (running) since Sun 2026-01-25 21:18:07 EST; 7min ago"
  echo "       Docs: man:tuned(8)"
  echo "             man:tuned.conf(5)"
  echo "   Main PID: 1186 (tuned)"
  echo "      Tasks: 3 (limit: 11234)"
  echo "     Memory: 15.9M"
  echo "        CPU: 412ms"
  echo "     CGroup: /system.slice/tuned.service"
  echo "             └─1186 /usr/bin/python3 -Es /usr/sbin/tuned -l -P"
  echo

  # STEP 2: List profiles
  echo "  Step 2: List available tuned profiles."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo tuned-adm list" && "$cmd2" != "tuned-adm list" ]]; then
    print_error "Incorrect. Use: sudo tuned-adm list"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Available profiles:"
  echo "- balanced                        - General non-specialized tuned profile"
  echo "- powersave                       - Optimize for low power consumption"
  echo "- throughput-performance          - Broadly applicable tuning for high throughput"
  echo "- latency-performance             - Optimize for deterministic performance at the cost of power"
  echo "- network-throughput              - Optimize for high network throughput"
  echo "- virtual-guest                   - Optimize for running inside a virtual guest"
  echo "- virtual-host                    - Optimize for running KVM guests"
  echo "Current active profile: balanced"
  echo

  # STEP 3: Switch to throughput-performance
  echo "  Step 3: Switch the active profile to throughput-performance."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo tuned-adm profile throughput-performance" && \
        "$cmd3" != "tuned-adm profile throughput-performance" ]]; then
    print_error "Incorrect. Use: sudo tuned-adm profile throughput-performance"
    read -p "Press Enter to try again..." _
    continue
  fi


  # STEP 4: Verify active profile
  echo "  Step 4: Verify the active profile."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo tuned-adm active" && "$cmd4" != "tuned-adm active" ]]; then
    print_error "Incorrect. Use: sudo tuned-adm active"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Current active profile: throughput-performance"
  echo

  # STEP 5: Create custom profile directory
  echo "  Step 5: Create a custom tuned profile directory: /etc/tuned/my-custom-profile"
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo mkdir -p /etc/tuned/my-custom-profile" && \
        "$cmd5" != "mkdir -p /etc/tuned/my-custom-profile" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /etc/tuned/my-custom-profile"
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 6: Edit tuned.conf (user chooses editor)
  echo "  Step 6: Create /etc/tuned/my-custom-profile/tuned.conf"
  echo "          Include throughput-performance and set cpu governor to performance."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo vim /etc/tuned/my-custom-profile/tuned.conf" && \
        "$cmd6" != "sudo nano /etc/tuned/my-custom-profile/tuned.conf" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/tuned/my-custom-profile/tuned.conf (or nano)"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (created file with the following content)"
  echo "  [main]"
  echo "  include=throughput-performance"
  echo
  echo "  [cpu]"
  echo "  governor=performance"
  echo

  # STEP 7: Activate custom profile
  echo "  Step 7: Activate the custom profile."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo tuned-adm profile my-custom-profile" && \
        "$cmd7" != "tuned-adm profile my-custom-profile" ]]; then
    print_error "Incorrect. Use: sudo tuned-adm profile my-custom-profile"
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 8: Verify active profile is custom
  echo "  Step 8: Verify the active profile is now my-custom-profile."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "tuned-adm active" && "$cmd8" != "sudo tuned-adm active" ]]; then
    print_error "Incorrect. Use: tuned-adm active"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Current active profile: my-custom-profile"
  echo

  # STEP 9: Turn tuning off (troubleshooting)
  echo "  Step 9: Temporarily disable tuning (turn tuned profiles off)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo tuned-adm off" && "$cmd9" != "tuned-adm off" ]]; then
    print_error "Incorrect. Use: sudo tuned-adm off"
    read -p "Press Enter to try again..." _
    continue
  fi


  # STEP 10: Confirm off state
  echo "  Step 10: Confirm tuning is disabled."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "tuned-adm active" && "$cmd10" != "sudo tuned-adm active" ]]; then
    print_error "Incorrect. Use: tuned-adm active"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "No current active profile."
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified tuned is running"
  print_info "- listed available profiles"
  print_info "- switched profiles and verified active state"
  print_info "- created and activated a custom profile in /etc/tuned/"
  print_info "- disabled tuning for troubleshooting"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP LEVEL
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
