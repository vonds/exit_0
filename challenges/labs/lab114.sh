#!/bin/bash

# Lab 114: RHEL Bootloader Basics — Inspect and regenerate GRUB safely
# RHCSA focus: inspecting GRUB defaults, understanding menu entries,
# identifying installed kernels, regenerating grub.cfg safely,
# and verifying boot-related configuration without risking the system.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 114: RHEL GRUB Bootloader Basics"
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
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

PROMPT="student@lab114:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL system fails to boot as expected. Before making changes,"
  center_text "you must inspect GRUB configuration and safely regenerate grub.cfg."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Inspect GRUB default settings."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "grep '^GRUB_' /etc/default/grub" ]]; then
    print_error "Incorrect. Use: grep '^GRUB_' /etc/default/grub"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  GRUB_TIMEOUT=5"
  echo "  GRUB_DEFAULT=saved"
  echo "  GRUB_CMDLINE_LINUX=\"crashkernel=auto resume=/dev/mapper/rhel-swap\""

  # STEP 2
  echo
  echo "  Step 2: List available GRUB menu entries."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "grep '^menuentry' /boot/grub2/grub.cfg | head" ]]; then
    print_error "Incorrect. Use: grep '^menuentry' /boot/grub2/grub.cfg | head"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  menuentry 'Red Hat Enterprise Linux (5.14.0-427.el9.x86_64)' {"
  echo "  menuentry 'Red Hat Enterprise Linux (rescue)' {"

  # STEP 3
  echo
  echo "  Step 3: Identify installed kernel and initramfs images."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "ls -1 /boot | grep -E 'vmlinuz|initramfs'" ]]; then
    print_error "Incorrect. Use: ls -1 /boot | grep -E 'vmlinuz|initramfs'"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  vmlinuz-5.14.0-427.el9.x86_64"
  echo "  initramfs-5.14.0-427.el9.x86_64.img"

  # STEP 4
  echo
  echo "  Step 4: Safely regenerate GRUB configuration."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "sudo grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
    print_error "Incorrect. Use: sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  Generating grub configuration file ..."
  echo "  Found linux image: /boot/vmlinuz-5.14.0-427.el9.x86_64"
  echo "  Found initrd image: /boot/initramfs-5.14.0-427.el9.x86_64.img"
  echo "  done"

  # STEP 5
  echo
  echo "  Step 5: Verify the grub.cfg timestamp."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "ls -l /boot/grub2/grub.cfg" ]]; then
    print_error "Incorrect. Use: ls -l /boot/grub2/grub.cfg"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  -rw-------. 1 root root 41287 Aug 20 14:32 /boot/grub2/grub.cfg"

  # STEP 6
  echo
  echo "  Step 6: Confirm systemd default target."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  graphical.target"

  # STEP 7
  echo
  echo "  Step 7: Check GRUB installer version (no writes performed)."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "grub2-install --version" ]]; then
    print_error "Incorrect. Use: grub2-install --version"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  grub-install (GRUB) 2.06"

  print_success "Excellent work!"
  print_info "You safely inspected GRUB defaults, verified kernel entries,"
  print_info "regenerated grub.cfg correctly, and confirmed boot configuration."
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP LEVEL
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
