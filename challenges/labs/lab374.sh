#!/bin/bash

# Lab 374: RHEL Troubleshooting — Repair Incorrect Filesystem Permissions After a Restore
# Focus: fixing broken ownership/modes after restore, validating against RPM metadata, restoring SELinux contexts
# Key skills: stat, ls -l, namei -l, find, rpm -V, rpm --setperms/--setugids, restorecon, getenforce,
# systemctl status/restart, journalctl, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 374: Repair Incorrect Permissions After a Restore"
LAB_ID="lab374"
LAB_XP=37400
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
  center_text "A server was restored from backup and is now behaving oddly."
  center_text "An admin reports that basic commands work, but services fail and users cannot read expected files."
  center_text "You suspect filesystem permissions/ownership and SELinux contexts were not preserved during restore."
  echo
  center_text "Goal: identify what changed, repair ownership/permissions safely, restore SELinux contexts, and verify."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm a symptom (service failure)
  echo "  Step 1: Check the status of sshd and note any permission-related errors."
  read -p "  lab@rhel-lab374:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo systemctl status sshd --no-pager" && \
        "$cmd1" != "systemctl status sshd --no-pager" && \
        "$cmd1" != "sudo systemctl status sshd" && \
        "$cmd1" != "systemctl status sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sshd.service - OpenSSH server daemon"
  echo "  Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)"
  echo "  Active: failed (Result: exit-code)"
  echo "  Process: 912 ExecStart=/usr/sbin/sshd -D \$OPTIONS (code=exited, status=255)"
  echo "  Jan 05 09:41:12 rhel-lab374 sshd[912]: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  echo "  Jan 05 09:41:12 rhel-lab374 sshd[912]: @         WARNING: UNPROTECTED PRIVATE KEY FILE!          @"
  echo "  Jan 05 09:41:12 rhel-lab374 sshd[912]: Permissions 0644 for '/etc/ssh/ssh_host_rsa_key' are too open."
  echo "  Jan 05 09:41:12 rhel-lab374 sshd[912]: It is required that your private key files are NOT accessible by others."
  echo "  Jan 05 09:41:12 rhel-lab374 sshd[912]: This private key will be ignored."
  echo

  # STEP 2: Inspect the file permissions directly
  echo "  Step 2: Inspect ownership and permissions of the SSH host key files."
  read -p "  lab@rhel-lab374:~$ " cmd2
  echo
  if [[ "$cmd2" != "ls -l /etc/ssh/ssh_host_*key" && \
        "$cmd2" != "sudo ls -l /etc/ssh/ssh_host_*key" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -rw-r--r--. 1 root root  2602 Jan 05 09:12 /etc/ssh/ssh_host_rsa_key"
  echo "  -rw-r--r--. 1 root root   564 Jan 05 09:12 /etc/ssh/ssh_host_ecdsa_key"
  echo "  -rw-r--r--. 1 root root   411 Jan 05 09:12 /etc/ssh/ssh_host_ed25519_key"
  echo

  # STEP 3: Check parent directory execute bits (common restore issue)
  echo "  Step 3: Verify permissions on the path components for /etc/ssh (directory execute bits)."
  read -p "  lab@rhel-lab374:~$ " cmd3
  echo
  if [[ "$cmd3" != "namei -l /etc/ssh/ssh_host_rsa_key" && \
        "$cmd3" != "sudo namei -l /etc/ssh/ssh_host_rsa_key" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  f: /etc/ssh/ssh_host_rsa_key"
  echo "  drwxr-xr-x root root /"
  echo "  drwxr-xr-x root root etc"
  echo "  drwxr-xr-x root root ssh"
  echo "  -rw-r--r-- root root ssh_host_rsa_key"
  echo

  # STEP 4: Use rpm verification to validate against packaged expectations
  echo "  Step 4: Verify the openssh-server package for permission/ownership drift."
  read -p "  lab@rhel-lab374:~$ " cmd4
  echo
  if [[ "$cmd4" != "rpm -V openssh-server" && \
        "$cmd4" != "sudo rpm -V openssh-server" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  .M.......  c /etc/ssh/sshd_config"
  echo "  .......U.    /etc/ssh/ssh_host_rsa_key"
  echo "  .......G.    /etc/ssh/ssh_host_rsa_key"
  echo "  .......P.    /etc/ssh/ssh_host_rsa_key"
  echo "  .......U.    /etc/ssh/ssh_host_ecdsa_key"
  echo "  .......G.    /etc/ssh/ssh_host_ecdsa_key"
  echo "  .......P.    /etc/ssh/ssh_host_ecdsa_key"
  echo "  .......U.    /etc/ssh/ssh_host_ed25519_key"
  echo "  .......G.    /etc/ssh/ssh_host_ed25519_key"
  echo "  .......P.    /etc/ssh/ssh_host_ed25519_key"
  echo

  # STEP 5: Restore owner/group defaults from RPM metadata
  echo "  Step 5: Restore default user/group ownership for openssh-server managed files."
  read -p "  lab@rhel-lab374:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo rpm --setugids openssh-server" && \
        "$cmd5" != "rpm --setugids openssh-server" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 6: Restore default permissions from RPM metadata
  echo "  Step 6: Restore default file permissions for openssh-server managed files."
  read -p "  lab@rhel-lab374:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo rpm --setperms openssh-server" && \
        "$cmd6" != "rpm --setperms openssh-server" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 7: Check SELinux mode (restore sometimes loses contexts)
  echo "  Step 7: Check SELinux mode."
  read -p "  lab@rhel-lab374:~$ " cmd7
  echo
  if [[ "$cmd7" != "getenforce" && "$cmd7" != "sestatus" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Enforcing"
  echo

  # STEP 8: Restore SELinux contexts on /etc/ssh
  echo "  Step 8: Restore SELinux contexts for /etc/ssh recursively."
  read -p "  lab@rhel-lab374:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo restorecon -RFv /etc/ssh" && \
        "$cmd8" != "restorecon -RFv /etc/ssh" && \
        "$cmd8" != "sudo restorecon -Rv /etc/ssh" && \
        "$cmd8" != "restorecon -Rv /etc/ssh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /etc/ssh/ssh_host_rsa_key context system_u:object_r:sshd_key_t:s0->system_u:object_r:sshd_key_t:s0"
  echo "  restorecon reset /etc/ssh/ssh_host_ecdsa_key context system_u:object_r:sshd_key_t:s0->system_u:object_r:sshd_key_t:s0"
  echo "  restorecon reset /etc/ssh/ssh_host_ed25519_key context system_u:object_r:sshd_key_t:s0->system_u:object_r:sshd_key_t:s0"
  echo

  # STEP 9: Restart sshd and confirm it comes up cleanly
  echo "  Step 9: Restart sshd and confirm it is active."
  read -p "  lab@rhel-lab374:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo systemctl restart sshd" && \
        "$cmd9" != "systemctl restart sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo
  echo "  Step 10: Confirm sshd is active and no longer reporting key permission errors."
  read -p "  lab@rhel-lab374:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo systemctl status sshd --no-pager" && \
        "$cmd10" != "systemctl status sshd --no-pager" && \
        "$cmd10" != "sudo journalctl -u sshd --no-pager | tail -n 20" && \
        "$cmd10" != "journalctl -u sshd --no-pager | tail -n 20" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sshd.service - OpenSSH server daemon"
  echo "  Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)"
  echo "  Active: active (running)"
  echo "  Jan 05 09:46:18 rhel-lab374 sshd[1102]: Server listening on 0.0.0.0 port 22."
  echo "  Jan 05 09:46:18 rhel-lab374 sshd[1102]: Server listening on :: port 22."
  echo

  print_success "Great job."
  print_info "You repaired incorrect permissions and contexts after a restore using an ops-safe workflow:"
  print_info "- confirmed service failure and validated file modes/ownership"
  print_info "- used rpm -V to identify drift, rpm --setugids/--setperms to restore packaged defaults"
  print_info "- restored SELinux contexts with restorecon and verified sshd recovered"
  print_info "You earned $LAB_XP XP for completing this lab."
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
