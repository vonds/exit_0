#!/bin/bash

# Lab 126: alien, ldd, and the Dynamic Linker (ldconfig, ld.so.conf, ld.so.cache)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 126: Dynamic Linker & alien Basics"
LAB_ID="lab126"
LAB_XP=3350
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
  center_text "A vendor shipped a binary that depends on a custom shared library."
  center_text "You need to validate library dependencies, make /opt/mylib discoverable,"
  center_text "refresh the dynamic linker cache, and sanity-check with ldconfig."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Show the shared libraries required by /bin/ls."
  read -p "  lab@lpic-lab126:~$ " cmd1
  echo
  if [[ "$cmd1" != "ldd /bin/ls" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  linux-vdso.so.1 (0x00007ffd5b3fc000)"
  echo "  libselinux.so.1 => /lib64/libselinux.so.1 (0x00007f3d8c1a0000)"
  echo "  libc.so.6 => /lib64/libc.so.6 (0x00007f3d8bfa0000)"
  echo "  /lib64/ld-linux-x86-64.so.2 (0x00007f3d8c3f0000)"
  echo

  # STEP 2
  echo "  Step 2: List the first 10 entries from the dynamic linker cache."
  read -p "  lab@lpic-lab126:~$ " cmd2
  echo
  if [[ "$cmd2" != "ldconfig -p | head" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  10 libs found in cache (truncated)"
  echo "  libm.so.6 (libc6,x86-64) => /lib64/libm.so.6"
  echo "  libc.so.6 (libc6,x86-64) => /lib64/libc.so.6"
  echo "  libdl.so.2 (libc6,x86-64) => /lib64/libdl.so.2"
  echo "  libpthread.so.0 (libc6,x86-64) => /lib64/libpthread.so.0"
  echo "  librt.so.1 (libc6,x86-64) => /lib64/librt.so.1"
  echo

  # STEP 3
  echo "  Step 3: Show active lines in /etc/ld.so.conf."
  read -p "  lab@lpic-lab126:~$ " cmd3
  echo
  if [[ "$cmd3" != "grep -E '^[^#]' /etc/ld.so.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  include /etc/ld.so.conf.d/*.conf"
  echo

  # STEP 4
  echo "  Step 4: List snippet files in /etc/ld.so.conf.d."
  read -p "  lab@lpic-lab126:~$ " cmd4
  echo
  if [[ "$cmd4" != "ls -1 /etc/ld.so.conf.d" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  kernel-5.14.0.conf"
  echo "  libc.conf"
  echo "  x86_64-linux-gnu.conf"
  echo

  # STEP 5
  echo "  Step 5: Add a custom library path /opt/mylib via a new snippet."
  read -p "  lab@lpic-lab126:~$ " cmd5
  echo
  if [[ "$cmd5" != "echo /opt/mylib | sudo tee /etc/ld.so.conf.d/mylib.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /opt/mylib"
  echo

  # STEP 6
  echo "  Step 6: Update the library cache so the new path is recognized."
  read -p "  lab@lpic-lab126:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo ldconfig" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 7
  echo "  Step 7: Verify that ldconfig now scans /opt/mylib."
  read -p "  lab@lpic-lab126:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo ldconfig -v 2>/dev/null | grep -m1 /opt/mylib" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /opt/mylib:"
  echo

  # STEP 8
  echo "  Step 8: Temporarily prepend /opt/mylib to LD_LIBRARY_PATH for the current shell."
  read -p "  lab@lpic-lab126:~$ " cmd8
  echo
  if [[ "$cmd8" != "export LD_LIBRARY_PATH=/opt/mylib:\$LD_LIBRARY_PATH" ]]; then
    print_error "Incorrect. Use: export LD_LIBRARY_PATH=/opt/mylib:\$LD_LIBRARY_PATH"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  LD_LIBRARY_PATH set for current shell."
  echo

  print_success "Lab complete."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
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
