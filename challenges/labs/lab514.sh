#!/bin/bash

# Lab 514: Rocky Linux 10 — Modify the System Bootloader (GRUB2 / RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 514: Modify the System Bootloader (Rocky 10 / RHCSA)"
LAB_ID="lab514"
LAB_XP=51400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab514:~$ "

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
  center_text "You must modify GRUB2 boot behavior on a Rocky Linux 10 system."
  center_text "You will inspect available boot entries, set a new default kernel,"
  center_text "add a persistent kernel argument, rebuild GRUB2 config, and verify."
  echo
  center_text "Targets:"
  center_text "- List available boot entries (no awk)"
  center_text "- Set default kernel by index"
  center_text "- Add a persistent kernel argument (audit=1)"
  center_text "- Regenerate grub.cfg"
  center_text "- Verify changes"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: verify current default target kernel
  echo "  Step 1: Show the current default kernel."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "grubby --default-kernel" ]]; then
    print_error "Incorrect. Use: grubby --default-kernel"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /boot/vmlinuz-5.14.0-427.el10.x86_64"
  echo

  # STEP 2: list all boot entries (NO awk, NO escapes)
  echo "  Step 2: List all GRUB boot entries (kernel indexes) using grubby."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "grubby --info=ALL" ]]; then
    print_error "Incorrect. Use: grubby --info=ALL"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  index=0"
  echo "  kernel=/boot/vmlinuz-5.14.0-427.el10.x86_64"
  echo "  args=\"ro crashkernel=auto rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet\""
  echo "  initrd=/boot/initramfs-5.14.0-427.el10.x86_64.img"
  echo "  title=Rocky Linux (5.14.0-427.el10.x86_64)"
  echo
  echo "  index=1"
  echo "  kernel=/boot/vmlinuz-5.14.0-362.el10.x86_64"
  echo "  args=\"ro crashkernel=auto rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet\""
  echo "  initrd=/boot/initramfs-5.14.0-362.el10.x86_64.img"
  echo "  title=Rocky Linux (5.14.0-362.el10.x86_64)"
  echo

  # STEP 3: set default by index
  echo "  Step 3: Set the default boot entry to index 1."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo grubby --set-default-index=1" ]]; then
    print_error "Incorrect. Use: sudo grubby --set-default-index=1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 4: verify new default kernel
  echo "  Step 4: Verify the default kernel changed."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "grubby --default-kernel" ]]; then
    print_error "Incorrect. Use: grubby --default-kernel"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /boot/vmlinuz-5.14.0-362.el10.x86_64"
  echo

  # STEP 5: add persistent kernel arg to default kernel
  echo "  Step 5: Add the persistent kernel argument audit=1 to the DEFAULT kernel."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo grubby --update-kernel=DEFAULT --args='audit=1'" ]]; then
    print_error "Incorrect. Use: sudo grubby --update-kernel=DEFAULT --args='audit=1'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 6: verify audit=1 is now present in args
  echo "  Step 6: Verify the DEFAULT kernel args include audit=1."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "grubby --info=DEFAULT" ]]; then
    print_error "Incorrect. Use: grubby --info=DEFAULT"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  index=1"
  echo "  kernel=/boot/vmlinuz-5.14.0-362.el10.x86_64"
  echo "  args=\"ro crashkernel=auto rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet audit=1\""
  echo "  initrd=/boot/initramfs-5.14.0-362.el10.x86_64.img"
  echo

  # STEP 7: rebuild grub.cfg for consistency (BIOS path)
  echo "  Step 7: Regenerate the GRUB2 configuration file."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
    print_error "Incorrect. Use: sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Generating grub configuration file ..."
  echo "  Found linux image: /boot/vmlinuz-5.14.0-427.el10.x86_64"
  echo "  Found initrd image: /boot/initramfs-5.14.0-427.el10.x86_64.img"
  echo "  Found linux image: /boot/vmlinuz-5.14.0-362.el10.x86_64"
  echo "  Found initrd image: /boot/initramfs-5.14.0-362.el10.x86_64.img"
  echo "  done"
  echo

  # STEP 8: verify audit argument is visible via /proc/cmdline (requires reboot normally; simulate check)
  echo "  Step 8: Verify the current kernel command line (note: audit=1 appears after reboot)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "cat /proc/cmdline" ]]; then
    print_error "Incorrect. Use: cat /proc/cmdline"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  BOOT_IMAGE=(hd0,gpt2)/vmlinuz-5.14.0-362.el10.x86_64 ro crashkernel=auto rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet"
  echo "  (audit=1 will be present after reboot)"
  echo

  print_success "Excellent work."
  print_info "You successfully completed RHCSA-relevant GRUB2 tasks:"
  print_info "- listed boot entries using grubby (no awk)"
  print_info "- changed default boot entry by index"
  print_info "- added a persistent kernel argument via grubby"
  print_info "- regenerated grub.cfg safely"
  print_info "- verified default kernel and boot args"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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
