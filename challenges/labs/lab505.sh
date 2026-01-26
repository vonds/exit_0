#!/bin/bash

# Lab 505: Configure autofs (On-Demand NFS Automount)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 505: Configure autofs"
LAB_ID="lab505"
LAB_XP=50500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab505:~$ "

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

while true; do
  clear
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "Your system should mount NFS directories only when accessed."
  center_text "You must configure autofs to automount an NFS export on demand."
  echo
  center_text "Targets:"
  center_text "- Server: nfs-server.example.com"
  center_text "- Export: /srv/nfs/shared"
  center_text "- Mount base: /mnt/nfs_shared"
  center_text "- Final mount: /mnt/nfs_shared/shared"
  echo
  read -p "Press Enter to begin..." _

  clear
  echo "  Step 1: Install the autofs package."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "sudo dnf install -y autofs" && "$cmd" != "sudo yum install -y autofs" ]] && continue
  echo "  Installed:"
  echo "    autofs-1:5.1.7-57.el9.x86_64"
  echo

  echo "  Step 2: Edit /etc/auto.master and configure the autofs mount point."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "sudo vim /etc/auto.master" ]] && continue
  echo "  (editor opened)"
  echo

  echo "  Step 3: Type the line you added to /etc/auto.master."
  read -p "$PROMPT" master
  echo
  [[ "$master" != "/mnt/nfs_shared  /etc/auto.nfs" ]] && continue

  echo "  Step 4: Create and edit the autofs map file."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "sudo vim /etc/auto.nfs" ]] && continue
  echo "  (editor opened)"
  echo

  echo "  Step 5: Type the NFS mapping line you added to /etc/auto.nfs."
  read -p "$PROMPT" map
  echo
  [[ "$map" != "shared  -rw,sync  nfs-server.example.com:/srv/nfs/shared" ]] && continue

  echo "  Step 6: Start the autofs service."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "sudo systemctl start autofs" ]] && continue

  echo "  Step 7: Enable autofs at boot."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "sudo systemctl enable autofs" ]] && continue
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/autofs.service → /usr/lib/systemd/system/autofs.service."
  echo

  echo "  Step 8: Verify autofs service status."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "sudo systemctl status autofs" ]] && continue
  echo "  ● autofs.service - Automounts filesystems on demand"
  echo "     Loaded: loaded (/usr/lib/systemd/system/autofs.service; enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 9: Trigger the automount by accessing the path."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "ls /mnt/nfs_shared/shared" ]] && continue
  echo "  docs"
  echo "  reports"
  echo "  team.txt"
  echo

  echo "  Step 10: Verify the active mount."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "findmnt /mnt/nfs_shared/shared" ]] && continue
  echo "  TARGET                  SOURCE                                   FSTYPE OPTIONS"
  echo "  /mnt/nfs_shared/shared  nfs-server.example.com:/srv/nfs/shared   nfs4   rw,relatime"
  echo

  echo "  Step 11: Unmount the directory manually."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "sudo umount /mnt/nfs_shared/shared" ]] && continue

  echo "  Step 12: Confirm it is no longer mounted."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "mount | grep nfs" ]] && continue
  echo

  echo "  Step 13: Trigger automount again."
  read -p "$PROMPT" cmd
  echo
  [[ "$cmd" != "ls /mnt/nfs_shared/shared" ]] && continue
  echo "  docs"
  echo "  reports"
  echo "  team.txt"
  echo

  print_success "Autofs configuration complete."
  award_xp $LAB_XP
  record_lab_completion

  echo
  read -p "Press Enter to exit lab..." _
  exit 0
done
