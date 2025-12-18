#!/bin/bash

# Lab 235: Verify RPM signature, install/remove a package (dcraw) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real keys, packages, or repos are modified. All outputs are simulated.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 235: RPM Signatures + Install/Remove (dcraw)"
LAB_ID="lab235"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PKG="dcraw"
RPM="/tmp/dcraw-9.28-1.el8.x86_64.rpm"
GPG="/tmp/RPM-GPG-KEY-lab235"
KEYID="8fdb98ab"

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
  center_text "Goal: Verify an RPM signature for ${PKG}, import the signing key, verify again,"
  center_text "then install the RPM and remove it cleanly. All actions are simulated."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm the RPM file exists (simulated)
  draw_lab_ui
  echo "  Step 1: List the RPM to verify its presence and size."
  read -p "  lab@lab235:~$ " cmd1
  [[ "$cmd1" != "ls -lh $RPM" ]] && {
    print_error "Hint: List the exact path $RPM in long format."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  -rw-r--r-- 1 root root 120K Jul 22 12:34 $RPM"
  echo

  # Step 2: Check the RPM signature BEFORE importing the key (should show NOKEY)
  echo "  Step 2: Verify the RPM signature (expect NOKEY before import)."
  read -p "  lab@lab235:~$ " cmd2
  if [[ "$cmd2" == "rpm -K $RPM" || "$cmd2" == "rpm --checksig $RPM" ]]; then
    echo "  $(basename "$RPM"): digests signatures OK"
    echo "  $(basename "$RPM"): Header V4 RSA/SHA256 Signature, key ID $KEYID: NOKEY"
    echo "  $(basename "$RPM"): V4 RSA/SHA256 Signature, key ID $KEYID: NOKEY"
  elif [[ "$cmd2" == "rpm -Kvv $RPM" || "$cmd2" == "rpm --checksig --verbose $RPM" ]]; then
    echo "  Verifying... $(basename "$RPM")"
    echo "  Header V4 RSA/SHA256 Signature, key ID $KEYID: NOKEY"
    echo "  V4 RSA/SHA256 Signature, key ID $KEYID: NOKEY"
  else
    print_error "Hint: Use rpm -K (or rpm --checksig) against $RPM."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Import the GPG key used to sign the RPM (simulated)
  echo "  Step 3: Import the GPG key for this package."
  read -p "  lab@lab235:~$ " cmd3
  if [[ "$cmd3" == "rpm --import $GPG" || "$cmd3" == "sudo rpm --import $GPG" ]]; then
    :
  else
    print_error "Hint: Use rpm --import <key-file> (simulated key: $GPG)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify the RPM signature again (should be OK)
  echo "  Step 4: Re-check the RPM signature (should be OK now)."
  read -p "  lab@lab235:~$ " cmd4
  if [[ "$cmd4" == "rpm -K $RPM" || "$cmd4" == "rpm --checksig $RPM" ]]; then
    echo "  $(basename "$RPM"): digests signatures OK"
    echo "  $(basename "$RPM"): Header V4 RSA/SHA256 Signature, key ID $KEYID: OK"
    echo "  $(basename "$RPM"): V4 RSA/SHA256 Signature, key ID $KEYID: OK"
  elif [[ "$cmd4" == "rpm -Kvv $RPM" || "$cmd4" == "rpm --checksig --verbose $RPM" ]]; then
    echo "  Verifying... $(basename "$RPM")"
    echo "  Header V4 RSA/SHA256 Signature, key ID $KEYID: OK"
    echo "  V4 RSA/SHA256 Signature, key ID $KEYID: OK"
  else
    print_error "Hint: Use rpm -K (or rpm --checksig) again on $RPM."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Install the package (accept dnf/yum or rpm -Uvh)
  echo "  Step 5: Install the RPM package."
  read -p "  lab@lab235:~$ " cmd5
  if [[ "$cmd5" == "sudo dnf install -y $RPM" || "$cmd5" == "dnf install -y $RPM" ]]; then
    echo "  Last metadata expiration check: 0:02:03 ago on Tue 22 Jul 2025 12:32:37 PM UTC."
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package  Arch     Version            Repository   Size"
    echo "  ================================================================================"
    echo "  Installing:"
    echo "   $PKG     x86_64   9.28-1.el8         @commandline 120 k"
    echo
    echo "  Installed:"
    echo "    $PKG-9.28-1.el8.x86_64"
  elif [[ "$cmd5" == "sudo yum install -y $RPM" || "$cmd5" == "yum install -y $RPM" ]]; then
    echo "  Examining $RPM: $PKG-9.28-1.el8.x86_64"
    echo "  Marking $PKG-9.28-1.el8.x86_64 to be installed"
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  --> Finished Dependency Resolution"
    echo "  Installed: $PKG.x86_64 9.28-1.el8"
  elif [[ "$cmd5" == "sudo rpm -Uvh $RPM" || "$cmd5" == "rpm -Uvh $RPM" ]]; then
    echo "  Preparing...                          ################################# [100%]"
    echo "  Updating / Installing..."
    echo "     1:$PKG-9.28-1.el8                  ################################# [100%]"
  else
    print_error "Hint: Use dnf/yum install <path-to-rpm> or rpm -Uvh <rpm>."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Verify installation details
  echo "  Step 6: Query package information to confirm install."
  read -p "  lab@lab235:~$ " cmd6
  if [[ "$cmd6" == "rpm -qi $PKG" ]]; then
    echo "  Name        : $PKG"
    echo "  Version     : 9.28"
    echo "  Release     : 1.el8"
    echo "  Architecture: x86_64"
    echo "  Install Date: Tue 22 Jul 2025 12:36:10 PM UTC"
    echo "  Group       : Applications/Multimedia"
    echo "  Size        : 245632"
    echo "  License     : GPLv2"
    echo "  Signature   : RSA/SHA256, Tue 22 Jul 2025 12:00:00 PM UTC, Key ID $KEYID"
    echo "  Source RPM  : ${PKG}-9.28-1.el8.src.rpm"
    echo "  Summary     : Decode raw images from digital cameras"
    echo "  Description :"
    echo "  dcraw is a utility to read raw image formats from digital cameras."
  elif [[ "$cmd6" == "rpm -q $PKG" ]]; then
    echo "  $PKG-9.28-1.el8.x86_64"
  else
    print_error "Hint: Use rpm -qi dcraw (or rpm -q dcraw) to verify."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Remove the package
  echo "  Step 7: Remove the package cleanly."
  read -p "  lab@lab235:~$ " cmd7
  if [[ "$cmd7" == "sudo dnf remove -y $PKG" || "$cmd7" == "dnf remove -y $PKG" ]]; then
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package  Arch     Version            Repository   Size"
    echo "  ================================================================================"
    echo "  Removing:"
    echo "   $PKG     x86_64   9.28-1.el8         @commandline 120 k"
    echo
    echo "  Removed:"
    echo "    $PKG-9.28-1.el8.x86_64"
  elif [[ "$cmd7" == "sudo yum remove -y $PKG" || "$cmd7" == "yum remove -y $PKG" ]]; then
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  --> Finished Dependency Resolution"
    echo "  Removed: $PKG.x86_64 9.28-1.el8"
  elif [[ "$cmd7" == "sudo rpm -e $PKG" || "$cmd7" == "rpm -e $PKG" ]]; then
    :
  else
    print_error "Hint: Use dnf/yum remove dcraw or rpm -e dcraw."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 8: Confirm removal
  echo "  Step 8: Confirm the package is no longer installed."
  read -p "  lab@lab235:~$ " cmd8
  if [[ "$cmd8" == "rpm -q $PKG" ]]; then
    echo "  package $PKG is not installed"
  else
    print_error "Hint: Use rpm -q dcraw to verify it’s gone."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You verified an RPM signature, imported the key, installed $PKG, and removed it (simulated)."
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
