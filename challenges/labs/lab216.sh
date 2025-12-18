#!/bin/bash

# Lab 216: Export NFS share /common and allow through firewall (SIMULATED & SAFE)
# SAFETY: This lab does NOT change your system. It only validates typed commands and prints canned outputs.
#         No real exports, services, or firewall rules are modified.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 216: NFS Export + Firewall"
LAB_ID="lab216"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated paths/files
EXPORT_DIR="/common"
EXPORTS_SIM="/tmp/exports.lab216"   # simulated /etc/exports

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
  center_text "Goal: Export $EXPORT_DIR via NFS and permit client access through the firewall."
  center_text "Actions: create share dir, configure simulated /etc/exports, start/enable NFS, export,"
  center_text "verify with exportfs/showmount, and allow NFS through firewalld."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Ensure NFS utilities are present (SIMULATED check)
  draw_lab_ui
  echo "  Step 1: Verify NFS utilities are installed."
  echo "          Expected: rpm -q nfs-utils   (or: dpkg -l nfs-common)"
  read -p "  lab@lab216:~$ " cmd1
  if [[ "$cmd1" == "rpm -q nfs-utils" ]]; then
    echo "nfs-utils-2.5.4-1.el9.x86_64"
  elif [[ "$cmd1" == "dpkg -l nfs-common" ]]; then
    echo "Desired=Unknown/Install/Remove/Purge/Hold"
    echo "| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend"
    echo "|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)"
    echo "ii  nfs-common 1:1.3.4-2.1ubuntu5 amd64 NFS support files common to client and server"
  else
    print_error "Use either: rpm -q nfs-utils   OR   dpkg -l nfs-common"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create the export directory (SIMULATED — mkdir outputs nothing)
  echo "  Step 2: Create the export directory."
  echo "          Expected: sudo mkdir -p $EXPORT_DIR"
  read -p "  lab@lab216:~$ " cmd2
  [[ "$cmd2" != "sudo mkdir -p /common" ]] && { print_error "Use: sudo mkdir -p /common"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Set permissive ownership/permissions (SIMULATED)
  echo "  Step 3: Set safe, open permissions (demo)."
  echo "          Expected: sudo chmod 0777 $EXPORT_DIR"
  read -p "  lab@lab216:~$ " cmd3
  [[ "$cmd3" != "sudo chmod 0777 /common" ]] && { print_error "Use: sudo chmod 0777 /common"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Add export to simulated /etc/exports
  echo "  Step 4: Configure the export (simulated /etc/exports)."
  echo "          Export to all clients with common options."
  echo "          Expected: echo '/common *(rw,sync,no_subtree_check)' | sudo tee -a $EXPORTS_SIM"
  read -p "  lab@lab216:~$ " cmd4
  [[ "$cmd4" != "echo '/common *(rw,sync,no_subtree_check)' | sudo tee -a /tmp/exports.lab216" ]] && {
    print_error "Use exactly: echo '/common *(rw,sync,no_subtree_check)' | sudo tee -a /tmp/exports.lab216"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "/common *(rw,sync,no_subtree_check)"
  echo

  # Step 5: Enable and start NFS server (SIMULATED)
  echo "  Step 5: Enable and start the NFS server."
  echo "          Expected: sudo systemctl enable --now nfs-server"
  read -p "  lab@lab216:~$ " cmd5
  [[ "$cmd5" != "sudo systemctl enable --now nfs-server" ]] && { print_error "Use: sudo systemctl enable --now nfs-server"; read -p "Press Enter to try again..." _; continue; }
  # (systemctl usually prints nothing on success)
  echo

  # Step 6: Export/reload NFS table (SIMULATED)
  echo "  Step 6: Apply export table."
  echo "          Expected: sudo exportfs -arv"
  read -p "  lab@lab216:~$ " cmd6
  [[ "$cmd6" != "sudo exportfs -arv" ]] && { print_error "Use: sudo exportfs -arv"; read -p "Press Enter to try again..." _; continue; }
  echo "exporting *:/common"
  echo

  # Step 7: Verify exports (SIMULATED)
  echo "  Step 7: Verify verbose export settings."
  echo "          Expected: sudo exportfs -v"
  read -p "  lab@lab216:~$ " cmd7
  [[ "$cmd7" != "sudo exportfs -v" ]] && { print_error "Use: sudo exportfs -v"; read -p "Press Enter to try again..." _; continue; }
  echo "/common"
  echo "        <world>(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,async)"
  echo

  # Step 8: Allow NFS through firewall (SIMULATED)
  echo "  Step 8: Open NFS service in the firewall (permanent) and reload."
  echo "          Expected: sudo firewall-cmd --add-service=nfs --permanent"
  read -p "  lab@lab216:~$ " cmd8a
  [[ "$cmd8a" != "sudo firewall-cmd --add-service=nfs --permanent" ]] && {
    print_error "Use: sudo firewall-cmd --add-service=nfs --permanent"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "success"
  echo
  echo "          Expected: sudo firewall-cmd --reload"
  read -p "  lab@lab216:~$ " cmd8b
  [[ "$cmd8b" != "sudo firewall-cmd --reload" ]] && { print_error "Use: sudo firewall-cmd --reload"; read -p "Press Enter to try again..." _; continue; }
  echo "success"
  echo
  echo "          Expected: sudo firewall-cmd --list-services"
  read -p "  lab@lab216:~$ " cmd8c
  [[ "$cmd8c" != "sudo firewall-cmd --list-services" ]] && { print_error "Use: sudo firewall-cmd --list-services"; read -p "Press Enter to try again..." _; continue; }
  echo "dhcpv6-client ssh nfs"
  echo

  # Step 9: Confirm clients can see the export (SIMULATED)
  echo "  Step 9: Show exports as seen locally."
  echo "          Expected: showmount -e localhost"
  read -p "  lab@lab216:~$ " cmd9
  [[ "$cmd9" != "showmount -e localhost" ]] && { print_error "Use: showmount -e localhost"; read -p "Press Enter to try again..." _; continue; }
  echo "Export list for localhost:"
  echo "/common *"
  echo

  print_success "Nice work! NFS share exported and firewall configured."
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
