#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 167: Secure Deployment Verification and SSH Recovery"
LAB_ID="lab167"
LAB_XP=28600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab167:~$ "

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
  center_text "A signed tarball is ready for deployment. Verify it."
  center_text "Then recover from a shadow mistake and apply a safe sshd change."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Import signing key (real: trust chain step)
  echo "  Step 1: Import the vendor public key."
  echo "  Assume vendor-pubkey.asc is in the current directory."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "gpg --import vendor-pubkey.asc" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  gpg: key 8A1B2C3D4E5F6789: public key \"Vendor Signing <release@vendor.example>\" imported"
  echo "  gpg: Total number processed: 1"
  echo "  gpg:               imported: 1"
  echo

  # STEP 2: Verify detached signature
  echo "  Step 2: Verify the detached signature for app.tar.gz."
  echo "  Assume app.tar.gz and app.tar.gz.sig are present."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "gpg --verify app.tar.gz.sig app.tar.gz" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  gpg: Good signature from \"Vendor Signing <release@vendor.example>\""
  echo

  # STEP 3: Recover from a shadow issue using backup
  echo "  Step 3: Recover from an /etc/shadow mistake by restoring /etc/shadow-."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo cp -a /etc/shadow- /etc/shadow" && "$cmd3" != "cp -a /etc/shadow- /etc/shadow" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Restored /etc/shadow from /etc/shadow-."
  echo

  # STEP 4: Safely edit sshd_config
  echo "  Step 4: Safely edit sshd_config using sudoedit."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudoedit /etc/ssh/sshd_config" && "$cmd4" != "sudo -e /etc/ssh/sshd_config" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  [sudo] password for examuser:"
  echo "  sudoedit: editing /etc/ssh/sshd_config"
  echo
  echo "  # You are now in your editor."
  echo "  # Make a small, safe change such as:"
  echo "  #   PermitRootLogin no"
  echo "  #   PasswordAuthentication no"
  echo "  # Save and quit (for vim: :wq)."
  echo
  echo "  Wrote /etc/ssh/sshd_config"
  echo

  # STEP 5: Validate config and restart sshd (real: don't lock yourself out)
  echo "  Step 5: Validate sshd config syntax, then restart sshd."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo sshd -t" && "$cmd5" != "sshd -t" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (No output indicates valid config.)"
  echo

  read -p "$PROMPT" cmd5b
  echo
  if [[ "$cmd5b" != "sudo systemctl restart sshd" && "$cmd5b" != "systemctl restart sshd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sshd restarted."
  echo

  print_success "Well done."
  print_info "You ran a real workflow: verify a signed artifact, recover shadow safely, and change sshd without breaking access."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done