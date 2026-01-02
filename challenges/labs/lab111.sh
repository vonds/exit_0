#!/bin/bash

# Lab 111: Explore /proc (CPU & Memory) with Cross-Checks

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 111: /proc CPU & Memory Exploration"
LAB_ID="lab111"
LAB_XP=8020
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
  center_text "Read CPU & memory facts from /proc and verify them with lscpu and free."
  center_text "Extract model name and logical CPU count."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: CPU model name from /proc/cpuinfo
  echo "  Step 1: Print the CPU model name from /proc/cpuinfo (first occurrence)."
  read -p "  lab@lpic-lab111:~$ " cmd1
  echo
  if [[ "$cmd1" != "grep -m1 '^model name' /proc/cpuinfo" && \
        "$cmd1" != "grep -m 1 '^model name' /proc/cpuinfo" && \
        "$cmd1" != "cat /proc/cpuinfo | grep -m1 '^model name'" && \
        "$cmd1" != "awk -F: '/^model name/{print; exit}' /proc/cpuinfo" ]]; then
    print_error "Incorrect. Example: grep -m1 '^model name' /proc/cpuinfo"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  model name  : Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz"
  echo

  # STEP 2: Logical processor count from /proc/cpuinfo
  echo "  Step 2: Count logical processors using /proc/cpuinfo."
  read -p "  lab@lpic-lab111:~$ " cmd2
  echo
  if [[ "$cmd2" != "grep -c '^processor' /proc/cpuinfo" && \
        "$cmd2" != "cat /proc/cpuinfo | grep -c '^processor'" ]]; then
    print_error "Incorrect. Use: grep -c '^processor' /proc/cpuinfo"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  8"
  echo

  # STEP 3: Cross-check CPU facts with lscpu
  echo "  Step 3: Cross-check CPU summary using the standard utility."
  read -p "  lab@lpic-lab111:~$ " cmd3
  echo
  if [[ "$cmd3" != "lscpu" && "$cmd3" != "sudo lscpu" ]]; then
    print_error "Incorrect. Use: lscpu"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Architecture:            x86_64"
  echo "  CPU(s):                  8"
  echo "  Thread(s) per core:      2"
  echo "  Core(s) per socket:      4"
  echo "  Model name:              Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz"
  echo

  # STEP 4: Extract MemTotal and MemAvailable from /proc/meminfo
  echo "  Step 4: Show MemTotal and MemAvailable from /proc/meminfo."
  read -p "  lab@lpic-lab111:~$ " cmd4
  echo
  if [[ "$cmd4" != "egrep '^(MemTotal|MemAvailable)' /proc/meminfo" && \
        "$cmd4" != "grep -E '^(MemTotal|MemAvailable)' /proc/meminfo" ]]; then
    print_error "Incorrect. Example: grep -E '^(MemTotal|MemAvailable)' /proc/meminfo"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  MemTotal:       16270568 kB"
  echo "  MemAvailable:   12450832 kB"
  echo

  # STEP 5: Cross-check memory with free -h
  echo "  Step 5: Cross-check memory values using a human-readable summary."
  read -p "  lab@lpic-lab111:~$ " cmd5
  echo
  if [[ "$cmd5" != "free -h" && "$cmd5" != "sudo free -h" ]]; then
    print_error "Incorrect. Use: free -h"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "                total        used        free      shared  buff/cache   available"
  echo "  Mem:            15Gi       2.5Gi       1.1Gi       210Mi        12Gi         11Gi"
  echo "  Swap:            2.0Gi        0B        2.0Gi"
  echo


  # STEP 6: Bonus — show hugepages summary if present
  echo "  Step 6: Show hugepage settings if supported."
  read -p "  lab@lpic-lab111:~$ " cmd6
  echo
  if [[ "$cmd6" != "grep Huge /proc/meminfo" && "$cmd6" != "grep -E '^Huge' /proc/meminfo" ]]; then
    print_error "Incorrect. Example: grep Huge /proc/meminfo"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  HugePages_Total:       0"
  echo "  HugePages_Free:        0"
  echo "  Hugepagesize:       2048 kB"
  echo

  print_success "Great work!"
  print_info "You extracted CPU model & logical count from /proc, verified with lscpu,"
  print_info "read MemTotal/Available from /proc/meminfo, cross-checked with free -h,"
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
