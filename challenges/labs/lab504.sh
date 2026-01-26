#!/bin/bash

# Lab 504: Mount and Unmount Network File Systems using NFS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 504: NFS Mounting & Persistence"
LAB_ID="lab504"
LAB_XP=50400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab504:~$ "

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
  center_text "Your system must access a shared directory hosted on an NFS server."
  center_text "You must mount it temporarily, configure persistence, test safely,"
  center_text "verify functionality, and cleanly unmount it."
  echo
  center_text "Targets:"
  center_text "- NFS Server: nfs-server.example.com"
  center_text "- Exported Path: /srv/nfs/shared"
  center_text "- Local Mount: /mnt/nfs_shared"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create the mount point directory."
  read -p "$PROMPT" cmd1
  echo
  [[ "$cmd1" != "sudo mkdir -p /mnt/nfs_shared" ]] && { print_error "Use: sudo mkdir -p /mnt/nfs_shared"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 2: Temporarily mount the NFS share."
  read -p "$PROMPT" cmd2
  echo
  [[ "$cmd2" != "sudo mount -t nfs nfs-server.example.com:/srv/nfs/shared /mnt/nfs_shared" ]] && {
    print_error "Use: sudo mount -t nfs nfs-server.example.com:/srv/nfs/shared /mnt/nfs_shared"
    read -p "Press Enter..." _
    continue
  }
  echo

  echo "  Step 3: Verify the mount using df."
  read -p "$PROMPT" cmd3
  echo
  [[ "$cmd3" != "df -h /mnt/nfs_shared" ]] && { print_error "Use: df -h /mnt/nfs_shared"; read -p "Press Enter..." _; continue; }
  echo "Filesystem                             Size  Used Avail Use% Mounted on"
  echo "nfs-server.example.com:/srv/nfs/shared 100G  1.2G   99G   2% /mnt/nfs_shared"
  echo

  echo "  Step 4: Unmount the temporary NFS mount."
  read -p "$PROMPT" cmd4
  echo
  [[ "$cmd4" != "sudo umount /mnt/nfs_shared" ]] && { print_error "Use: sudo umount /mnt/nfs_shared"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 5: Edit /etc/fstab to configure persistent mounting."
  read -p "$PROMPT" cmd5
  echo
  [[ "$cmd5" != "sudo vim /etc/fstab" && "$cmd5" != "vim /etc/fstab" ]] && { print_error "Use: sudo vim /etc/fstab"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 6: Add the NFS fstab entry."
  read -p "$PROMPT" fstab_line
  echo
  [[ "$fstab_line" != "nfs-server.example.com:/srv/nfs/shared  /mnt/nfs_shared  nfs  defaults  0  0" ]] && {
    print_error "Incorrect fstab entry."
    read -p "Press Enter..." _
    continue
  }
  echo

  echo "  Step 7: Test /etc/fstab safely."
  read -p "$PROMPT" cmd7
  echo
  [[ "$cmd7" != "sudo mount -a" && "$cmd7" != "mount -a" ]] && { print_error "Use: sudo mount -a"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 8: Verify persistent mount."
  read -p "$PROMPT" cmd8
  echo
  [[ "$cmd8" != "df -h /mnt/nfs_shared" ]] && { print_error "Use: df -h /mnt/nfs_shared"; read -p "Press Enter..." _; continue; }
  echo "Filesystem                             Size  Used Avail Use% Mounted on"
  echo "nfs-server.example.com:/srv/nfs/shared 100G  1.2G   99G   2% /mnt/nfs_shared"
  echo

  echo "  Step 9: Display active NFS mounts."
  read -p "$PROMPT" cmd9
  echo
  [[ "$cmd9" != "mount | grep nfs" ]] && { print_error "Use: mount | grep nfs"; read -p "Press Enter..." _; continue; }
  echo "nfs-server.example.com:/srv/nfs/shared on /mnt/nfs_shared type nfs (rw,relatime,vers=4.2,rsize=1048576,wsize=1048576)"
  echo

  echo "  Step 10: Unmount the NFS filesystem."
  read -p "$PROMPT" cmd10
  echo
  [[ "$cmd10" != "sudo umount /mnt/nfs_shared" ]] && { print_error "Use: sudo umount /mnt/nfs_shared"; read -p "Press Enter..." _; continue; }
  echo

  print_success "Outstanding."
  print_info "You successfully:"
  print_info "- mounted NFS temporarily"
  print_info "- configured persistent mounting via /etc/fstab"
  print_info "- tested safely using mount -a"
  print_info "- verified mount integrity"
  print_info "- cleanly unmounted the NFS filesystem"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "1) Retry"
  center_text "2) Return to menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done
