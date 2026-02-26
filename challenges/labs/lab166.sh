#!/bin/bash

# Lab 166: SELinux & Samba — Share Data and Fix SELinux Denials (contexts + boolean)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 166: SELinux & Samba"
LAB_ID="lab166"
LAB_XP=17200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab166:~$ "

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
  center_text "A team needs a quick SMB share for exchanging build artifacts."
  center_text "Samba is running, but SELinux blocks access to the share directory."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Install Samba and SELinux tooling
  echo "  Step 1: Install Samba and SELinux tools."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo dnf install -y samba samba-common policycoreutils-python-utils" && "$cmd1" != "dnf install -y samba samba-common policycoreutils-python-utils" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Updating Subscription Management repositories."
  echo "  Dependencies resolved."
  echo "  Installing: samba, samba-common, policycoreutils-python-utils"
  echo "  Complete!"
  echo

  # STEP 2: Create the share directory and set permissions
  echo "  Step 2: Create the share directory and set permissions."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo mkdir -p /srv/samba/share && sudo chmod 2770 /srv/samba/share" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 3: Configure Samba share and start service
  echo "  Step 3: Configure Samba to export /srv/samba/share, then enable and start smb."
  echo "  Open /etc/samba/smb.conf and add a share named [share] pointing to /srv/samba/share."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo vim /etc/samba/smb.conf" && "$cmd3" != "sudo nano /etc/samba/smb.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  [share]"
  echo "      path = /srv/samba/share"
  echo "      browseable = yes"
  echo "      writable = yes"
  echo "      guest ok = no"
  echo

  echo "  Enable and start smb:"
  read -p "$PROMPT" cmd3b
  echo
  if [[ "$cmd3b" != "sudo systemctl enable --now smb" && "$cmd3b" != "systemctl enable --now smb" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/smb.service → /usr/lib/systemd/system/smb.service."
  echo

  # STEP 4: Open firewall for Samba and create a Samba user
  echo "  Step 4: Allow Samba through the firewall and create an SMB user."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo firewall-cmd --permanent --add-service=samba" && "$cmd4" != "firewall-cmd --permanent --add-service=samba" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  read -p "$PROMPT" cmd4b
  echo
  if [[ "$cmd4b" != "sudo firewall-cmd --reload" && "$cmd4b" != "firewall-cmd --reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Create a local user for testing and set an SMB password:"
  read -p "$PROMPT" cmd4c
  echo
  if [[ "$cmd4c" != "sudo useradd -m smbuser && sudo smbpasswd -a smbuser" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  New SMB password:"
  echo "  Retype new SMB password:"
  echo "  Added user smbuser."
  echo

  # STEP 5: Confirm SELinux is the blocker by checking contexts and a boolean
  echo "  Step 5: Inspect SELinux context on the share directory and check Samba SELinux boolean."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls -Zd /srv/samba/share" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwxrws---. root root unconfined_u:object_r:default_t:s0 /srv/samba/share"
  echo

  read -p "$PROMPT" cmd5b
  echo
  if [[ "$cmd5b" != "getsebool samba_export_all_rw" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  samba_export_all_rw --> off"
  echo

  # STEP 6: Fix SELinux access using fcontext + restorecon and enable required boolean
  echo "  Step 6: Label the share for Samba and enable the required SELinux boolean."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo semanage fcontext -a -t samba_share_t '/srv/samba/share(/.*)?'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  read -p "$PROMPT" cmd6b
  echo
  if [[ "$cmd6b" != "sudo restorecon -Rv /srv/samba/share" && "$cmd6b" != "restorecon -Rv /srv/samba/share" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /srv/samba/share context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:samba_share_t:s0"
  echo

  read -p "$PROMPT" cmd6c
  echo
  if [[ "$cmd6c" != "sudo setsebool -P samba_export_all_rw on" && "$cmd6c" != "setsebool -P samba_export_all_rw on" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Boolean updated."
  echo

  # STEP 7: Verify the fix with context and boolean state
  echo "  Step 7: Verify SELinux context and boolean state for the share."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ls -Zd /srv/samba/share" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwxrws---. root root unconfined_u:object_r:samba_share_t:s0 /srv/samba/share"
  echo

  read -p "$PROMPT" cmd7b
  echo
  if [[ "$cmd7b" != "getsebool samba_export_all_rw" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  samba_export_all_rw --> on"
  echo

  # STEP 8: Cleanup: reset boolean and remove the custom fcontext rule
  echo "  Step 8: Cleanup: reset Samba SELinux boolean and remove the custom file context rule."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo setsebool -P samba_export_all_rw off" && "$cmd8" != "setsebool -P samba_export_all_rw off" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  read -p "$PROMPT" cmd8b
  echo
  if [[ "$cmd8b" != "sudo semanage fcontext -d '/srv/samba/share(/.*)?'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  read -p "$PROMPT" cmd8c
  echo
  if [[ "$cmd8c" != "sudo restorecon -Rv /srv/samba/share" && "$cmd8c" != "restorecon -Rv /srv/samba/share" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  print_success "Well done."
  print_info "You fixed a real SELinux workflow: Samba access requires correct file labeling and policy booleans."
  print_info "You applied a persistent fcontext rule, enforced labels with restorecon, and validated the policy state."
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
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done