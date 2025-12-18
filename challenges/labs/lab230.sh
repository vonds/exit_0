#!/bin/bash

# Lab 230: Set Timezone + Configure NTP with chrony (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real packages, services, or system configs are changed.
#         A simulated chrony config is written under /tmp for practice.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 230: Timezone + NTP (chrony)"
LAB_ID="lab230"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

SIM_CHRONY_UNIT_A="chronyd"   # RHEL/Fedora family
SIM_CHRONY_UNIT_B="chrony"    # Debian/Ubuntu family
SIM_CONF="/tmp/chrony.lab230.conf"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$LEVEL" "$(calculate_xp_to_next_level)"
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
  center_text "Goal: Inspect and change the system timezone, install and enable chrony,"
  center_text "configure pool servers in a SIMULATED config, and verify NTP sync."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Inspect current time settings
  draw_lab_ui
  echo "  Step 1: Show current time settings and timezone."
  read -p "  lab@lab230:~$ " cmd1
  [[ "$cmd1" != "timedatectl status" ]] && {
    print_error "Hint: Use the time control utility to view status."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "               Local time: Tue 2025-07-22 05:58:37 PDT"
  echo "           Universal time: Tue 2025-07-22 12:58:37 UTC"
  echo "                 RTC time: Tue 2025-07-22 12:58:36"
  echo "                Time zone: America/Los_Angeles (PDT, -0700)"
  echo "System clock synchronized: no"
  echo "              NTP service: inactive"
  echo "          RTC in local TZ: no"
  echo

  # Step 2: Change timezone (to UTC for practice)
  echo "  Step 2: Change the system timezone to UTC."
  read -p "  lab@lab230:~$ " cmd2
  if [[ "$cmd2" != "sudo timedatectl set-timezone UTC" && "$cmd2" != "timedatectl set-timezone UTC" ]]; then
    print_error "Hint: Use the time control utility to set the timezone."
    read -p "Press Enter to try again..." _
    continue
  fi
  # (timedatectl set-timezone prints no output on success)
  echo

  # Step 3: Verify timezone change
  echo "  Step 3: Verify the new timezone is active."
  read -p "  lab@lab230:~$ " cmd3
  [[ "$cmd3" != "timedatectl status" ]] && {
    print_error "Hint: Re-run the status view to confirm."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "               Local time: Tue 2025-07-22 12:58:40 UTC"
  echo "           Universal time: Tue 2025-07-22 12:58:40 UTC"
  echo "                 RTC time: Tue 2025-07-22 12:58:39"
  echo "                Time zone: UTC (UTC, +0000)"
  echo "System clock synchronized: no"
  echo "              NTP service: inactive"
  echo "          RTC in local TZ: no"
  echo

  # Step 4: Install chrony
  echo "  Step 4: Install the NTP client (chrony)."
  read -p "  lab@lab230:~$ " cmd4
  if [[ "$cmd4" == "sudo dnf install -y chrony" ]]; then
    echo "Last metadata expiration check: 0:02:03 ago on Tue 22 Jul 2025 12:56:37 PM UTC."
    echo "Dependencies resolved."
    echo "================================================================================"
    echo " Package  Arch   Version        Repository   Size"
    echo "================================================================================"
    echo "Installing:"
    echo " chrony   x86_64 4.5-3.el9      appstream    470 k"
    echo
    echo "Installed:"
    echo "  chrony-4.5-3.el9.x86_64"
  elif [[ "$cmd4" == "sudo apt-get install -y chrony" ]]; then
    echo "Reading package lists... Done"
    echo "Building dependency tree... Done"
    echo "Reading state information... Done"
    echo "The following NEW packages will be installed:"
    echo "  chrony"
    echo "0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded."
    echo "Setting up chrony (4.5-1) ..."
  else
    print_error "Hint: Install the chrony package using your distro's package manager."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Enable and start chrony service
  echo "  Step 5: Enable and start the chrony service."
  read -p "  lab@lab230:~$ " cmd5
  if [[ "$cmd5" != "sudo systemctl enable --now chronyd" && "$cmd5" != "sudo systemctl enable --now chrony" ]]; then
    print_error "Hint: Use the service manager to enable and start the NTP client."
    read -p "Press Enter to try again..." _
    continue
  fi
  # (enable --now typically silent here)
  echo

  # Step 6: Confirm service is running
  echo "  Step 6: Check the status of the NTP client service."
  read -p "  lab@lab230:~$ " cmd6
  if [[ "$cmd6" == "systemctl status chronyd" || "$cmd6" == "systemctl status chrony" ]]; then
    echo "  ● ${cmd6##*status } .service - Network Time Synchronization (chrony)"
    echo "       Loaded: loaded (/usr/lib/systemd/system/${cmd6##*status }.service; enabled; vendor preset: enabled)"
    echo "       Active: active (running) since Tue 2025-07-22 12:59:12 UTC; 5s ago"
    echo "     Main PID: 2042 (${cmd6##*status })"
    echo "        Tasks: 1 (limit: 32768)"
    echo "       Memory: 1.8M"
    echo "          CPU: 24ms"
    echo "       CGroup: /system.slice/${cmd6##*status }.service"
    echo "               └─2042 /usr/sbin/${cmd6##*status } -F 2"
    echo
  else
    print_error "Hint: Use the service-status command for the chrony unit."
    read -p "Press Enter to try again..." _
    continue
  fi

  # Step 7: Prepare a SIMULATED chrony config with pool servers
  echo "  Step 7: Create a simulated chrony config with two pool servers at ${SIM_CONF}."
  read -p "  lab@lab230:~$ " cmd7
  if [[ "$cmd7" == *"${SIM_CONF}"* && "$cmd7" == *"server 0.pool.ntp.org"* && "$cmd7" == *"server 1.pool.ntp.org"* ]]; then
    echo "server 0.pool.ntp.org iburst" > "$SIM_CONF"
    echo "server 1.pool.ntp.org iburst" >> "$SIM_CONF"
    echo
    echo "  (simulated) $SIM_CONF now contains:"
    echo "server 0.pool.ntp.org iburst"
    echo "server 1.pool.ntp.org iburst"
  else
    print_error "Hint: Write two 'server … iburst' lines for 0.pool.ntp.org and 1.pool.ntp.org into the simulated file."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Restart the service to apply changes
  echo "  Step 8: Restart the NTP client service."
  read -p "  lab@lab230:~$ " cmd8
  if [[ "$cmd8" != "sudo systemctl restart chronyd" && "$cmd8" != "sudo systemctl restart chrony" ]]; then
    print_error "Hint: Use the service manager to restart the NTP client."
    read -p "Press Enter to try again..." _
    continue
  fi
  # (restart is silent)
  echo

  # Step 9: Inspect synchronization (choose either sources -v or tracking)
  echo "  Step 9: Show NTP sync details (sources or tracking)."
  read -p "  lab@lab230:~$ " cmd9
  if [[ "$cmd9" == "chronyc sources -v" ]]; then
    echo "210 Number of sources = 2"
    echo "MS Name/IP address         Stratum Poll Reach LastRx Last sample"
    echo "============================================================================="
    echo "^* time.cloudflare.com           3   6   377     11   -112us[ -1ms] +/-   5ms"
    echo "^+ time.google.com               1   6   377      9   +734us[+632us] +/-   6ms"
  elif [[ "$cmd9" == "chronyc tracking" ]]; then
    echo "Reference ID    : 8CFB8D98 (time.cloudflare.com)"
    echo "Stratum         : 4"
    echo "Ref time (UTC)  : Tue Jul 22 13:00:22 2025"
    echo "System time     : 0.000098 seconds slow of NTP time"
    echo "Last offset     : -0.000112 seconds"
    echo "RMS offset      : 0.000154 seconds"
    echo "Frequency       : 2.345 ppm fast"
    echo "Residual freq   : -0.123 ppm"
    echo "Skew            : 0.500 ppm"
    echo "Root delay      : 0.005123 seconds"
    echo "Root dispersion : 0.002345 seconds"
    echo "Update interval : 64.0 seconds"
    echo "Leap status     : Normal"
  else
    print_error "Hint: Use either 'chronyc sources -v' or 'chronyc tracking'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 10: Confirm NTP is considered active by the system
  echo "  Step 10: Re-check system time status."
  read -p "  lab@lab230:~$ " cmd10
  [[ "$cmd10" != "timedatectl status" ]] && {
    print_error "Hint: Use the same time control utility to view status again."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "               Local time: Tue 2025-07-22 13:00:30 UTC"
  echo "           Universal time: Tue 2025-07-22 13:00:30 UTC"
  echo "                 RTC time: Tue 2025-07-22 13:00:29"
  echo "                Time zone: UTC (UTC, +0000)"
  echo "System clock synchronized: yes"
  echo "              NTP service: active"
  echo "          RTC in local TZ: no"
  echo

  print_success "Great job! Timezone changed, chrony installed and enabled, servers configured, and sync verified (simulated)."
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
