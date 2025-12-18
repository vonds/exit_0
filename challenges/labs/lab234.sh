#!/bin/bash

# Lab 234: Configure DNF/YUM repos from an ISO (BaseOS + AppStream) (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real mounts or repo files are changed. A simulated ISO and repo config are used.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 234: Local Repos from ISO (BaseOS + AppStream)"
LAB_ID="lab234"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated artifacts (do not exist on your system)
ISO_PATH="/tmp/rhel-8-dvd.iso"
MNT="/mnt/rhel8"
BASE_REPO="/etc/yum.repos.d/local-BaseOS.repo"
APP_REPO="/etc/yum.repos.d/local-AppStream.repo"

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
  center_text "Goal: Mount an installation ISO at $MNT and configure two local DNF/YUM repos:"
  center_text "       BaseOS → file://$MNT/BaseOS   and   AppStream → file://$MNT/AppStream."
  center_text "Verify with dnf/yum that both repos are enabled and list packages."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify the ISO file (simulated)
  draw_lab_ui
  echo "  Step 1: Confirm the ISO image is present."
  read -p "  lab@lab234:~$ " cmd1
  [[ "$cmd1" != "ls -lh /tmp/rhel-8-dvd.iso" ]] && {
    print_error "Hint: List the ISO at $ISO_PATH (long format)."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "-rw-r--r-- 1 root root 8.0G Jul 22 12:00 /tmp/rhel-8-dvd.iso"
  echo

  # Step 2: Create the mount point
  echo "  Step 2: Create the mount directory."
  read -p "  lab@lab234:~$ " cmd2
  if [[ "$cmd2" != "sudo mkdir -p /mnt/rhel8" && "$cmd2" != "mkdir -p /mnt/rhel8" ]]; then
    print_error "Hint: Make the directory $MNT."
    read -p "Press Enter to try again..." _
    continue
  fi
  # (mkdir is silent)
  echo

  # Step 3: Mount the ISO loopback (simulated)
  echo "  Step 3: Mount the ISO at $MNT using loopback."
  read -p "  lab@lab234:~$ " cmd3
  if [[ "$cmd3" == "sudo mount -o loop /tmp/rhel-8-dvd.iso /mnt/rhel8" || "$cmd3" == "mount -o loop /tmp/rhel-8-dvd.iso /mnt/rhel8" || "$cmd3" == "sudo mount -o loop -t iso9660 /tmp/rhel-8-dvd.iso /mnt/rhel8" ]]; then
    # (mount success is silent)
    :
  else
    print_error "Hint: Use mount -o loop … ${ISO_PATH} ${MNT}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify expected trees exist on the mounted ISO
  echo "  Step 4: List top-level directories on the mounted ISO."
  read -p "  lab@lab234:~$ " cmd4
  [[ "$cmd4" != "ls -1 /mnt/rhel8" && "$cmd4" != "ls /mnt/rhel8" ]] && {
    print_error "Hint: List $MNT to see BaseOS and AppStream."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "AppStream"
  echo "BaseOS"
  echo "EFI"
  echo "images"
  echo "isolinux"
  echo "repodata"
  echo "TRANS.TBL"
  echo

  # Step 5: Create local BaseOS repo file (simulated)
  echo "  Step 5: Create a YUM/DNF repo file for BaseOS pointing to file://$MNT/BaseOS."
  read -p "  lab@lab234:~$ " cmd5
  if [[ "$cmd5" =~ (tee|cat|echo|printf) && "$cmd5" =~ local-BaseOS\.repo && "$cmd5" =~ (BaseOS|baseurl=.*BaseOS) ]]; then
    echo "[local-BaseOS]"
    echo "name=Local BaseOS"
    echo "baseurl=file:///mnt/rhel8/BaseOS"
    echo "enabled=1"
    echo "gpgcheck=0"
  else
    print_error "Hint: Write a repo stanza [local-BaseOS] with baseurl=file:///mnt/rhel8/BaseOS (enabled=1, gpgcheck=0)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Create local AppStream repo file (simulated)
  echo "  Step 6: Create a repo file for AppStream pointing to file://$MNT/AppStream."
  read -p "  lab@lab234:~$ " cmd6
  if [[ "$cmd6" =~ (tee|cat|echo|printf) && "$cmd6" =~ local-AppStream\.repo && "$cmd6" =~ (AppStream|baseurl=.*AppStream) ]]; then
    echo "[local-AppStream]"
    echo "name=Local AppStream"
    echo "baseurl=file:///mnt/rhel8/AppStream"
    echo "enabled=1"
    echo "gpgcheck=0"
  else
    print_error "Hint: Write a repo stanza [local-AppStream] with baseurl=file:///mnt/rhel8/AppStream (enabled=1, gpgcheck=0)."
    read -p "Press Enter to try again..." _
    continue
