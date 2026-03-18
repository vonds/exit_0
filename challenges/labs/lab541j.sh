#!/bin/bash

# Lab 541J: Modify Kernel Boot Parameters with grubby (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541J: Modify Kernel Boot Parameters with grubby"
LAB_ID="lab541j"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "ServerA currently boots with quiet graphical startup enabled."
  center_text "Modify the bootloader configuration so boot messages are visible"
  center_text "during startup by removing rhgb and quiet from the kernel args."
  echo

  center_text "Requirements:"
  center_text "- Remove rhgb"
  center_text "- Remove quiet"
  center_text "- Make the change apply persistently"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Inspect the current default kernel boot entry."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo grubby --info DEFAULT" ]]; then
    print_error "Incorrect. Use: sudo grubby --info DEFAULT"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  index=0"
  echo "  kernel=\"/boot/vmlinuz-5.14.0-600.el10.x86_64\""
  echo "  initrd=\"/boot/initramfs-5.14.0-600.el10.x86_64.img\""
  echo "  title=\"Red Hat Enterprise Linux (5.14.0-600.el10.x86_64) 10.0 (Plow)\""
  echo "  args=\"ro crashkernel=1G-4G:192M resume=/dev/mapper/rhel-swap root=/dev/mapper/rhel-root rhgb quiet\""
  echo

  echo "  Step 2: Remove the rhgb and quiet parameters from all installed kernels."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo grubby --update-kernel=ALL --remove-args=\"rhgb quiet\"" ]]; then
    print_error "Incorrect. Use: sudo grubby --update-kernel=ALL --remove-args=\"rhgb quiet\""
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  The default is /boot/vmlinuz-5.14.0-600.el10.x86_64 with index 0 and kernel args updated."
  echo

  echo "  Step 3: Verify the default kernel entry no longer includes rhgb or quiet."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo grubby --info DEFAULT" ]]; then
    print_error "Incorrect. Use: sudo grubby --info DEFAULT"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  index=0"
  echo "  kernel=\"/boot/vmlinuz-5.14.0-600.el10.x86_64\""
  echo "  initrd=\"/boot/initramfs-5.14.0-600.el10.x86_64.img\""
  echo "  title=\"Red Hat Enterprise Linux (5.14.0-600.el10.x86_64) 10.0 (Plow)\""
  echo "  args=\"ro crashkernel=1G-4G:192M resume=/dev/mapper/rhel-swap root=/dev/mapper/rhel-root\""
  echo

  echo "  Step 4: Inspect the generated GRUB defaults file to confirm quiet graphical boot is not configured there."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "grep '^GRUB_CMDLINE_LINUX' /etc/default/grub" ]]; then
    print_error "Incorrect. Use: grep '^GRUB_CMDLINE_LINUX' /etc/default/grub"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  GRUB_CMDLINE_LINUX=\"crashkernel=1G-4G:192M resume=/dev/mapper/rhel-swap root=/dev/mapper/rhel-root\""
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected the current default kernel boot entry"
  print_info "- removed rhgb and quiet from installed kernel entries"
  print_info "- verified the default boot entry no longer includes quiet graphical boot"
  print_info "- confirmed the GRUB defaults reflect visible boot messages"
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