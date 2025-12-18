#!/bin/bash

# Lab 109: Persistent Module Configuration (Blacklisting & Options)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 109: Persistent Module Configuration"
LAB_ID="lab109"
LAB_XP=18140
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
  center_text "Create persistent kernel module settings: blacklist an unwanted module and set"
  center_text "options for a safe practice module. Verify with modprobe/lsmod and rebuild initramfs."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Blacklist pcspkr persistently
  echo "  Step 1: Persistently blacklist the 'pcspkr' module."
  read -p "  lab@lpic-lab109:~$ " cmd1
  echo
  if [[ "$cmd1" != "echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf" && \
        "$cmd1" != "printf 'blacklist pcspkr\n' | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf" && \
        "$cmd1" != "sudo sh -c \"echo blacklist pcspkr > /etc/modprobe.d/blacklist-pcspkr.conf\"" ]]; then
    print_error "Incorrect. Example: echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  blacklist pcspkr"
  echo

  # STEP 2: Verify blacklist is registered
  echo "  Step 2: Verify that 'pcspkr' is now blacklisted."
  read -p "  lab@lpic-lab109:~$ " cmd2
  echo
  if [[ "$cmd2" != "grep -R \"^blacklist pcspkr\" /etc/modprobe.d" && \
        "$cmd2" != "grep -R '^blacklist pcspkr' /etc/modprobe.d" ]]; then
    print_error "Incorrect. Example: grep -R '^blacklist pcspkr' /etc/modprobe.d"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /etc/modprobe.d/blacklist-pcspkr.conf:blacklist pcspkr"
  echo

  # STEP 3: Demonstrate blacklisting effect
  echo "  Step 3: Attempt to load the blacklisted module to see the expected failure."
  read -p "  lab@lpic-lab109:~$ " cmd3
  echo
  if [[ "$cmd3" != "modprobe pcspkr" && "$cmd3" != "sudo modprobe pcspkr" && "$cmd3" != "modprobe -v pcspkr" && "$cmd3" != "sudo modprobe -v pcspkr" ]]; then
    print_error "Incorrect. Use: modprobe pcspkr"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  modprobe: ERROR: Module pcspkr is blacklisted."
  echo

  # STEP 4: Create persistent options for a safe module (loop)
  echo "  Step 4: Create a persistent option for 'loop' (e.g., max_loop=16) under /etc/modprobe.d."
  read -p "  lab@lpic-lab109:~$ " cmd4
  echo
  if [[ "$cmd4" != "echo 'options loop max_loop=16' | sudo tee /etc/modprobe.d/loop.conf" && \
        "$cmd4" != "printf 'options loop max_loop=16\n' | sudo tee /etc/modprobe.d/loop.conf" && \
        "$cmd4" != "sudo sh -c \"echo options loop max_loop=16 > /etc/modprobe.d/loop.conf\"" ]]; then
    print_error "Incorrect. Example: echo 'options loop max_loop=16' | sudo tee /etc/modprobe.d/loop.conf"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  options loop max_loop=16"
  echo

  # STEP 5: Validate option is recognized
  echo "  Step 5: Validate that an option for 'loop' is now registered."
  read -p "  lab@lpic-lab109:~$ " cmd5
  echo
  if [[ "$cmd5" != "modprobe -c | grep -E '^options\\s+loop\\b'" && \
        "$cmd5" != "modprobe -c | grep ^options.*loop" && \
        "$cmd5" != "modinfo -p loop" && \
        "$cmd5" != "sudo modinfo -p loop" ]]; then
    print_error "Incorrect. Example: modprobe -c | grep -E '^options\\s+loop\\b'"
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd5" == "modinfo -p loop" || "$cmd5" == "sudo modinfo -p loop" ]]; then
    echo "  max_loop:int"
    echo "      Maximum number of loop devices (default 8)"
  else
    echo "  options loop max_loop=16"
  fi
  echo

  # STEP 6: Rebuild initramfs so settings persist at early boot (accept common tools)
  echo "  Step 6: Rebuild the initramfs so these settings persist across early boot."
  read -p "  lab@lpic-lab109:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo update-initramfs -u" && \
        "$cmd6" != "update-initramfs -u" && \
        "$cmd6" != "sudo dracut -f" && \
        "$cmd6" != "dracut -f" && \
        "$cmd6" != "sudo mkinitcpio -P" && \
        "$cmd6" != "mkinitcpio -P" ]]; then
    print_error "Incorrect. Examples: update-initramfs -u  |  dracut -f  |  mkinitcpio -P"
    read -p "Press Enter to try again..." _
    continue
  fi
  case "$cmd6" in
    *update-initramfs*) echo "  update-initramfs: Generating /boot/initrd.img-$(uname -r)";;
    *dracut*)          echo "  dracut: Generating '/boot/initramfs-$(uname -r).img'";;
    *mkinitcpio*)      echo "  ==> Building image from preset: 'default'"; echo "  ==> Generating initramfs for $(uname -r)";;
  esac
  echo

  # STEP 7: (Bonus) Confirm pcspkr isn't loaded; ensure loop can be loaded with options
  echo "  Step 7: Confirm 'pcspkr' is not loaded and (optionally) load 'loop'."
  read -p "  lab@lpic-lab109:~$ " cmd7a
  echo
  if [[ "$cmd7a" != "lsmod | grep pcspkr" && "$cmd7a" != "grep pcspkr /proc/modules" ]]; then
    print_error "Incorrect. Example: lsmod | grep pcspkr"
    read -p "Press Enter to try again..." _
    continue
  fi

  read -p "  lab@lpic-lab109:~$ " cmd7b
  echo
  if [[ "$cmd7b" != "modprobe loop" && "$cmd7b" != "sudo modprobe loop" ]]; then
    print_error "Incorrect. Use: modprobe loop"
    read -p "Press Enter to try again..." _
    continue
  fi

  read -p "  lab@lpic-lab109:~$ " cmd7c
  echo
  if [[ "$cmd7c" != "lsmod | grep -E '^loop(\\s|$)'" && "$cmd7c" != "lsmod | grep ^loop" && "$cmd7c" != "lsmod | grep loop" ]]; then
    print_error "Incorrect. Example: lsmod | grep ^loop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  loop                   45056  0"
  echo

  print_success "Excellent!"
  print_info "You created persistent kernel module settings: blacklisted 'pcspkr', added an option for 'loop',"
  print_info "verified both with modprobe/lsmod, and rebuilt the initramfs to persist through early boot."
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
