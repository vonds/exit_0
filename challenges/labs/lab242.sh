#!/bin/bash

# Lab 242: Firewalld — runtime vs permanent rules (HTTP, HTTPS, VNC) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real firewall changes occur.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 242: Firewalld permanent + runtime rules (HTTP, HTTPS, VNC)"
LAB_ID="lab242"
LAB_XP=20650
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

ZONE="public"

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
  center_text "Goal: Inspect firewalld, add HTTP/HTTPS/VNC to the runtime config, then make them permanent."
  center_text "You’ll verify the default zone, list services, add rules, reload, and confirm."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Check firewalld service status
  draw_lab_ui
  echo "  Step 1: Show firewalld service status."
  read -p "  lab@lab242:~$ " cmd1
  if [[ "$cmd1" == "systemctl status firewalld" ]]; then
    echo "  ● firewalld.service - firewalld - dynamic firewall daemon"
    echo "       Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)"
    echo "       Active: active (running) since Tue 2025-07-22 09:40:01 UTC; 1h 12min ago"
    echo "         Docs: man:firewalld(1)"
    echo "     Main PID: 735 (firewalld)"
    echo "        Tasks: 2 (limit: 32768)"
    echo "       Memory: 22.0M"
    echo "          CPU: 340ms"
    echo "       CGroup: /system.slice/firewalld.service"
    echo "               └─735 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid"
    echo "  "
    echo "  Jul 22 09:40:01 lpic-lab242 systemd[1]: Started firewalld - dynamic firewall daemon."
    echo "  Jul 22 09:40:02 lpic-lab242 firewalld[735]: WARNING: AllowZoneDrifting is deprecated"
  else
    print_error "Hint: Use systemctl status firewalld"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Get default zone
  echo "  Step 2: Display the default zone."
  read -p "  lab@lab242:~$ " cmd2
  if [[ "$cmd2" == "firewall-cmd --get-default-zone" ]]; then
    echo "  ${ZONE}"
  else
    print_error "Hint: firewall-cmd --get-default-zone"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: List current runtime services in the default zone
  echo "  Step 3: List services currently allowed (runtime) in the default zone."
  read -p "  lab@lab242:~$ " cmd3
  if [[ "$cmd3" == "firewall-cmd --list-services" ]]; then
    echo "  dhcpv6-client ssh"
  else
    print_error "Hint: firewall-cmd --list-services"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Add HTTP and HTTPS to the runtime configuration
  echo "  Step 4a: Add HTTP (runtime)."
  read -p "  lab@lab242:~$ " cmd4a
  [[ "$cmd4a" != "firewall-cmd --add-service=http" ]] && {
    print_error "Hint: firewall-cmd --add-service=http"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo
  echo "  Step 4b: Add HTTPS (runtime)."
  read -p "  lab@lab242:~$ " cmd4b
  [[ "$cmd4b" != "firewall-cmd --add-service=https" ]] && {
    print_error "Hint: firewall-cmd --add-service=https"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo

  # Step 5: Add VNC to runtime and verify
  echo "  Step 5: Add VNC (runtime)."
  read -p "  lab@lab242:~$ " cmd5a
  [[ "$cmd5a" != "firewall-cmd --add-service=vnc-server" ]] && {
    print_error "Hint: firewall-cmd --add-service=vnc-server"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo
  echo "  Step 5 (cont.): Re-list runtime services."
  read -p "  lab@lab242:~$ " cmd5b
  if [[ "$cmd5b" == "firewall-cmd --list-services" ]]; then
    echo "  dhcpv6-client http https ssh vnc-server"
  else
    print_error "Hint: firewall-cmd --list-services"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Make the rules permanent (add per-service to permanent config)
  echo "  Step 6: Add the same services to the PERMANENT config."
  read -p "  lab@lab242:~$ " cmd6a
  [[ "$cmd6a" != "firewall-cmd --permanent --add-service=http" ]] && {
    print_error "Hint: firewall-cmd --permanent --add-service=http"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  read -p "  lab@lab242:~$ " cmd6b
  [[ "$cmd6b" != "firewall-cmd --permanent --add-service=https" ]] && {
    print_error "Hint: firewall-cmd --permanent --add-service=https"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  read -p "  lab@lab242:~$ " cmd6c
  [[ "$cmd6c" != "firewall-cmd --permanent --add-service=vnc-server" ]] && {
    print_error "Hint: firewall-cmd --permanent --add-service=vnc-server"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo

  # Step 7: Reload and verify permanent + runtime alignment
  echo "  Step 7: Reload firewalld and verify permanent services."
  read -p "  lab@lab242:~$ " cmd7a
  [[ "$cmd7a" != "firewall-cmd --reload" ]] && {
    print_error "Hint: firewall-cmd --reload"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  success"
  echo
  read -p "  lab@lab242:~$ " cmd7b
  if [[ "$cmd7b" == "firewall-cmd --permanent --list-services" ]]; then
    echo "  dhcpv6-client http https ssh vnc-server"
  else
    print_error "Hint: firewall-cmd --permanent --list-services"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  read -p "  lab@lab242:~$ " cmd7c
  if [[ "$cmd7c" == "firewall-cmd --list-services" ]]; then
    echo "  dhcpv6-client http https ssh vnc-server"
  else
    print_error "Hint: firewall-cmd --list-services"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! You inspected firewalld, added HTTP/HTTPS/VNC at runtime, made them permanent, reloaded, and verified (simulated)."
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
