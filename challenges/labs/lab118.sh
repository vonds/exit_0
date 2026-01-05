#!/bin/bash

# Lab 118: Reconfiguring Installed Packages on RHEL (dnf/rpm + system tools)
# Focus: re-applying configuration safely and verifying changes without Debian dpkg-reconfigure
# Key skills: timedatectl, localectl, systemctl, ssh-keygen, rpm -V, restorecon, dnf reinstall,
# rpm --setperms/--setugids, and safe validation.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 118: Reconfiguring Installed Packages on RHEL"
LAB_ID="lab118"
LAB_XP=3000
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
  center_text "After a system hardening and package update, a RHEL server is behaving oddly:"
  center_text "- The time zone appears incorrect in logs"
  center_text "- SSH access was briefly unavailable after a restart"
  echo
  center_text "Goal: reconfigure safely and verify the changes."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  echo "  Step 1: Show the current system time zone."
  read -p "  lab@rhel-lab118:~$ " cmd1
  echo
  if [[ "$cmd1" != "timedatectl" && "$cmd1" != "timedatectl status" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Local time: Sun 2026-01-04 19:12:01 EST"
  echo "  Universal time: Sun 2026-01-05 00:12:01 UTC"
  echo "  RTC time: Sun 2026-01-05 00:12:01"
  echo "  Time zone: America/New_York (EST, -0500)"
  echo "  System clock synchronized: yes"
  echo "  NTP service: active"
  echo "  RTC in local TZ: no"
  echo

  echo "  Step 2: List available time zones (verify the correct target exists)."
  read -p "  lab@rhel-lab118:~$ " cmd2
  echo
  if [[ "$cmd2" != "timedatectl list-timezones | grep -i new_york" && \
        "$cmd2" != "timedatectl list-timezones | grep -i america/new_york" && \
        "$cmd2" != "timedatectl list-timezones | grep -i 'America/New_York'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  America/New_York"
  echo

  echo "  Step 3: Set the system time zone to America/New_York."
  read -p "  lab@rhel-lab118:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo timedatectl set-timezone America/New_York" && \
        "$cmd3" != "timedatectl set-timezone America/New_York" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  echo "  Step 4: Verify /etc/localtime points to the correct zoneinfo."
  read -p "  lab@rhel-lab118:~$ " cmd4
  echo
  if [[ "$cmd4" != "ls -l /etc/localtime" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  lrwxrwxrwx. 1 root root 33 Jan  4 19:12 /etc/localtime -> ../usr/share/zoneinfo/America/New_York"
  echo

  echo "  Step 5: Show current system locale settings."
  read -p "  lab@rhel-lab118:~$ " cmd5
  echo
  if [[ "$cmd5" != "localectl status" && "$cmd5" != "localectl" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  System Locale: LANG=en_US.UTF-8"
  echo "      VC Keymap: us"
  echo "     X11 Layout: us"
  echo

  echo "  Step 6: Ensure sshd is enabled and running."
  read -p "  lab@rhel-lab118:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl enable --now sshd" && \
        "$cmd6" != "systemctl enable --now sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Synchronizing state of sshd.service with SysV service script with /usr/lib/systemd/systemd-sysv-install."
  echo "  Executing: /usr/lib/systemd/systemd-sysv-install enable sshd"
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/sshd.service → /usr/lib/systemd/system/sshd.service."
  echo

  echo "  Step 7: Regenerate OpenSSH host keys safely."
  read -p "  lab@rhel-lab118:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo ssh-keygen -A" && "$cmd7" != "ssh-keygen -A" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ssh-keygen: generating new host keys: RSA ECDSA ED25519"
  echo

  echo "  Step 8: Restart sshd to pick up any key/config changes."
  read -p "  lab@rhel-lab118:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo systemctl restart sshd" && "$cmd8" != "systemctl restart sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  echo "  Step 9: Verify package integrity for openssh-server."
  read -p "  lab@rhel-lab118:~$ " cmd9
  echo
  if [[ "$cmd9" != "rpm -V openssh-server" && "$cmd9" != "sudo rpm -V openssh-server" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  echo "  Step 10: If a packaged config was damaged, reinstall openssh-server (repair workflow)."
  read -p "  lab@rhel-lab118:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo dnf reinstall -y openssh-server" && \
        "$cmd10" != "dnf reinstall -y openssh-server" && \
        "$cmd10" != "sudo dnf reinstall openssh-server" && \
        "$cmd10" != "dnf reinstall openssh-server" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:01:18 ago on Sun 04 Jan 2026."
  echo "  Dependencies resolved."
  echo "  Reinstalling:"
  echo "    openssh-server.x86_64  8.7p1-38.el9  baseos"
  echo "  Complete!"
  echo

  print_success "Great job."
  print_info "You re-applied configuration on a RHEL-like system without dpkg-reconfigure:"
  print_info "timezone via timedatectl, locale inspection via localectl, sshd state via systemctl,"
  print_info "host key regeneration via ssh-keygen -A, integrity checks via rpm -V, and repairs via dnf reinstall."
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
