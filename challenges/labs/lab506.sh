#!/bin/bash

# Lab 506: Extend Existing Logical Volumes (Non-Destructive)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 506: Extend Existing Logical Volumes"
LAB_ID="lab506"
LAB_XP=50600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab506:~$ "

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
  center_text "The logical volume /dev/vg_data/lv_data is running out of space."
  center_text "You must safely extend it and resize the filesystem without data loss."
  echo
  center_text "Targets:"
  center_text "- Volume Group: vg_data"
  center_text "- Logical Volume: lv_data"
  center_text "- Mount Point: /mnt/data"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Check available free space in the volume group."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "vgs vg_data" && "$cmd1" != "sudo vgs vg_data" ]]; then
    print_error "Incorrect. Use: vgs vg_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  VG       #PV #LV #SN Attr   VSize   VFree"
  echo "  vg_data    1   1   0 wz--n- 40.00g  20.00g"
  echo

  echo "  Step 2: Extend the logical volume by 5GB."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo lvextend -L +5G /dev/vg_data/lv_data" ]]; then
    print_error "Incorrect. Use: sudo lvextend -L +5G /dev/vg_data/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Size of logical volume vg_data/lv_data changed from 15.00 GiB to 20.00 GiB."
  echo "  Logical volume lv_data successfully resized."
  echo

  echo "  Step 3: Resize the ext4 filesystem to use the new space."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo resize2fs /dev/vg_data/lv_data" ]]; then
    print_error "Incorrect. Use: sudo resize2fs /dev/vg_data/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "resize2fs 1.46.5 (30-Dec-2021)"
  echo "Filesystem at /dev/vg_data/lv_data is mounted on /mnt/data; on-line resizing required"
  echo "The filesystem on /dev/vg_data/lv_data is now 5242880 (4k) blocks long."
  echo

  echo "  Step 4: Verify the new logical volume size."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "lvs /dev/vg_data/lv_data" && "$cmd4" != "sudo lvs /dev/vg_data/lv_data" ]]; then
    print_error "Incorrect. Use: lvs /dev/vg_data/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  LV      VG      Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lv_data vg_data -wi-ao---- 20.00g"
  echo

  echo "  Step 5: Verify the filesystem size."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "df -h /mnt/data" ]]; then
    print_error "Incorrect. Use: df -h /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Filesystem                      Size  Used Avail Use% Mounted on"
  echo "/dev/mapper/vg_data-lv_data      20G  2.0G   18G  10% /mnt/data"
  echo

  echo "  Step 6: Extend the logical volume to use all remaining free space."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo lvextend -l +100%FREE /dev/vg_data/lv_data" ]]; then
    print_error "Incorrect. Use: sudo lvextend -l +100%FREE /dev/vg_data/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Size of logical volume vg_data/lv_data changed from 20.00 GiB to 40.00 GiB."
  echo "  Logical volume lv_data successfully resized."
  echo

  echo "  Step 7: Resize the filesystem again."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo resize2fs /dev/vg_data/lv_data" ]]; then
    print_error "Incorrect. Use: sudo resize2fs /dev/vg_data/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "resize2fs 1.46.5 (30-Dec-2021)"
  echo "Filesystem at /dev/vg_data/lv_data is mounted on /mnt/data; on-line resizing required"
  echo "The filesystem on /dev/vg_data/lv_data is now 10485760 (4k) blocks long."
  echo

  echo "  Step 8: Confirm the final filesystem size."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "df -h /mnt/data" ]]; then
    print_error "Incorrect. Use: df -h /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Filesystem                      Size  Used Avail Use% Mounted on"
  echo "/dev/mapper/vg_data-lv_data      40G  2.1G   38G   6% /mnt/data"
  echo

  print_success "Outstanding work."
  print_info "You successfully:"
  print_info "- verified VG free space"
  print_info "- extended a logical volume"
  print_info "- resized the filesystem online"
  print_info "- validated the changes"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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
