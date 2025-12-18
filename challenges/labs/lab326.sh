#!/bin/bash

# Lab 326: Laptop Memory (SO-DIMM) Installation and Upgrade
# Focus: CompTIA A+ Domain 1.1 – Install, upgrade, and configure laptop components (Memory Modules)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 326: Laptop Memory (SO-DIMM) Installation and Upgrade"
LAB_ID="lab326"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo; echo; echo
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario: You are upgrading a laptop’s memory modules (SO-DIMM)."
  center_text "Objective: Safely remove, install, and verify new RAM."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1
  draw_lab_ui
  echo "  Step 1: Before opening the chassis, what should you check to confirm upgrade compatibility?"
  read -p "  lab@a-plus-lab326:~$ " cmd1
  echo
  if [[ "$cmd1" != "Check the laptop manual" && "$cmd1" != "Check system manual" && "$cmd1" != "Check manufacturer specifications" && "$cmd1" != "Check the manufacturer specifications" ]]; then
    print_error "Incorrect. Always check the laptop’s manual or manufacturer specs to verify upgradeability and supported RAM."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Verify upgradeability in the laptop manual/manufacturer specs."
  echo

  # Step 2
  echo "  Step 2: What memory form factor is typically used in laptops?"
  read -p "  lab@a-plus-lab326:~$ " cmd2
  echo
  if [[ "$cmd2" != "SO-DIMM" && "$cmd2" != "Small Outline DIMM" && "$cmd2" != "Small Outline Dual In-Line Memory Module" ]]; then
    print_error "Incorrect. Laptops use SO-DIMM (Small Outline Dual In-Line Memory Module)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: SO-DIMM is the laptop form factor."
  echo

  # Step 3
  echo "  Step 3: What should you do before handling memory modules to prevent component damage?"
  read -p "  lab@a-plus-lab326:~$ " cmd3
  echo
  if [[ "$cmd3" != "Wear an ESD wrist strap" && "$cmd3" != "Use ESD protection" && "$cmd3" != "Discharge static electricity" && "$cmd3" != "Use an antistatic mat" ]]; then
    print_error "Incorrect. Wear an ESD wrist strap and work on an antistatic mat to prevent electrostatic discharge."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Use ESD protection."
  echo

  # Step 4
  echo "  Step 4: At what angle should SO-DIMM modules be inserted or removed?"
  read -p "  lab@a-plus-lab326:~$ " cmd4
  echo
  if [[ "$cmd4" != "45 degrees" && "$cmd4" != "45-degree angle" && "$cmd4" != "45°" ]]; then
    print_error "Incorrect. SO-DIMMs insert/remove at about a 45-degree angle, then press flat to latch."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: ~45-degree angle."
  echo

  # Step 5
  echo "  Step 5: What do the notches on a memory module ensure?"
  read -p "  lab@a-plus-lab326:~$ " cmd5
  echo
  if [[ "$cmd5" != "Proper orientation" && "$cmd5" != "Prevent incorrect installation" && "$cmd5" != "Ensure correct alignment" ]]; then
    print_error "Incorrect. The notch enforces correct orientation and prevents backward installation."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Notches ensure correct alignment/orientation."
  echo

  # Step 6
  echo "  Step 6: What configuration lets two memory modules work together for higher bandwidth?"
  read -p "  lab@a-plus-lab326:~$ " cmd6
  echo
  if [[ "$cmd6" != "Dual channel" && "$cmd6" != "Dual-channel mode" && "$cmd6" != "Dual channel mode" ]]; then
    print_error "Incorrect. Dual-channel mode increases memory throughput when using matched modules."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Dual-channel mode."
  echo

  # Step 7
  echo "  Step 7: Why should you install matched pairs of memory modules?"
  read -p "  lab@a-plus-lab326:~$ " cmd7
  echo
  if [[ "$cmd7" != "To ensure dual-channel compatibility" && "$cmd7" != "To ensure same speed and manufacturer" && "$cmd7" != "For dual-channel performance" && "$cmd7" != "Matched pairs enable dual-channel performance" ]]; then
    print_error "Incorrect. Matched pairs (same capacity/speed/specs) help ensure dual-channel compatibility and stability."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Matched pairs maximize dual-channel stability/performance."
  echo

  # Step 8
  echo "  Step 8: How do you release a SO-DIMM from its slot?"
  read -p "  lab@a-plus-lab326:~$ " cmd8
  echo
  if [[ "$cmd8" != "Push the side clips outward" && "$cmd8" != "Press the retaining clips outward" && "$cmd8" != "Release the side clips" ]]; then
    print_error "Incorrect. Gently press the side retaining clips outward; the module pops up to ~45°."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Release the side clips; the module pops up."
  echo

  # Step 9
  echo "  Step 9: After installing RAM, where should you verify the total memory recognized?"
  read -p "  lab@a-plus-lab326:~$ " cmd9
  echo
  if [[ "$cmd9" != "BIOS" && "$cmd9" != "UEFI" && "$cmd9" != "Operating system" && "$cmd9" != "System Information" && "$cmd9" != "BIOS/UEFI" ]]; then
    print_error "Incorrect. Verify in BIOS/UEFI and within the operating system (e.g., System Information)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Verify in BIOS/UEFI and the OS."
  echo

  # Step 10
  echo "  Step 10: If the laptop shipped with 2×8 GB and you want 32 GB total, what should you do?"
  read -p "  lab@a-plus-lab326:~$ " cmd10
  echo
  if [[ "$cmd10" != "Replace both with 2x16 GB" && "$cmd10" != "Install two 16 GB SO-DIMMs" && "$cmd10" != "Replace both modules with 16 GB each" ]]; then
    print_error "Incorrect. Replace both 8 GB modules with two 16 GB SO-DIMMs for 32 GB (if supported)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Correct: Replace both 8 GB modules with 2×16 GB (if the platform supports it)."
  echo

  print_success "Lab complete."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp "$LAB_XP"
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
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
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
