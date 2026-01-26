#!/bin/bash

# Lab 465: Rocky Linux 10 — SELinux Contexts & sysctl Management (RHCSA Focus)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 465: SELinux Contexts & sysctl Configuration (Rocky 10)"
LAB_ID="lab465"
LAB_XP=46500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab465:~$ "

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
  center_text "You are auditing SELinux behavior and kernel parameters on a Rocky Linux 10 system."
  center_text "You must inspect SELinux contexts, save specific values to files,"
  center_text "and safely modify runtime and persistent sysctl settings."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: ps auxZ | grep sshd
  echo "  Step 1: Display SELinux context for sshd processes."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ps auxZ | grep sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:system_r:sshd_t:s0    root     1023  0.0  sshd"
  echo

  # STEP 2: edit /home/student/sshd
  echo "  Step 2: Open /home/student/sshd using vi."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "vi /home/student/sshd" && "$cmd2" != "vim /home/student/sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 3: Paste the SELinux context EXACTLY as seen (single line):"
  read -p "  > " sshdctx
  if [[ "$sshdctx" != "system_u:system_r:sshd_t:s0" ]]; then
    print_error "Incorrect SELinux context."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  # STEP 4: disable kernel modules
  echo "  Step 4: Disable kernel module loading at runtime."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo sysctl -w kernel.modules_disabled=1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  kernel.modules_disabled = 1"
  echo

  # STEP 5: ls -Z /bin/sudo
  echo "  Step 5: Display SELinux context of /bin/sudo."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls -Z /bin/sudo" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:object_r:sudo_exec_t:s0 /bin/sudo"
  echo

  # STEP 6: edit /home/student/selabel
  echo "  Step 6: Open /home/student/selabel using vi."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "vi /home/student/selabel" && "$cmd6" != "vim /home/student/selabel" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vi opened)"
  echo

  echo "  Step 7: Enter ONLY the SELinux type from the output:"
  read -p "  > " selabel
  if [[ "$selabel" != "sudo_exec_t" ]]; then
    print_error "Incorrect SELinux label."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  # STEP 8: enable IPv6 seg6
  echo "  Step 8: Enable IPv6 segment routing on loopback."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo sysctl -w net.ipv6.conf.lo.seg6_enabled=1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 9: edit sysctl.conf
  echo "  Step 9: Open /etc/sysctl.conf using vi."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo vi /etc/sysctl.conf" && "$cmd9" != "sudo vim /etc/sysctl.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 10: Add the following line EXACTLY:"
  read -p "  > " sysctl_line
  if [[ "$sysctl_line" != "vm.swappiness=10" ]]; then
    print_error "Incorrect sysctl configuration."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  # STEP 11: apply sysctl
  echo "  Step 11: Apply sysctl configuration."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo sysctl -p" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  vm.swappiness = 10"
  echo

  # STEP 12: chcon
  echo "  Step 12: Change SELinux type of /var/index.html."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo chcon -t httpd_sys_content_t /var/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 13: setenforce 0
  echo "  Step 13: Set SELinux to permissive mode."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo setenforce 0" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 14: semanage user -l
  echo "  Step 14: List SELinux users."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo semanage user -l" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  xguest_u  s0  s0:c0.c1023  user_r user_home_t"
  echo

  # STEP 15: edit /home/student/serole
  echo "  Step 15: Open /home/student/serole using vi."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "vi /home/student/serole" && "$cmd15" != "vim /home/student/serole" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 16: Enter the SELinux ROLES value for xguest_u:"
  read -p "  > " serole
  if [[ "$serole" != "user_r" ]]; then
    print_error "Incorrect SELinux role."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  print_success "Excellent work."
  print_info "You completed RHCSA-level SELinux and sysctl tasks on Rocky Linux 10:"
  print_info "- inspected and recorded SELinux process and file contexts"
  print_info "- modified kernel parameters at runtime and persistently"
  print_info "- adjusted SELinux enforcing mode and file labels"
  print_info "- queried SELinux users and roles"
  print_info "You earned $LAB_XP XP."
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
