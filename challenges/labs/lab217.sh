#!/bin/bash

# Lab 217: Mount remote NFS share at /local with a persistent fstab entry (SIMULATED & SAFE)
# SAFETY: This lab does NOT touch your system. It only validates typed commands and prints canned outputs.
#         No real mounts or fstab writes occur. Persistent lines go to /tmp/fstab.lab217 (simulated).
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 217: NFS Client Mount via UUID"
LAB_ID="lab217"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated server/share and mountpoint (RFC 5737 test IPs)
NFS_SERVER="192.0.2.10"
NFS_CLIENT_IP="192.0.2.20"
NFS_EXPORT="/common"
MNT="/local"
FSTAB_SIM="/tmp/fstab.lab217"

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
  center_text "Goal: Discover $NFS_SERVER:$NFS_EXPORT, mount it at $MNT using NFSv4, add a persistent entry to $FSTAB_SIM,"
  center_text "then validate the mount and the fstab configuration. (All actions are simulated.)"
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify NFS client utilities (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Verify NFS client utilities are installed."
  echo "          Expected: rpm -q nfs-utils   (RHEL-ish)   OR   dpkg -l nfs-common   (Debian/Ubuntu)"
  read -p "  lab@lab217:~$ " cmd1
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

  # Step 2: Discover exports on the server (SIMULATED)
  echo "  Step 2: List NFS exports on the server."
  echo "          Expected: showmount -e $NFS_SERVER"
  read -p "  lab@lab217:~$ " cmd2
  [[ "$cmd2" != "showmount -e 192.0.2.10" ]] && { print_error "Use: showmount -e 192.0.2.10"; read -p "Press Enter to try again..." _; continue; }
  echo "Export list for 192.0.2.10:"
  echo "/common *"
  echo

  # Step 3: Create the local mount point (SIMULATED — mkdir prints nothing)
  echo "  Step 3: Create the local mount point."
  echo "          Expected: sudo mkdir -p $MNT"
  read -p "  lab@lab217:~$ " cmd3
  [[ "$cmd3" != "sudo mkdir -p /local" ]] && { print_error "Use: sudo mkdir -p /local"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: One-time mount using NFSv4 (SIMULATED — mount prints nothing on success)
  echo "  Step 4: Mount the share using NFSv4."
  echo "          Expected: sudo mount -t nfs -o vers=4 $NFS_SERVER:$NFS_EXPORT $MNT"
  read -p "  lab@lab217:~$ " cmd4
  if [[ "$cmd4" != "sudo mount -t nfs -o vers=4 192.0.2.10:/common /local" ]]; then
    print_error "Use: sudo mount -t nfs -o vers=4 192.0.2.10:/common /local"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Verify the mount (SIMULATED)
  echo "  Step 5: Verify the mount is active."
  echo "          Expected: df -hT $MNT"
  read -p "  lab@lab217:~$ " cmd5a
  [[ "$cmd5a" != "df -hT /local" ]] && { print_error "Use: df -hT /local"; read -p "Press Enter to try again..." _; continue; }
  echo "Filesystem               Type  Size  Used Avail Use% Mounted on"
  echo "192.0.2.10:/common       nfs4   50G  2.0G   48G   4% /local"
  echo
  echo "          (Alt) Show the detailed mount entry."
  echo "          Expected: mount | grep ' /local '"
  read -p "  lab@lab217:~$ " cmd5b
  [[ "$cmd5b" != "mount | grep ' /local '" ]] && { print_error "Use exactly: mount | grep ' /local '"; read -p "Press Enter to try again..." _; continue; }
  echo "192.0.2.10:/common on /local type nfs4 (rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=$NFS_CLIENT_IP,local_lock=none,addr=$NFS_SERVER)"
  echo

  # Step 6: Add a persistent entry to the simulated fstab
  echo "  Step 6: Add a persistent entry to $FSTAB_SIM."
  echo "          Expected: echo '$NFS_SERVER:$NFS_EXPORT $MNT nfs defaults,_netdev,vers=4 0 0' | sudo tee -a $FSTAB_SIM"
  read -p "  lab@lab217:~$ " cmd6
  [[ "$cmd6" != "echo '192.0.2.10:/common /local nfs defaults,_netdev,vers=4 0 0' | sudo tee -a /tmp/fstab.lab217" ]] && {
    print_error "Use the exact echo | sudo tee -a form shown"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "192.0.2.10:/common /local nfs defaults,_netdev,vers=4 0 0"
  echo

  # Step 7: Test the fstab entry by remounting (SIMULATED)
  echo "  Step 7: Test remount via fstab."
  echo "          Expected: sudo umount $MNT"
  read -p "  lab@lab217:~$ " cmd7a
  [[ "$cmd7a" != "sudo umount /local" ]] && { print_error "Use: sudo umount /local"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: sudo mount -a"
  read -p "  lab@lab217:~$ " cmd7b
  [[ "$cmd7b" != "sudo mount -a" ]] && { print_error "Use: sudo mount -a"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: findmnt -T $MNT"
  read -p "  lab@lab217:~$ " cmd7c
  [[ "$cmd7c" != "findmnt -T /local" ]] && { print_error "Use: findmnt -T /local"; read -p "Press Enter to try again..." _; continue; }
  echo "TARGET SOURCE                 FSTYPE OPTIONS"
  echo "/local  192.0.2.10:/common    nfs4   rw,relatime,vers=4.2,_netdev"
  echo

  # Step 8: Show simulated fstab contents (SIMULATED)
  echo "  Step 8: Display $FSTAB_SIM."
  echo "          Expected: cat $FSTAB_SIM"
  read -p "  lab@lab217:~$ " cmd8
  [[ "$cmd8" != "cat /tmp/fstab.lab217" ]] && { print_error "Use: cat /tmp/fstab.lab217"; read -p "Press Enter to try again..." _; continue; }
  echo "192.0.2.10:/common /local nfs defaults,_netdev,vers=4 0 0"
  echo

  print_success "Nice work! Remote NFS share mounted at /local with a persistent (simulated) fstab entry."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completio
