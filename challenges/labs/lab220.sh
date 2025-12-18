#!/bin/bash

# Lab 220: Direct Map AutoFS for NFS /common → /autodir (SIMULATED & SAFE)
# SAFETY: This lab does NOT modify your system. It validates typed commands and prints canned outputs.
#         No real autofs edits, mounts, or services are changed. Config files are written to /tmp/.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 220: AutoFS Direct Map → /autodir/common"
LAB_ID="lab220"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated targets
NFS_SERVER="192.0.2.10"                  # RFC 5737 test IP
NFS_EXPORT="/common"
MNT_BASE="/autodir"
MNT_PATH="/autodir/common"

# Simulated config files (stand-ins for /etc/auto.master and /etc/auto.direct)
AUTO_MASTER_SIM="/tmp/auto.master.lab220"
AUTO_DIRECT_SIM="/tmp/auto.direct.lab220"

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
  center_text "Goal: Configure a DIRECT AutoFS map so $NFS_SERVER:$NFS_EXPORT appears at $MNT_PATH on access."
  center_text "Steps: install check → create mountpoint → write auto.master + direct map (simulated)"
  center_text "→ enable/restart autofs → trigger & verify mount with ls/findmnt/mount."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify autofs is installed (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check that autofs is installed."
  echo "          Expected: rpm -q autofs   (RHEL-ish)   OR   dpkg -l autofs   (Debian/Ubuntu)"
  read -p "  lab@lab220:~$ " cmd1
  if [[ "$cmd1" == "rpm -q autofs" ]]; then
    echo "autofs-5.1.8-1.el9.x86_64"
  elif [[ "$cmd1" == "dpkg -l autofs" ]]; then
    echo "Desired=Unknown/Install/Remove/Purge/Hold"
    echo "| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend"
    echo "|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)"
    echo "ii  autofs  5.1.8-1ubuntu1  amd64  kernel-based automounter for Linux"
  else
    print_error "Use either: rpm -q autofs   OR   dpkg -l autofs"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create the base mount directory (SIMULATED — mkdir prints nothing)
  echo "  Step 2: Create the base directory for direct mounts."
  echo "          Expected: sudo mkdir -p $MNT_PATH"
  read -p "  lab@lab220:~$ " cmd2
  [[ "$cmd2" != "sudo mkdir -p /autodir/common" ]] && { print_error "Use: sudo mkdir -p /autodir/common"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Configure auto.master to include a DIRECT map (SIMULATED)
  echo "  Step 3: Add a direct map to the (simulated) auto.master."
  echo "          Expected: echo '/- $AUTO_DIRECT_SIM' | sudo tee -a $AUTO_MASTER_SIM"
  read -p "  lab@lab220:~$ " cmd3
  [[ "$cmd3" != "echo '/- /tmp/auto.direct.lab220' | sudo tee -a /tmp/auto.master.lab220" ]] && {
    print_error "Use exactly: echo '/- /tmp/auto.direct.lab220' | sudo tee -a /tmp/auto.master.lab220"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "/- /tmp/auto.direct.lab220"
  echo

  # Step 4: Write the direct map entry (SIMULATED)
  echo "  Step 4: Create the direct map so $MNT_PATH maps to $NFS_SERVER:$NFS_EXPORT."
  echo "          Expected: echo '$MNT_PATH -rw,soft,_netdev,vers=4 $NFS_SERVER:$NFS_EXPORT' | sudo tee $AUTO_DIRECT_SIM"
  read -p "  lab@lab220:~$ " cmd4
  [[ "$cmd4" != "echo '/autodir/common -rw,soft,_netdev,vers=4 192.0.2.10:/common' | sudo tee /tmp/auto.direct.lab220" ]] && {
    print_error "Use the exact echo | sudo tee form shown"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "/autodir/common -rw,soft,_netdev,vers=4 192.0.2.10:/common"
  echo

  # Step 5: Enable and start autofs (SIMULATED)
  echo "  Step 5: Enable and start the autofs service."
  echo "          Expected: sudo systemctl enable --now autofs"
  read -p "  lab@lab220:~$ " cmd5
  [[ "$cmd5" != "sudo systemctl enable --now autofs" ]] && { print_error "Use: sudo systemctl enable --now autofs"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 6: Restart autofs and check status (SIMULATED)
  echo "  Step 6: Restart autofs to pick up changes, then check status."
  echo "          Expected: sudo systemctl restart autofs"
  read -p "  lab@lab220:~$ " cmd6a
  [[ "$cmd6a" != "sudo systemctl restart autofs" ]] && { print_error "Use: sudo systemctl restart autofs"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: systemctl status autofs"
  read -p "  lab@lab220:~$ " cmd6b
  [[ "$cmd6b" != "systemctl status autofs" ]] && { print_error "Use: systemctl status autofs"; read -p "Press Enter to try again..." _; continue; }
  echo "  ● autofs.service - Automounts filesystems on demand"
  echo "       Loaded: loaded (/lib/systemd/system/autofs.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 11:15:03 UTC; 5s ago"
  echo "     Main PID: 1358 (automount)"
  echo "        Tasks: 2 (limit: 32768)"
  echo "       Memory: 1.9M"
  echo "          CPU: 45ms"
  echo "       CGroup: /system.slice/autofs.service"
  echo "               └─1358 /usr/sbin/automount --pid-file /run/autofs.pid"
  echo

  # Step 7: Trigger the automount by accessing the path (SIMULATED)
  echo "  Step 7: Access the path to trigger the mount."
  echo "          Expected: ls -l $MNT_PATH"
  read -p "  lab@lab220:~$ " cmd7
  [[ "$cmd7" != "ls -l /autodir/common" ]] && { print_error "Use: ls -l /autodir/common"; read -p "Press Enter to try again..." _; continue; }
  echo "total 8"
  echo "-rw-r--r-- 1 nfsuser nfsuser  128 Jul 22 11:16 README.txt"
  echo "drwxr-xr-x 2 nfsuser nfsuser 4096 Jul 22 11:16 data"
  echo

  # Step 8: Verify the active mount (SIMULATED)
  echo "  Step 8: Verify the mount using findmnt and mount."
  echo "          Expected: findmnt -T $MNT_PATH"
  read -p "  lab@lab220:~$ " cmd8a
  [[ "$cmd8a" != "findmnt -T /autodir/common" ]] && { print_error "Use: findmnt -T /autodir/common"; read -p "Press Enter to try again..." _; continue; }
  echo "TARGET             SOURCE                  FSTYPE OPTIONS"
  echo "/autodir/common    192.0.2.10:/common     nfs4   rw,relatime,vers=4.2,soft,_netdev"
  echo
  echo "          Expected: mount | grep '/autodir'"
  read -p "  lab@lab220:~$ " cmd8b
  [[ "$cmd8b" != "mount | grep '/autodir'" ]] && { print_error "Use: mount | grep '/autodir'"; read -p "Press Enter to try again..." _; continue; }
  echo "automount on /autodir type autofs (rw,relatime,fd=31,pgrp=1358,timeout=300,minproto=5,maxproto=5,direct,pipe_ino=12345)"
  echo "192.0.2.10:/common on /autodir/common type nfs4 (rw,relatime,vers=4.2,soft,proto=tcp,timeo=600,retrans=2,sec=sys,_netdev,addr=192.0.2.10)"
  echo

  # Step 9 (bonus): Show current maps (SIMULATED)
  echo "  Step 9 (bonus): Display active automount maps."
  echo "          Expected: sudo automount -m"
  read -p "  lab@lab220:~$ " cmd9
  [[ "$cmd9" != "sudo automount -m" ]] && { print_error "Use: sudo automount -m"; read -p "Press Enter to try again..." _; continue; }
  echo "Mount point: /autodir"
  echo "    type: direct"
  echo "    map: /tmp/auto.direct.lab220"
  echo "    entries:"
  echo "        /autodir/common -> -rw,soft,_netdev,vers=4 192.0.2.10:/common"
  echo

  # Step 10: Show simulated config files (SIMULATED)
  echo "  Step 10: Review the simulated configuration files."
  echo "           Expected: cat $AUTO_MASTER_SIM"
  read -p "  lab@lab220:~$ " cmd10a
  [[ "$cmd10a" != "cat /tmp/auto.master.lab220" ]] && { print_error "Use: cat /tmp/auto.master.lab220"; read -p "Press Enter to try again..." _; continue; }
  echo "/- /tmp/auto.direct.lab220"
  echo
  echo "           Expected: cat $AUTO_DIRECT_SIM"
  read -p "  lab@lab220:~$ " cmd10b
  [[ "$cmd10b" != "cat /tmp/auto.direct.lab220" ]] && { print_error "Use: cat /tmp/auto.direct.lab220"; read -p "Press Enter to try again..." _; continue; }
  echo "/autodir/common -rw,soft,_netdev,vers=4 192.0.2.10:/common"
  echo

  print_success "Nice work! Direct AutoFS map configured (simulated) and verified at /autodir/common."
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
