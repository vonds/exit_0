#!/bin/bash

# Lab 197: Install Newer Kernel from Local Package (Operate Running Systems)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 197: Install Newer Kernel (Local RPM)"
LAB_ID="lab197"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

RPM_DIR="/root/rpms"
KERNEL_RPM="kernel-5.14.0-500.el9.x86_64.rpm"   # example filename for practice

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
  center_text "Goal: Check current kernel, install newer kernel from a local RPM, reboot, verify new kernel."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Show current running kernel
  draw_lab_ui
  echo "  Step 1: Show the current kernel version."
  echo "          Expected: uname -r"
  read -p "  lab@lab197:~$ " s1
  [[ "$s1" != "uname -r" ]] && { print_error "Use: uname -r"; read -p "Press Enter to try again..." _; continue; }
  echo "5.14.0-362.el9.x86_64"
  echo

  # Step 2: List available local kernel RPM (example)
  echo "  Step 2: List the local kernel RPM in $RPM_DIR."
  echo "          Expected: ls $RPM_DIR/$KERNEL_RPM"
  read -p "  lab@lab197:~$ " s2
  [[ "$s2" != "ls /root/rpms/kernel-5.14.0-500.el9.x86_64.rpm" ]] && { print_error "Use: ls /root/rpms/kernel-5.14.0-500.el9.x86_64.rpm"; read -p "Press Enter to try again..." _; continue; }
  echo "/root/rpms/kernel-5.14.0-500.el9.x86_64.rpm"
  echo

  # Step 3: Install the kernel RPM (rpm -ivh shows progress)
  echo "  Step 3: Install the new kernel from the local RPM."
  echo "          Expected: rpm -ivh $RPM_DIR/$KERNEL_RPM"
  read -p "  lab@lab197:~$ " s3
  [[ "$s3" != "rpm -ivh /root/rpms/kernel-5.14.0-500.el9.x86_64.rpm" ]] && { print_error "Use: rpm -ivh /root/rpms/kernel-5.14.0-500.el9.x86_64.rpm"; read -p "Press Enter to try again..." _; continue; }
  echo "Preparing...                          ################################# [100%]"
  echo "Updating / installing..."
  echo "   1:kernel-5.14.0-500.el9.x86_64     ################################# [100%]"
  echo

  # Step 4: Verify multiple kernel versions installed
  echo "  Step 4: Verify installed kernel packages."
  echo "          Expected: rpm -q kernel"
  read -p "  lab@lab197:~$ " s4
  [[ "$s4" != "rpm -q kernel" ]] && { print_error "Use: rpm -q kernel"; read -p "Press Enter to try again..." _; continue; }
  echo "kernel-5.14.0-362.el9.x86_64"
  echo "kernel-5.14.0-500.el9.x86_64"
  echo

  # Step 5: Reboot to load the new kernel
  echo "  Step 5: Reboot to boot into the new kernel."
  echo "          Expected: reboot"
  read -p "  lab@lab197:~$ " s5
  [[ "$s5" != "reboot" ]] && { print_error "Use: reboot"; read -p "Press Enter to try again..." _; continue; }
  echo "Rebooting."
  echo

  # Step 6: After reboot, verify running kernel version
  echo "  Step 6: After boot, verify the running kernel is the new one."
  echo "          Expected: uname -r"
  read -p "  lab@lab197:~$ " s6
  [[ "$s6" != "uname -r" ]] && { print_error "Use: uname -r"; read -p "Press Enter to try again..." _; continue; }
  echo "5.14.0-500.el9.x86_64"
  echo

  print_success "Nice work!"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
