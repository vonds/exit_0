#!/bin/bash

# Lab 541A: Reset the Root Password from the Recovery Environment (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541A: Reset the Root Password from the Recovery Environment"
LAB_ID="lab541a"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  dracut:/# "

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
  center_text "ServerA was booted into the recovery environment after the"
  center_text "root password was forgotten. Reset the root password so the"
  center_text "system can be accessed again after reboot."
  echo
  center_text "Important:"
  center_text "- Work from the recovery shell shown in the prompt"
  center_text "- Ensure the system will relabel files on the next boot"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Inspect the current mount state of the sysroot filesystem."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "mount | grep sysroot" ]]; then
    print_error "Incorrect. Use: mount | grep sysroot"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/mapper/rhel-root on /sysroot type xfs (ro,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,prjquota)"
  echo

  echo "  Step 2: Remount the sysroot filesystem as read-write."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "mount -o remount,rw /sysroot" ]]; then
    print_error "Incorrect. Use: mount -o remount,rw /sysroot"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Enter the installed system environment."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "chroot /sysroot" ]]; then
    print_error "Incorrect. Use: chroot /sysroot"
    read -p "Press Enter to retry..." _
    continue
  fi
  PROMPT="  sh-5.2# "
  echo

  echo "  Step 4: Reset the root password."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "passwd" && "$cmd4" != "passwd root" ]]; then
    print_error "Incorrect. Use: passwd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Changing password for user root."
  echo "  New password:"
  echo "  Retype new password:"
  echo "  passwd: all authentication tokens updated successfully."
  echo

  echo "  Step 5: Ensure SELinux relabeling will occur on the next boot."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "touch /.autorelabel" ]]; then
    print_error "Incorrect. Use: touch /.autorelabel"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Verify that the relabel marker file exists."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls -l /.autorelabel" ]]; then
    print_error "Incorrect. Use: ls -l /.autorelabel"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-r--r--. 1 root root 0 Mar 14 10:41 /.autorelabel"
  echo

  echo "  Step 7: Exit the chroot environment."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "exit" ]]; then
    print_error "Incorrect. Use: exit"
    read -p "Press Enter to retry..." _
    continue
  fi
  PROMPT="  dracut:/# "
  echo

  echo "  Step 8: Exit the recovery shell so the system can continue booting."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "exit" ]]; then
    print_error "Incorrect. Use: exit"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected the recovery environment"
  print_info "- remounted the root filesystem as read-write"
  print_info "- entered the installed system with chroot"
  print_info "- reset the root password"
  print_info "- scheduled SELinux relabeling and verified the marker"
  print_info "- exited the recovery environment cleanly"
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
