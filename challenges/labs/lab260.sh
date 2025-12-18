#!/bin/bash

# Lab 260: SELinux boolean — nfs_export_all_rw (temp + persistent) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real SELinux state is changed.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 260: SELinux boolean nfs_export_all_rw"
LAB_ID="lab260"
LAB_XP=21580
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

BOOL="nfs_export_all_rw"

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
  center_text "Goal: Inspect ${BOOL}, toggle it temporarily (runtime) and persistently (across reboots),"
  center_text "and verify each change using standard SELinux tools (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm SELinux mode
  draw_lab_ui
  echo "  Step 1: Show current SELinux mode."
  read -p "  lab@lab260:~$ " cmd1
  if [[ "$cmd1" == "getenforce" ]]; then
    echo "  Enforcing"
  elif [[ "$cmd1" == "sestatus" ]]; then
    echo "  SELinux status:                 enabled"
    echo "  Current mode:                   enforcing"
    echo "  Policy from config:             targeted"
  else
    print_error "Hint: Use a standard SELinux status command (e.g., getenforce)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Show current boolean state (runtime)
  echo "  Step 2: Display the current state of ${BOOL}."
  read -p "  lab@lab260:~$ " cmd2
  if [[ "$cmd2" == "getsebool ${BOOL}" ]]; then
    echo "  ${BOOL} --> off"
  elif [[ "$cmd2" == "semanage boolean -l | grep ${BOOL}" ]]; then
    echo "  ${BOOL}                       (off , off)   Allow NFS to export read/write by default"
  else
    print_error "Hint: Try getsebool ${BOOL} or list booleans and filter."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Temporarily enable the boolean (runtime only)
  echo "  Step 3: Enable ${BOOL} for the current runtime session (not persistent)."
  read -p "  lab@lab260:~$ " cmd3
  if [[ "$cmd3" == "setsebool ${BOOL} on" || "$cmd3" == "setsebool ${BOOL} 1" ]]; then
    :
  else
    print_error "Hint: Use setsebool <boolean> on (runtime)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 3 (verify): Check the new runtime state."
  read -p "  lab@lab260:~$ " cmd3v
  if [[ "$cmd3v" == "getsebool ${BOOL}" ]]; then
    echo "  ${BOOL} --> on"
  elif [[ "$cmd3v" == "semanage boolean -l | grep ${BOOL}" ]]; then
    echo "  ${BOOL}                       (on  , off)   Allow NFS to export read/write by default"
  else
    print_error "Hint: Verify with getsebool ${BOOL} or semanage boolean -l."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Persistently enable the boolean (-P writes policy)
  echo "  Step 4: Make the change persistent across reboots."
  read -p "  lab@lab260:~$ " cmd4
  if [[ "$cmd4" == "setsebool -P ${BOOL} on" || "$cmd4" == "semanage boolean -m --on ${BOOL}" || "$cmd4" == "semanage boolean -m -on ${BOOL}" ]]; then
    # (both setsebool -P and semanage -m are silent on success)
    :
  else
    print_error "Hint: Use setsebool -P ... or semanage boolean -m --on ${BOOL}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Verify persistent + runtime are on
  echo "  Step 5: Verify both runtime and persistent defaults reflect 'on'."
  read -p "  lab@lab260:~$ " cmd5
  if [[ "$cmd5" == "semanage boolean -l | grep ${BOOL}" ]]; then
    echo "  ${BOOL}                       (on  , on )   Allow NFS to export read/write by default"
  elif [[ "$cmd5" == "getsebool ${BOOL}" ]]; then
    echo "  ${BOOL} --> on"
  else
    print_error "Hint: Use semanage boolean -l | grep ${BOOL} to see (current , default)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6 (optional): Demonstrate turning it off and persisting
  echo "  Step 6 (optional): Turn ${BOOL} off persistently (press Enter to skip)."
  read -p "  lab@lab260:~$ " cmd6a
  if [[ -z "$cmd6a" || "$cmd6a" == "setsebool -P ${BOOL} off" || "$cmd6a" == "semanage boolean -m --off ${BOOL}" ]]; then
    if [[ -n "$cmd6a" ]]; then
      # (silent)
      echo
      echo "  Step 6 (verify): Re-check boolean default/state."
      read -p "  lab@lab260:~$ " cmd6v
      if [[ "$cmd6v" == "semanage boolean -l | grep ${BOOL}" ]]; then
        echo "  ${BOOL}                       (off , off)   Allow NFS to export read/write by default"
      elif [[ "$cmd6v" == "getsebool ${BOOL}" ]]; then
        echo "  ${BOOL} --> off"
      else
        print_error "Hint: Verify with semanage boolean -l | grep ${BOOL}."
        read -p "Press Enter to try again..." _
        continue
      fi
      echo
    fi
  else
    print_error "Hint: Use setsebool -P ${BOOL} off (or semanage boolean -m --off ${BOOL}), or press Enter to skip."
    read -p "Press Enter to try again..." _
    continue
  fi

  print_success "Nice work! You inspected ${BOOL}, toggled it at runtime, made the setting persistent, and verified each state (simulated)."
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
