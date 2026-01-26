#!/bin/bash

# Lab 455: RHEL Storage Automation — create filesystems on LVs and mount them

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 455: Make Filesystems + Mount LVs (xfs/ext4/vfat)"
LAB_ID="lab455"
LAB_XP=45500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
}

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

normalize_script() {
  sed -e 's/[[:space:]]\+$//' | awk 'NR==1{first=NR} {lines[NR]=$0} END{
    start=1
    while (start<=NR && lines[start]=="") start++
    end=NR
    while (end>=1 && lines[end]=="") end--
    for (i=start;i<=end;i++) print lines[i]
  }'
}

expected_script() {
  cat <<'EOF'
#!/bin/bash
set -euo pipefail

VG="vgscript"

XFS_LV="/dev/${VG}/lvscript1"
EXT4_LV="/dev/${VG}/lvscript2"
VFAT_LV="/dev/${VG}/lvscript3"

mkdir -p /mnt/xfs /mnt/ext4 /mnt/vfat

mkfs.xfs -f "$XFS_LV"
mkfs.ext4 -F "$EXT4_LV"
mkfs.vfat -F 32 "$VFAT_LV"

mount "$XFS_LV" /mnt/xfs
mount "$EXT4_LV" /mnt/ext4
mount "$VFAT_LV" /mnt/vfat

df -h | grep -E '/mnt/(xfs|ext4|vfat)'
EOF
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "Continuation of Lab 454. You already have VG 'vgscript' with LVs:"
  center_text "  lvscript1, lvscript2, lvscript3"
  echo
  center_text "Write ONE bash script that:"
  center_text "1) Creates filesystems:"
  center_text "   - lvscript1 -> XFS"
  center_text "   - lvscript2 -> EXT4"
  center_text "   - lvscript3 -> VFAT"
  center_text "2) Creates mount points:"
  center_text "   /mnt/xfs, /mnt/ext4, /mnt/vfat"
  center_text "3) Mounts them"
  center_text "4) Runs: df -h to list the mounted filesystems (in the script)"
  echo
  center_text "This lab simulates editing by having you paste the ENTIRE script, then validating it."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm the LVs exist
  echo "  Step 1: Confirm the logical volumes exist from Lab 454."
  read -p "  lab@rhel-lab455:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo lvs vgscript" && \
        "$cmd1" != "sudo lvs -o lv_name,vg_name,lv_size --units m vgscript" && \
        "$cmd1" != "lvs vgscript" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  LV        VG       LSize"
  echo "  lvscript1 vgscript 500.00m"
  echo "  lvscript2 vgscript 500.00m"
  echo "  lvscript3 vgscript 500.00m"
  echo

  # STEP 2: Open editor
  echo "  Step 2: Open the new script for editing: /home/user1/vgscript_fs_mount.sh"
  read -p "  lab@rhel-lab455:~$ " cmd2
  echo
  if [[ "$cmd2" != "vim /home/user1/vgscript_fs_mount.sh" && "$cmd2" != "nano /home/user1/vgscript_fs_mount.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 3: Paste full script and validate
  echo "  Step 3: Paste the FULL script content now."
  echo "          When finished, type a single line containing: END"
  echo
  echo "          Note: This is a strict check against the expected script (ignores trailing spaces"
  echo "          and leading/trailing blank lines, but otherwise must match)."
  echo

  tmp="$(mktemp)"
  while IFS= read -r line; do
    [[ "$line" == "END" ]] && break
    printf '%s\n' "$line" >> "$tmp"
  done
  echo

  user_norm="$(mktemp)"
  exp_norm="$(mktemp)"
  normalize_script < "$tmp" > "$user_norm"
  expected_script | normalize_script > "$exp_norm"

  if ! diff -u "$exp_norm" "$user_norm" >/dev/null 2>&1; then
    print_error "Script validation failed."
    echo
    print_info "Expected script:"
    echo
    expected_script
    echo
    print_info "Fix your script and try again."
    echo
    read -p "Press Enter to restart the lab..." _
    rm -f "$tmp" "$user_norm" "$exp_norm"
    continue
  fi

  echo "  (script content validated)"
  echo "  (saved to /home/user1/vgscript_fs_mount.sh)"
  echo
  rm -f "$tmp" "$user_norm" "$exp_norm"

  # STEP 4: Make executable
  echo "  Step 4: Make the script executable."
  read -p "  lab@rhel-lab455:~$ " cmd4
  echo
  if [[ "$cmd4" != "chmod +x /home/user1/vgscript_fs_mount.sh" && "$cmd4" != "chmod +x vgscript_fs_mount.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 5: Run script with sudo
  echo "  Step 5: Run your script with sudo."
  read -p "  lab@rhel-lab455:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo /home/user1/vgscript_fs_mount.sh" && "$cmd5" != "sudo ./vgscript_fs_mount.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/vgscript/lvscript1 isize=512    agcount=4, agsize=32000 blks"
  echo "  Creating filesystem with 128000 4k blocks and 128000 inodes"
  echo "  Filesystem UUID: 8b1f0b7c-5b12-4c2c-9f7a-0e9f9d3b2a11"
  echo "  mkfs.fat 4.2 (2021-01-31)"
  echo "  /dev/vgscript/lvscript1 mounted on /mnt/xfs"
  echo "  /dev/vgscript/lvscript2 mounted on /mnt/ext4"
  echo "  /dev/vgscript/lvscript3 mounted on /mnt/vfat"
  echo "  Filesystem                    Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/vgscript-lvscript1  496M   33M  464M   7% /mnt/xfs"
  echo "  /dev/mapper/vgscript-lvscript2  472M   24K  444M   1% /mnt/ext4"
  echo "  /dev/mapper/vgscript-lvscript3  496M  4.0K  496M   1% /mnt/vfat"
  echo

  # STEP 6: Verify mounts (df -h)
  echo "  Step 6: Verify the filesystems are mounted using df -h."
  read -p "  lab@rhel-lab455:~$ " cmd6
  echo
  if [[ "$cmd6" != "df -h | grep -E '/mnt/(xfs|ext4|vfat)'" && \
        "$cmd6" != "df -h | grep -E \"/mnt/(xfs|ext4|vfat)\"" && \
        "$cmd6" != "mount | grep /mnt" && \
        "$cmd6" != "lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/mapper/vgscript-lvscript1  496M   33M  464M   7% /mnt/xfs"
  echo "  /dev/mapper/vgscript-lvscript2  472M   24K  444M   1% /mnt/ext4"
  echo "  /dev/mapper/vgscript-lvscript3  496M  4.0K  496M   1% /mnt/vfat"
  echo

  print_success "Great job."
  print_info "You wrote a script that formatted LVs with xfs/ext4/vfat, created mount points,"
  print_info "mounted them, and used df -h to verify the mounts."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
