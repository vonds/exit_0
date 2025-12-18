#!/bin/bash

# Lab 244: Change system hostname and verify prompt — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real system files are modified.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 244: Hostname change + prompt verify"
LAB_ID="lab244"
LAB_XP=20690
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

OLD_HOST="lpic-lab244"
NEW_HOST_FQDN="server-core.example.local"
NEW_HOST_SHORT="server-core"

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
  center_text "Goal: Inspect the current hostname, set a new static hostname, update /etc/hosts,"
  center_text "and verify that a new shell prompt reflects the change (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Show current hostname (accept several common commands)
  draw_lab_ui
  echo "  Step 1: Display the current hostname information."
  read -p "  lab@${OLD_HOST}:~$ " cmd1
  if [[ "$cmd1" == "hostnamectl status" || "$cmd1" == "hostnamectl" ]]; then
    echo "  Static hostname: ${OLD_HOST}"
    echo "  Icon name:       computer-vm"
    echo "  Chassis:         vm"
    echo "  Machine ID:      11111111111111111111111111111111"
    echo "  Boot ID:         22222222-3333-4444-5555-666666666666"
    echo "  Operating System: Linux (simulated)"
    echo "  Kernel:          5.15.0 (simulated)"
    echo "  Architecture:    x86-64"
  elif [[ "$cmd1" == "hostname" ]]; then
    echo "  ${OLD_HOST}"
  else
    print_error "Hint: Try 'hostnamectl status' or 'hostname'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Set the new static hostname (silent on success)
  echo "  Step 2: Set the static hostname to '${NEW_HOST_FQDN}'."
  read -p "  lab@${OLD_HOST}:~$ " cmd2
  if [[ "$cmd2" == "hostnamectl set-hostname ${NEW_HOST_FQDN}" || "$cmd2" == "sudo hostnamectl set-hostname ${NEW_HOST_FQDN}" ]]; then
    :
  else
    print_error "Hint: Use hostnamectl set-hostname <fqdn>."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Verify the new hostname via hostnamectl / hostname / /etc/hostname
  echo "  Step 3: Verify the hostname was updated."
  read -p "  lab@${OLD_HOST}:~$ " cmd3
  if [[ "$cmd3" == "hostnamectl status" || "$cmd3" == "hostnamectl" ]]; then
    echo "  Static hostname: ${NEW_HOST_FQDN}"
    echo "  Icon name:       computer-vm"
    echo "  Chassis:         vm"
    echo "  Machine ID:      11111111111111111111111111111111"
    echo "  Boot ID:         22222222-3333-4444-5555-666666666666"
    echo "  Operating System: Linux (simulated)"
    echo "  Kernel:          5.15.0 (simulated)"
    echo "  Architecture:    x86-64"
  elif [[ "$cmd3" == "hostname -f" ]]; then
    echo "  ${NEW_HOST_FQDN}"
  elif [[ "$cmd3" == "hostname" || "$cmd3" == "hostname -s" ]]; then
    echo "  ${NEW_HOST_SHORT}"
  elif [[ "$cmd3" == "cat /etc/hostname" ]]; then
    echo "  ${NEW_HOST_FQDN}"
  else
    print_error "Hint: Try 'hostnamectl', 'hostname -f', or 'cat /etc/hostname'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Add a 127.0.1.1 mapping for the new hostname (simulated tee echo)
  echo "  Step 4: Map the new hostname in /etc/hosts (127.0.1.1)."
  read -p "  lab@${OLD_HOST}:~$ " cmd4
  if [[ "$cmd4" == "echo '127.0.1.1 ${NEW_HOST_FQDN} ${NEW_HOST_SHORT}' | sudo tee -a /etc/hosts" ]] || \
     [[ "$cmd4" == "sudo sh -c 'echo \"127.0.1.1 ${NEW_HOST_FQDN} ${NEW_HOST_SHORT}\" >> /etc/hosts'" ]]; then
    echo "  127.0.1.1 ${NEW_HOST_FQDN} ${NEW_HOST_SHORT}"
  else
    print_error "Hint: Append a 127.0.1.1 line with FQDN and short name to /etc/hosts."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Start a new login shell so PS1 picks up the short hostname (silent)
  echo "  Step 5: Start a new login shell to refresh the prompt."
  read -p "  lab@${OLD_HOST}:~$ " cmd5
  if [[ "$cmd5" == "exec bash -l" ]]; then
    :
  else
    print_error "Hint: Use a login shell (e.g., exec bash -l) to refresh PS1."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Confirm the prompt/hostname now reflect the change
  echo "  Step 6: Confirm the short hostname in the new shell."
  read -p "  lab@${NEW_HOST_SHORT}:~$ " cmd6
  if [[ "$cmd6" == "hostname -s" || "$cmd6" == "hostname" ]]; then
    echo "  ${NEW_HOST_SHORT}"
  else
    print_error "Hint: Use 'hostname -s' or 'hostname'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # (Optional) Step 7: Verify resolution works using getent
  echo "  Step 7: Verify name resolution for the new hostname."
  read -p "  lab@${NEW_HOST_SHORT}:~$ " cmd7
  if [[ "$cmd7" == "getent hosts ${NEW_HOST_SHORT}" || "$cmd7" == "getent hosts ${NEW_HOST_FQDN}" ]]; then
    echo "  127.0.1.1 ${NEW_HOST_FQDN} ${NEW_HOST_SHORT}"
  else
    print_error "Hint: Try 'getent hosts ${NEW_HOST_SHORT}'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! Hostname updated, /etc/hosts mapped, and prompt verified (simulated)."
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
