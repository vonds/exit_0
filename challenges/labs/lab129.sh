#!/bin/bash

# Lab 129: Networking Troubleshooting — Fix "Intermittent Connectivity" (Bad MTU)
# Focus: diagnose and fix packet loss caused by an incorrect MTU setting.
# Key skills: ip link, ping with DF flag, MTU adjustment, verification workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 129: Fix Intermittent Connectivity (MTU)"
LAB_ID="lab129"
LAB_XP=12900
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
  center_text "Users report that connections work sometimes but fail on larger transfers."
  center_text "Small pings succeed, but some traffic hangs or drops."
  center_text "You suspect a misconfigured MTU."
  echo
  center_text "Notes:"
  center_text "- Interface is eth0"
  center_text "- Correct MTU should be 1500"
  center_text "- Use sudo where required."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Check the current MTU on eth0."
  read -r -p "  lab@net-ops-129:~$ " cmd1
  echo
  if [[ "$cmd1" != "ip link show eth0" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1200 qdisc fq_codel state UP mode DEFAULT group default qlen 1000"
  echo

  # STEP 2
  echo "  Step 2: Test a large ping with DF set (should fail)."
  read -r -p "  lab@net-ops-129:~$ " cmd2
  echo
  if [[ "$cmd2" != "ping -c 1 -M do -s 1400 1.1.1.1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  ping: local error: message too long, mtu=1200"
  echo

  # STEP 3
  echo "  Step 3: Fix the MTU on eth0."
  read -r -p "  lab@net-ops-129:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo ip link set dev eth0 mtu 1500" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 4
  echo "  Step 4: Confirm the MTU is now correct."
  read -r -p "  lab@net-ops-129:~$ " cmd4
  echo
  if [[ "$cmd4" != "ip link show eth0" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000"
  echo

  # STEP 5
  echo "  Step 5: Re-test the large ping."
  read -r -p "  lab@net-ops-129:~$ " cmd5
  echo
  if [[ "$cmd5" != "ping -c 1 -M do -s 1400 1.1.1.1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=13.1 ms"
  echo

  # STEP 6
  echo "  Step 6: Final sanity check with a normal ping."
  read -r -p "  lab@net-ops-129:~$ " cmd6
  echo
  if [[ "$cmd6" != "ping -c 1 1.1.1.1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=12.6 ms"
  echo

  print_success "Nice work."
  print_info "You diagnosed intermittent connectivity caused by an incorrect MTU."
  print_info "You verified the failure, corrected the MTU, and confirmed stability."
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
  read -r -p "  > " post_choice

  [[ "$post_choice" == "2" ]] && exit 0
done
