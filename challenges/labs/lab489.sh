#!/bin/bash

# Lab 489: Interrupt the Boot Process to Gain System Access

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 489: Interrupt Boot to Gain Access (GRUB + rd.break)"
LAB_ID="lab489"
LAB_XP=48900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  root@initramfs:/# "

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
  center_text "You have lost root access to a RHEL system."
  center_text "Normal login is not possible."
  center_text "You must interrupt the boot process"
  center_text "to regain administrative control."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify GRUB interruption key
  echo "  Step 1: Identify the key used to interrupt boot and access GRUB."
  read -p "  examuser@console:~$ " cmd1
  echo
  if [[ "$cmd1" != "Esc" && "$cmd1" != "Shift" ]]; then
    print_error "Incorrect. GRUB is accessed with Esc or Shift."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "GRUB menu displayed."
  echo

  # STEP 2: Edit kernel parameters
  echo "  Step 2: Identify the GRUB key used to edit kernel boot parameters."
  read -p "  examuser@grub:~$ " cmd2
  echo
  if [[ "$cmd2" != "e" ]]; then
    print_error "Incorrect. Press 'e' to edit the boot entry."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Kernel parameters opened for editing."
  echo

  # STEP 3: Append rd.break
  echo "  Step 3: Enter the kernel parameter used to break into initramfs."
  read -p "  examuser@grub-edit:~$ " cmd3
  echo
  if [[ "$cmd3" != "rd.break" ]]; then
    print_error "Incorrect. Append rd.break to the linux line."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "rd.break appended successfully."
  echo

  # STEP 4: Boot with modified parameters
  echo "  Step 4: Identify the key combo used to boot with modified parameters."
  read -p "  examuser@grub-edit:~$ " cmd4
  echo
  if [[ "$cmd4" != "Ctrl+X" && "$cmd4" != "F10" ]]; then
    print_error "Incorrect. Use Ctrl+X or F10."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Boot interrupted. Dropped into initramfs shell."
  echo

  # STEP 5: Remount root filesystem
  echo "  Step 5: Remount the root filesystem as read-write."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "mount -o remount,rw /sysroot" ]]; then
    print_error "Incorrect. Use mount -o remount,rw /sysroot."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Root filesystem remounted read-write."
  echo

  # STEP 6: Chroot into sysroot
  echo "  Step 6: Change root into the system environment."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "chroot /sysroot" ]]; then
    print_error "Incorrect. Use chroot /sysroot."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Switched root to /sysroot."
  echo

  # STEP 7: Reset root password
  echo "  Step 7: Reset the root password."
  read -p "  root@sysroot:/# " cmd7
  echo
  if [[ "$cmd7" != "passwd" ]]; then
    print_error "Incorrect. Use passwd."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "New password entered."
  echo "Password updated successfully."
  echo

  # STEP 8: Prepare SELinux relabel
  echo "  Step 8: Ensure SELinux relabeling occurs on next boot."
  read -p "  root@sysroot:/# " cmd8
  echo
  if [[ "$cmd8" != "touch /.autorelabel" ]]; then
    print_error "Incorrect. Use touch /.autorelabel."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "SELinux relabel scheduled."
  echo

  # STEP 9: Exit chroot
  echo "  Step 9: Exit the chroot environment."
  read -p "  root@sysroot:/# " cmd9
  echo
  if [[ "$cmd9" != "exit" ]]; then
    print_error "Incorrect. Use exit."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Exited chroot."
  echo

  # STEP 10: Reboot system
  echo "  Step 10: Exit initramfs to continue boot."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "exit" ]]; then
    print_error "Incorrect. Use exit."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "System rebooting..."
  echo "SELinux relabel in progress..."
  echo

  print_success "Outstanding work."
  print_info "You demonstrated RHCSA-critical recovery skills:"
  print_info "- interrupting GRUB safely"
  print_info "- modifying kernel boot parameters"
  print_info "- using rd.break and initramfs"
  print_info "- restoring root access correctly on SELinux systems"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
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
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done
