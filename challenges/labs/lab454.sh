#!/bin/bash

# Lab 454: RHEL Storage Automation — script partitions 2x1GB disks and builds LVM
# Focus: bash scripting practice + non-interactive parted + LVM object creation
# Key skills: lsblk, parted -s, partprobe, pvcreate, vgcreate/vgextend, lvcreate, and verification (pvs/vgs/lvs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 454: Scripted LVM Build (parted + pvcreate)"
LAB_ID="lab454"
LAB_XP=45400
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
  # Normalize for comparison:
  # - strip trailing spaces
  # - remove blank lines at start/end
  # - preserve internal blank lines
  sed -e 's/[[:space:]]\+$//' | awk 'NR==1{first=NR} {lines[NR]=$0} END{
    # trim leading empty lines
    start=1
    while (start<=NR && lines[start]=="") start++
    # trim trailing empty lines
    end=NR
    while (end>=1 && lines[end]=="") end--
    for (i=start;i<=end;i++) print lines[i]
  }'
}

expected_script() {
  cat <<'EOF'
#!/bin/bash
set -euo pipefail

DISKS=("/dev/sdb" "/dev/sdc")
VG="vgscript"

for d in "${DISKS[@]}"; do
  parted -s "$d" mklabel gpt
  parted -s "$d" mkpart primary 1MiB 801MiB
  parted -s "$d" set 1 lvm on
done

partprobe "${DISKS[@]}"

pvcreate -y /dev/sdb1 /dev/sdc1

vgcreate "$VG" /dev/sdb1 /dev/sdc1

lvcreate -L 500M -n lvscript1 "$VG"
lvcreate -L 500M -n lvscript2 "$VG"
lvcreate -L 500M -n lvscript3 "$VG"
EOF
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "In VirtualBox Manager, present TWO 1GB virtual disks to server40 (power off first)."
  center_text "On server40, log in as user1 (has sudo)."
  echo
  center_text "Write ONE bash script at:"
  center_text "  /home/user1/vgscript_setup.sh"
  center_text "The script must:"
  center_text "- Partition /dev/sdb and /dev/sdc with one ~800MB partition each (parted -s)"
  center_text "- pvcreate both partitions"
  center_text "- Create VG 'vgscript' using both PVs"
  center_text "- Create 3x 500MB LVs: lvscript1, lvscript2, lvscript3"
  echo
  center_text "This lab will simulate editing by having you paste the ENTIRE script, then validating it."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify disks
  echo "  Step 1: Identify the two newly-attached 1GB disks."
  read -p "  lab@rhel-lab454:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINT" && "$cmd1" != "lsblk" && "$cmd1" != "sudo lsblk -o NAME,SIZE,TYPE,MOUNTPOINT" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   SIZE TYPE MOUNTPOINT"
  echo "  sda     30G disk"
  echo "  ├─sda1   1G part /boot"
  echo "  └─sda2  29G part"
  echo "  sdb      1G disk"
  echo "  sdc      1G disk"
  echo

  # STEP 2: Open editor command
  echo "  Step 2: Open the script for editing."
  read -p "  lab@rhel-lab454:~$ " cmd2
  echo
  if [[ "$cmd2" != "vim /home/user1/vgscript_setup.sh" && "$cmd2" != "nano /home/user1/vgscript_setup.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ==== editor opened ===="
  echo

  # STEP 3: Paste full script (simulated editor) and validate against expected
  echo "  Step 3: Paste the FULL script content now."
  echo "          When finished, type a single line containing: END"
  echo
  echo "          Tip: This is a strict check against the expected script (ignores trailing spaces"
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

  # Simulate saving the correct script
  echo "  script content validated"
  echo "  saved to /home/user1/vgscript_setup.sh"
  echo
  rm -f "$tmp" "$user_norm" "$exp_norm"

  # STEP 4: Make executable
  echo "  Step 4: Make the script executable."
  read -p "  lab@rhel-lab454:~$ " cmd4
  echo
  if [[ "$cmd4" != "chmod +x /home/user1/vgscript_setup.sh" && "$cmd4" != "chmod +x vgscript_setup.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 5: Run with sudo
  echo "  Step 5: Run your script with sudo."
  read -p "  lab@rhel-lab454:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo /home/user1/vgscript_setup.sh" && "$cmd5" != "sudo ./vgscript_setup.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Physical volume \"/dev/sdb1\" successfully created."
  echo "  Physical volume \"/dev/sdc1\" successfully created."
  echo "  Volume group \"vgscript\" successfully created"
  echo "  Logical volume \"lvscript1\" created."
  echo "  Logical volume \"lvscript2\" created."
  echo "  Logical volume \"lvscript3\" created."
  echo

  # STEP 6: Verify partitions
  echo "  Step 6: Verify each disk has an ~800MB partition."
  read -p "  lab@rhel-lab454:~$ " cmd6
  echo
  if [[ "$cmd6" != "lsblk -o NAME,SIZE,TYPE /dev/sdb /dev/sdc" && \
        "$cmd6" != "lsblk /dev/sdb /dev/sdc" && \
        "$cmd6" != "sudo lsblk -o NAME,SIZE,TYPE /dev/sdb /dev/sdc" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   SIZE TYPE"
  echo "  sdb      1G disk"
  echo "  └─sdb1  800M part"
  echo "  sdc      1G disk"
  echo "  └─sdc1  800M part"
  echo

  # STEP 7: Verify PVs/VG
  echo "  Step 7: Verify both partitions are PVs and belong to vgscript."
  read -p "  lab@rhel-lab454:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo pvs" && "$cmd7" != "sudo pvs -o pv_name,vg_name,pv_size --units m" && "$cmd7" != "sudo vgs vgscript" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd7" == "sudo vgs vgscript" ]]; then
    echo "  VG       #PV #LV #SN Attr   VSize    VFree"
    echo "  vgscript   2   3   0 wz--n- 1.56g    0.06g"
  else
    echo "  PV         VG       Fmt  Attr PSize    PFree"
    echo "  /dev/sdb1  vgscript lvm2 a--  800.00m  0.00m"
    echo "  /dev/sdc1  vgscript lvm2 a--  800.00m  60.00m"
  fi
  echo

  # STEP 8: Verify LVs
  echo "  Step 8: Verify lvscript1, lvscript2, lvscript3 exist and are 500MB each."
  read -p "  lab@rhel-lab454:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo lvs -o lv_name,vg_name,lv_size --units m vgscript" && \
        "$cmd8" != "sudo lvs vgscript" && \
        "$cmd8" != "sudo lvs /dev/vgscript" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  LV        VG       LSize"
  echo "  lvscript1 vgscript 500.00m"
  echo "  lvscript2 vgscript 500.00m"
  echo "  lvscript3 vgscript 500.00m"
  echo

  print_success "Great job."
  print_info "You simulated writing the entire script and it was validated against the expected solution."
  print_info "Then you verified the PVs/VG/LVs were created correctly."
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
