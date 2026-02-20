#!/bin/bash

# Lab 7: Inspect and Load Kernel Modules on Demand

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 7: Inspect and Load Kernel Modules on Demand"
LAB_ID="lab7"
LAB_XP=2564
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
    center_text "A USB device isn't working and may be missing a kernel module."
    center_text "You’ve been asked to investigate, load the correct module,"
    center_text "verify it's active, and configure it to load on every boot."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: lsmod command (interactive)
    echo "  Step 1: What command lists all currently loaded kernel modules?"
    read -p "  lab@lpic-lab7:~$ " cmd_lsmod
    echo

    if [[ "$cmd_lsmod" != "lsmod" ]]; then
        print_error "Incorrect. Use the basic command to list modules."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Module                  Size  Used by"
    echo "  xhci_pci               20480  0"
    echo "  usbcore               294912  3 xhci_pci,ehci_hcd,usb_common"
    echo

    # Step 2: modinfo usb_storage
    echo "  Step 2: What command would show module info for 'usb_storage'?"
    read -p "  lab@lpic-lab7:~$ " cmd1
    echo

    if [[ "$cmd1" != "modinfo usb_storage" ]]; then
        print_error "Incorrect. Hint: Use modinfo on the suspected module name."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  filename:       /lib/modules/5.15.0-88-generic/kernel/drivers/usb/storage/usb-storage.ko"
    echo "  description:    USB Mass Storage driver for Linux"
    echo "  license:        GPL"
    echo "  alias:          usb:v*p*d*dc*dsc*dp*ic08isc06ip50in*"
    echo

    # Step 3: Load module
    echo "  Step 3: What command loads the usb_storage module immediately?"
    read -p "  lab@lpic-lab7:~$ " cmd2
    echo

    if [[ "$cmd2" != "sudo modprobe usb_storage" ]]; then
        print_error "Incorrect. Hint: Use modprobe with elevated permissions."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo

    # Step 4: Verify module is loaded
    echo "  Step 4: What command verifies that the module is loaded?"
    read -p "  lab@lpic-lab7:~$ " cmd3
    echo

    if [[ "$cmd3" != "lsmod | grep usb_storage" ]]; then
        print_error "Incorrect. Hint: Use lsmod and filter with grep."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  usb_storage           69632  0"
    echo

    # Step 5: Kernel modules directory
    echo "  Step 5: What directory contains all modules for this kernel version?"
    read -p "  lab@lpic-lab7:~$ " cmd4
    echo

    if [[ "$cmd4" != "ls /lib/modules/5.15.0-88-generic/" ]]; then
        print_error "Incorrect. Hint: Use ls on the directory matching the kernel version."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  kernel/  modules.alias  modules.dep  modules.softdep  updates/"
    echo

    # Step 6: Autoload on boot
    echo "  Step 6: What file would you add usb_storage to for auto-loading on boot?"
    read -p "  lab@lpic-lab7:~$ " cmd5
    echo

    if [[ "$cmd5" != "echo usb_storage | sudo tee /etc/modules-load.d/usb.conf" ]]; then
        print_error "Incorrect. Hint: Use tee to write into a file inside /etc/modules-load.d/"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  usb_storage"
    echo

    print_success "Well done!"
    print_info "You verified loaded modules, inspected usb_storage details,"
    print_info "loaded it manually, and configured it to persist on boot."
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
