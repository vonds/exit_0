#!/bin/bash

# Lab 23: Package Integrity Enforcer – GPG and RPM/DPKG Verification

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 23: Package Integrity"
LAB_ID="lab23"
LAB_XP=22940
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

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "You're asked to verify the authenticity and integrity of a package file."
    center_text "This involves checking signatures, hashes, and metadata before installation."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command would you use to verify the GPG signature on rpm package 'vim.rpm'?"
    read -p "  lab@lpic-lab23:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "rpm --checksig vim.rpm" ]]; then
        print_error "Incorrect. Use rpm's signature check flag."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  vim.rpm: rsa sha1 (md5) pgp md5 OK"
    echo

    echo "  Step 2: What command shows detailed signature and file info for the rpm?"
    read -p "  lab@lpic-lab23:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "rpm -Kv vim.rpm" ]]; then
        print_error "Incorrect. Use -Kv to verify both signature and digest."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  vim.rpm: rsa sha1 md5 OK"
    echo

    echo "  Step 3: What would you use to verify the MD5 checksum of a Debian .deb file?"
    read -p "  lab@lpic-lab23:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "dpkg-deb --info vim.deb" ]]; then
        print_error "Incorrect. Use dpkg-deb to inspect .deb metadata and control info."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  new debian package, version 2.0."
    echo "   size 456789 bytes: control archive=12345 bytes."
    echo "   MD5Sum: 1a2b3c... vim.deb"
    echo

    echo "  Step 4: What file typically holds trusted GPG public keys on a Debian system?"
    read -p "  lab@lpic-lab23:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "/etc/apt/trusted.gpg" && "$cmd4" != "/etc/apt/trusted.gpg.d/" ]]; then
        print_error "Incorrect. Look in /etc/apt for GPG trust stores."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Found: /etc/apt/trusted.gpg and /etc/apt/trusted.gpg.d/"
    echo

    echo "  Step 5: What command would you use to import a new GPG key for RPM-based systems?"
    read -p "  lab@lpic-lab23:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "rpm --import /path/to/RPM-GPG-KEY" ]]; then
        print_error "Incorrect. rpm --import is required for trusted key use."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  GPG key imported successfully."
    echo

    print_success "Great job!"
    print_info "You earned $LAB_XP XP for completing this lab!"
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

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
