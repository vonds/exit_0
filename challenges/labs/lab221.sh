#!/bin/bash

# Lab 221: Indirect Map AutoFS for user30 NFS home → /nfshome (SIMULATED & SAFE)
# SAFETY: This lab does NOT modify your system. It validates typed commands and prints canned outputs.
#         No real autofs edits, mounts, or services are changed. Config files are written to /tmp/.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 221: AutoFS Indirect Map → /nfshome/user30"
LAB_ID="lab221"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated targets
NFS_SERVER="192.0.2.11"                  # RFC 5737 test IP
NFS_HOME_EXPORT="/home"
AUTOFS_BASE="/nfshome"
KEY_USER="user30"                        # Indirect map key
MNT_PATH="$AUTOFS_BASE/$KEY_USER"

# Simulated config files (stand-ins for /etc/auto.master and the map file)
AUTO_MASTER_SIM="/tmp/auto.master.lab221"
AUTO_MAP_SIM="/tmp/auto.nfshome.lab221"

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
  center_text "Goal: Configure an INDIRECT AutoFS map so $MNT_PATH is mounted on-demand from"
  center_text "$NFS_SERVER:$NFS_HOME_EXPORT/$KEY_USER. Verify by accessing the path and inspecting mounts."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify autofs installed (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check that autofs is installed."
  echo "          Expected: rpm -q autofs   (RHEL-ish)   OR   dpkg -l autofs   (Debian/Ubuntu)"
  read -p "  lab@lab221:~$ " cmd1
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

  # Step 2: Create base directory for the INDIRECT map (SIMULATED — mkdir prints nothing)
  echo "  Step 2: Create the base directory $AUTOFS_BASE for the indirect map."
  echo "          Expected: sudo mkdir -p $AUTOFS_BASE"
  read -p "  lab@lab221:~$ " cmd2
  [[ "$cmd2" != "sudo mkdir -p /nfshome" ]] && { print_error "Use: sudo mkdir -p /nfshome"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Configure auto.master to reference the indirect map (SIMULATED)
  echo "  Step 3: Add the indirect map to the (simulated) auto.master."
  echo "          Expected: echo '$AUTOFS_BASE $AUTO_MAP_SIM --timeout=300' | sudo tee -a $AUTO_MASTER_SIM"
  read -p "  lab@lab221:~$ " cmd3
  [[ "$cmd3" != "echo '/nfshome /tmp/auto.nfshome.lab221 --timeout=300' | sudo tee -a /tmp/auto.master.lab221" ]] && {
    print_error "Use exactly: echo '/nfshome /tmp/auto.nfshome.lab221 --timeout=300' | sudo tee -a /tmp/auto.master.lab221"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "/nfshome /tmp/auto.nfshome.lab221 --timeout=300"
  echo

  # Step 4: Create the indirect map entry for user30 (SIMULATED)
  echo "  Step 4: Map key '$KEY_USER' to the NFS export."
  echo "          Expected: echo '$KEY_USER -rw,soft,_netdev,vers=4 $NFS_SERVER:$NFS_HOME_EXPORT/$KEY_USER' | sudo tee $AUTO_MAP_SIM"
  read -p "  lab@lab221:~$ " cmd4
  [[ "$cmd4" != "echo 'user30 -rw,soft,_netdev,vers=4 192.0.2.11:/home/user30' | sudo tee /tmp/auto.nfshome.lab221" ]] && {
    print_error "Use the exact echo | sudo tee form shown"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "user30 -rw,soft,_netdev,vers=4 192.0.2.11:/home/user30"
  echo

  # Step 5: Enable and start autofs (SIMULATED)
  echo "  Step 5: Enable and start the autofs service."
  echo "          Expected: sudo systemctl enable --now autofs"
  read -p "  lab@lab221:~$ " cmd5
  [[ "$cmd5" != "sudo systemctl enable --now autofs" ]] && { print_error "Use: sudo systemctl enable --now autofs"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 6: Restart autofs and check status (SIMULATED)
  echo "  Step 6: Restart autofs to apply changes, then check status."
  echo "          Expected: sudo systemctl restart autofs"
  read -p "  lab@lab221:~$ " cmd6a
  [[ "$cmd6a" != "sudo systemctl restart autofs" ]] && { print_error "Use: sudo systemctl restart autofs"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: systemctl status autofs"
  read -p "  lab@lab221:~$ " cmd6b
  [[ "$cmd6b" != "systemctl status autofs" ]] && { print_error "Use: systemctl status autofs"; read -p "Press Enter to try again..." _; continue; }
  echo "  ● autofs.service - Automounts filesystems on demand"
  echo "       Loaded: loaded (/lib/systemd/system/autofs.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 11:28:11 UTC; 4s ago"
  echo "     Main PID: 2042 (automount)"
  echo "        Tasks: 2 (limit: 32768)"
  echo "       Memory: 2.1M"
  echo "          CPU: 39ms"
  echo "       CGroup: /system.slice/autofs.service"
  echo "               └─2042 /usr/sbin/automount --pid-file /run/autofs.pid"
  echo

  # Step 7: Trigger the automount by accessing the key path (SIMULATED)
  echo "  Step 7: Access $MNT_PATH to trigger the mount."
  echo "          Expected: ls -l $MNT_PATH"
  read -p "  lab@lab221:~$ " cmd7
  [[ "$cmd7" != "ls -l /nfshome/user30" ]] && { print_error "Use: ls -l /nfshome/user30"; read -p "Press Enter to try again..." _; continue; }
  echo "total 12"
  echo "-rw------- 1 user30 user30   908 Jul 22 11:29 .bash_history"
  echo "-rw-r--r-- 1 user30 user30   220 Jul 22 11:29 .bash_logout"
  echo "-rw-r--r-- 1 user30 user30  3771 Jul 22 11:29 .bashrc"
  echo "drwxr-xr-x 2 user30 user30  4096 Jul 22 11:29 Documents"
  echo

  # Step 8: Verify the active mount (SIMULATED)
  echo "  Step 8: Verify the mount using findmnt and mount."
  echo "          Expected: findmnt -T $MNT_PATH"
  read -p "  lab@lab221:~$ " cmd8a
  [[ "$cmd8a" != "findmnt -T /nfshome/user30" ]] && { print_error "Use: findmnt -T /nfshome/user30"; read -p "Press Enter to try again..." _; continue; }
  echo "TARGET            SOURCE                          FSTYPE OPTIONS"
  echo "/nfshome/user30   192.0.2.11:/home/user30        nfs4   rw,relatime,vers=4.2,soft,_netdev"
  echo
  echo "          Expected: mount | grep '/nfshome'"
  read -p "  lab@lab221:~$ " cmd8b
  [[ "$cmd8b" != "mount | grep '/nfshome'" ]] && { print_error "Use: mount | grep '/nfshome'"; read -p "Press Enter to try again..." _; continue; }
  echo "automount on /nfshome type autofs (rw,relatime,fd=35,pgrp=2042,timeout=300,indirect,pipe_ino=23456)"
  echo "192.0.2.11:/home/user30 on /nfshome/user30 type nfs4 (rw,relatime,vers=4.2,soft,proto=tcp,timeo=600,retrans=2,sec=sys,_netdev,addr=192.0.2.11)"
  echo

  # Step 9 (bonus): Show active maps (SIMULATED)
  echo "  Step 9 (bonus): Display active automount maps."
  echo "          Expected: sudo automount -m"
  read -p "  lab@lab221:~$ " cmd9
  [[ "$cmd9" != "sudo automount -m" ]] && { print_error "Use: sudo automount -m"; read -p "Press Enter to try again..." _; continue; }
  echo "Mount point: /nfshome"
  echo "    type: indirect"
  echo "    map: /tmp/auto.nfshome.lab221"
  echo "    entries:"
  echo "        user30 -> -rw,soft,_netdev,vers=4 192.0.2.11:/home/user30"
  echo

  # Step 10: Review simulated configuration files
  echo "  Step 10: Review simulated autofs configuration files."
  echo "           Expected: cat $AUTO_MASTER_SIM"
  read -p "  lab@lab221:~$ " cmd10a
  [[ "$cmd10a" != "cat /tmp/auto.master.lab221" ]] && { print_error "Use: cat /tmp/auto.master.lab221"; read -p "Press Enter to try again..." _; continue; }
  echo "/nfshome /tmp/auto.nfshome.lab221 --timeout=300"
  echo
  echo "           Expected: cat $AUTO_MAP_SIM"
  read -p "  lab@lab221:~$ " cmd10b
  [[ "$cmd10b" != "cat /tmp/auto.nfshome.lab221" ]] && { print_error "Use: cat /tmp/auto.nfshome.lab221"; read -p "Press Enter to try again..." _; continue; }
  echo "user30 -rw,soft,_netdev,vers=4 192.0.2.11:/home/user30"
  echo

  print_success "Nice work! Indirect AutoFS map configured (simulated) and verified at /nfshome/user30."
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
