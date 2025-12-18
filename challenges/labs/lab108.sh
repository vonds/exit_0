#!/bin/bash

# Lab 108: Kernel Module Fundamentals (lsmod, modprobe, modinfo)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 108: Kernel Module Fundamentals"
LAB_ID="lab108"
LAB_XP=17980
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
  center_text "List loaded kernel modules, inspect a module's metadata, load/unload a safe module,"
  center_text "and verify it with lsmod. We'll use the 'loop' module for safe practice."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: List loaded modules
  echo "  Step 1: Show the first 10 lines of loaded kernel modules."
  read -p "  lab@lpic-lab108:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsmod | head -n 10" && "$cmd1" != "lsmod | head -10" && "$cmd1" != "lsmod | head" && "$cmd1" != "lsmod" ]]; then
    print_error "Incorrect. Try: lsmod | head -n 10"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Module                  Size  Used by"
  echo "  xfs                   999424  1"
  echo "  snd_hda_intel         491520  3"
  echo "  e1000                 155648  0"
  echo "  i915                 2662400  2"
  echo "  intel_rapl_msr         16384  0"
  echo "  intel_rapl_common      24576  1 intel_rapl_msr"
  echo "  drm_kms_helper        311296  1 i915"
  echo "  cec                    61440  1 drm_kms_helper"
  echo "  rc_core                61440  1 cec"
  echo

  # STEP 2: Inspect module metadata with modinfo
  echo "  Step 2: Display metadata for the 'loop' module."
  read -p "  lab@lpic-lab108:~$ " cmd2
  echo
  if [[ "$cmd2" != "modinfo loop" && "$cmd2" != "sudo modinfo loop" ]]; then
    print_error "Incorrect. Use: modinfo loop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  filename:       /lib/modules/$(uname -r)/kernel/drivers/block/loop.ko"
  echo "  description:    Loopback block device"
  echo "  author:         Linux Kernel Team"
  echo "  license:        GPL"
  echo "  parm:           max_loop:int"
  echo "  alias:          block-major-7-*"
  echo

  # STEP 3: Load the loop module
  echo "  Step 3: Load the 'loop' module into the kernel."
  read -p "  lab@lpic-lab108:~$ " cmd3
  echo
  if [[ "$cmd3" != "modprobe loop" && "$cmd3" != "sudo modprobe loop" ]]; then
    print_error "Incorrect. Use: modprobe loop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Loaded module: loop"
  echo

  # STEP 4: Verify the module is loaded
  echo "  Step 4: Confirm that 'loop' appears in the list of loaded modules."
  read -p "  lab@lpic-lab108:~$ " cmd4
  echo
  if [[ "$cmd4" != "lsmod | grep -E '^loop(\\s|$)'" && "$cmd4" != "lsmod | grep ^loop" && "$cmd4" != "lsmod | grep loop" && "$cmd4" != "grep loop /proc/modules" ]]; then
    print_error "Incorrect. Example: lsmod | grep ^loop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  loop                   45056  0"
  echo

  # STEP 5: Load the module with a parameter (demonstration)
  echo "  Step 5: Reload or ensure 'loop' with a parameter setting."
  read -p "  lab@lpic-lab108:~$ " cmd5
  echo
  if [[ "$cmd5" != "modprobe loop max_loop=8" && "$cmd5" != "sudo modprobe loop max_loop=8" ]]; then
    print_error "Incorrect. Try: modprobe loop max_loop=8"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Applied parameter: max_loop=8 (effective on load-capable environments)"
  echo

  # STEP 6: Safely remove the module
  echo "  Step 6: Remove the 'loop' module from the kernel."
  read -p "  lab@lpic-lab108:~$ " cmd6
  echo
  if [[ "$cmd6" != "modprobe -r loop" && "$cmd6" != "sudo modprobe -r loop" && "$cmd6" != "rmmod loop" && "$cmd6" != "sudo rmmod loop" ]]; then
    print_error "Incorrect. Use: modprobe -r loop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Removed module: loop"
  echo

  print_success "Great job!"
  print_info "You listed loaded modules, inspected metadata with modinfo, loaded a safe module,"
  print_info "verified it with lsmod, applied a parameter, and removed it cleanly."
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
