#!/bin/bash

# Lab 114: GRUB Bootloader Basics (inspect & regenerate configs safely)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 114: GRUB Bootloader Basics"
LAB_ID="lab114"
LAB_XP=18150
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
  tmpfile="$(mktemp)"
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

# Helper to accept either Debian/Ubuntu (update-grub) or RHEL/Fedora (grub2-mkconfig)
is_update_grub()   { [[ "$1" =~ ^(sudo[[:space:]]+)?update-grub$ ]]; }
is_grub2_mkconfig(){ [[ "$1" =~ ^(sudo[[:space:]]+)?grub2-mkconfig[[:space:]]+-o[[:space:]]+/boot/grub2/grub\.cfg$ ]]; }
is_grub_mkconfig() { [[ "$1" =~ ^(sudo[[:space:]]+)?grub-mkconfig[[:space:]]+-o[[:space:]]+/boot/grub/grub\.cfg$ ]]; }

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Inspect GRUB defaults, list menu entries, and safely regenerate grub.cfg."
  center_text "This lab accepts both Debian/Ubuntu and RHEL-family command variants."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Show GRUB defaults
  echo "  Step 1: Print the GRUB defaults file lines (timeout, default, cmdline)."
  read -p "  lab@lpic-lab114:~$ " cmd1
  echo
  if [[ "$cmd1" != "grep -E '^GRUB_' /etc/default/grub" && "$cmd1" != "grep '^GRUB_' /etc/default/grub" ]]; then
    print_error "Incorrect. Try: grep -E '^GRUB_' /etc/default/grub"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  GRUB_DEFAULT=0"
  echo "  GRUB_TIMEOUT=5"
  echo "  GRUB_DISTRIBUTOR=\"GNU/Linux\""
  echo "  GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\""
  echo "  GRUB_CMDLINE_LINUX=\"\""
  echo

  # STEP 2: List GRUB menu entries from grub.cfg (first 5)
  echo "  Step 2: Show the first 5 menu entries from the active grub.cfg."
  read -p "  lab@lpic-lab114:~$ " cmd2
  echo
  if [[ "$cmd2" != "grep '^menuentry' /boot/grub*/grub.cfg | head -n 5" && \
        "$cmd2" != "grep \"^menuentry\" /boot/grub*/grub.cfg | head -n 5" ]]; then
    print_error "Incorrect. Example: grep '^menuentry' /boot/grub*/grub.cfg | head -n 5"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  menuentry 'GNU/Linux, with Linux 6.6.0' --class gnu-linux --class gnu --class os {"
  echo "  menuentry 'GNU/Linux, with Linux 6.6.0 (recovery mode)' --class gnu-linux {"
  echo "  menuentry 'Memory test (memtest86+)' {"
  echo "  menuentry 'Previous Linux versions →' {"
  echo "  menuentry 'UEFI Firmware Settings' {"
  echo

  # STEP 3: List current kernels present in /boot
  echo "  Step 3: List kernel and initramfs images in /boot."
  read -p "  lab@lpic-lab114:~$ " cmd3
  echo
  if [[ "$cmd3" != "ls -1 /boot | grep -E 'vmlinuz|initrd|initramfs'" && \
        "$cmd3" != "ls -1 /boot | grep -E \"vmlinuz|initrd|initramfs\"" ]]; then
    print_error "Incorrect. Example: ls -1 /boot | grep -E 'vmlinuz|initrd|initramfs'"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  vmlinuz-6.6.0"
  echo "  initrd.img-6.6.0"
  echo "  System.map-6.6.0"
  echo "  grub"
  echo

  # STEP 4: Regenerate grub.cfg (accept distro variants)
  echo "  Step 4: Regenerate the GRUB configuration file using your distro's command."
 
  # RHEL/Fedora: "sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
  read -p "  lab@lpic-lab114:~$ " cmd4
  echo
  if is_update_grub "$cmd4"; then
    echo "  Sourcing file \`/etc/default/grub'"
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-6.6.0"
    echo "  Found initrd image: /boot/initrd.img-6.6.0"
    echo "  done"
  elif is_grub2_mkconfig "$cmd4"; then
    echo "  Generating grub configuration file at /boot/grub2/grub.cfg"
    echo "  Found linux image: /boot/vmlinuz-6.6.0"
    echo "  Found initrd image: /boot/initramfs-6.6.0.img"
    echo "  done"
  elif is_grub_mkconfig "$cmd4"; then
    echo "  Generating grub configuration file at /boot/grub/grub.cfg"
    echo "  Found linux image: /boot/vmlinuz-6.6.0"
    echo "  Found initrd image: /boot/initrd.img-6.6.0"
    echo "  done"
  else
    print_error "Incorrect. Use one of: update-grub  |  grub2-mkconfig -o /boot/grub2/grub.cfg  |  grub-mkconfig -o /boot/grub/grub.cfg"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 5: Verify timestamp of regenerated grub.cfg
  echo "  Step 5: Show the grub.cfg path and its modification time."
  read -p "  lab@lpic-lab114:~$ " cmd5
  echo
  if [[ "$cmd5" != "ls -l /boot/grub*/grub.cfg" ]]; then
    print_error "Incorrect. Use: ls -l /boot/grub*/grub.cfg"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -r-------- 1 root root 123456 Aug 19 12:34 /boot/grub/grub.cfg"
  echo "  (or)"
  echo "  -r-------- 1 root root 123456 Aug 19 12:34 /boot/grub2/grub.cfg"
  echo

  # STEP 6: Inspect a key default like GRUB_TIMEOUT or GRUB_DEFAULT
  echo "  Step 6: Show the current GRUB_TIMEOUT value from /etc/default/grub."
  read -p "  lab@lpic-lab114:~$ " cmd6
  echo
  if [[ "$cmd6" != "grep '^GRUB_TIMEOUT=' /etc/default/grub" ]]; then
    print_error "Incorrect. Use: grep '^GRUB_TIMEOUT=' /etc/default/grub"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  GRUB_TIMEOUT=5"
  echo

  # STEP 7: (Safe) Check GRUB installer version (no changes made)
  echo "  Step 7: Print GRUB installer version safely (no device writes)."
  read -p "  lab@lpic-lab114:~$ " cmd7
  echo
  if [[ "$cmd7" != "grub2-install --version" && "$cmd7" != "grub-install --version" && "$cmd7" != "sudo grub2-install --version" && "$cmd7" != "sudo grub-install --version" ]]; then
    print_error "Incorrect. Example: grub2-install --version"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  grub-install (GRUB) 2.06"
  echo

  # STEP 8: Show current default boot target (systemd perspective)
  echo "  Step 8: Show the current default systemd target (runlevel equivalent)."
  read -p "  lab@lpic-lab114:~$ " cmd8
  echo
  if [[ "$cmd8" != "systemctl get-default" && "$cmd8" != "sudo systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  graphical.target"
  echo

  print_success "Excellent!"
  print_info "You inspected GRUB defaults, listed menu entries, regenerated grub.cfg in a distro-appropriate way,"
  print_info "verified the config timestamp, and safely confirmed the GRUB installer version."
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count="$(get_lab_completion_count)"
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
