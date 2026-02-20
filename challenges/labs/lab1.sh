#!/bin/bash

# Lab 1: Identify Kernel Module in Use for a PCI Device (Expanded)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 1: RAID Controller Module Identification"
LAB_ID="lab1"
LAB_XP=3100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

# Initialize tracking file if missing
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
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
    center_text "You've installed a new RAID controller at PCI address 03:00.0."
    center_text "Opening the case voids the warranty, so you'll confirm details via CLI only."
    center_text "Your goal is to identify the driver in use, validate kernel module load,"
    center_text "check logs, and perform further inspection and diagnostics."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: List PCI devices to confirm the controller is visible."
    read -p "  lab@lpic-lab1:~$ " cmd1
    echo
    if [[ "$cmd1" != "lspci" ]]; then
        print_error "Incorrect. Run 'lspci' to list PCI devices."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma]"
    echo "  03:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS 2208 [Thunderbolt]"
    echo

    echo "  Step 2: What command would show the kernel module in use for 03:00.0?"
    read -p "  lab@lpic-lab1:~$ " cmd2
    echo
    if [[ "$cmd2" != "lspci -k -s 03:00.0" ]]; then
        print_error "Incorrect. Hint: Use 'lspci' with the -k and -s options."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  03:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS 2208"
    echo "  Kernel driver in use: megaraid_sas"
    echo "  Kernel modules: megaraid_sas"
    echo

    echo "  Step 3: What command would list the modules directory to confirm loading?"
    read -p "  lab@lpic-lab1:~$ " cmd3
    echo
    if [[ "$cmd3" != "ls /sys/bus/pci/drivers" && "$cmd3" != "ls /sys/module" ]]; then
        print_error "Incorrect. Hint: Kernel module info lives under /sys."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  megaraid_sas  ata_piix  uhci_hcd  ehci_pci  virtio_pci"
    echo

    echo "  Step 4: What command would show if the megaraid_sas module is loaded?"
    read -p "  lab@lpic-lab1:~$ " cmd4
    echo
    if [[ "$cmd4" != "lsmod | grep megaraid_sas" && "$cmd4" != "modinfo megaraid_sas" ]]; then
        print_error "Incorrect. Hint: Use lsmod or modinfo to check module presence."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    if [[ "$cmd4" == "lsmod | grep megaraid_sas" ]]; then
        echo "  megaraid_sas           53248  0"
    else
        echo "  filename:       /lib/modules/5.15.0-88-generic/kernel/drivers/scsi/megaraid/megaraid_sas.ko.xz"
        echo "  license:        GPL"
        echo "  description:    LSI Logic MegaRAID SAS Driver"
        echo "  author:         LSI Logic Corporation"
        echo "  version:        07.714.04.00"
        echo "  srcversion:     3C1F63BD2E93B5643B82791"
    fi
    echo

    echo "  Step 5: What command would display kernel log messages related to the RAID module?"
    read -p "  lab@lpic-lab1:~$ " cmd5
    echo
    if [[ "$cmd5" != "dmesg | grep megaraid" && "$cmd5" != "journalctl -k | grep megaraid" ]]; then
        print_error "Incorrect. Hint: Use dmesg or journalctl to review kernel logs."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  lab@lpic-lab1:~$ $cmd5"
    echo "  [   10.237842] megaraid_sas 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16"
    echo "  [   10.237955] megaraid_sas 0000:03:00.0: FW now in Ready state"
    echo "  [   10.238123] megaraid_sas 0000:03:00.0: Configured for polling"
    echo

    echo "  Step 6: What command shows all currently loaded kernel modules?"
    read -p "  lab@lpic-lab1:~$ " cmd6
    echo
    if [[ "$cmd6" != "lsmod" ]]; then
        print_error "Incorrect. Hint: It's a simple command with no options."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Module                  Size  Used by"
    echo "  megaraid_sas           53248  0"
    echo "  ata_piix               36864  0"
    echo "  virtio_pci             20480  0"
    echo

    echo "  Step 7: What command can you use to manually reload the megaraid_sas module?"
    read -p "  lab@lpic-lab1:~$ " cmd7
    echo
    if [[ "$cmd7" != "sudo modprobe -r megaraid_sas && sudo modprobe megaraid_sas" ]]; then
        print_error "Incorrect. Hint: Use modprobe to remove (-r) and re-add the module."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  [ OK ] megaraid_sas kernel module unloaded and reloaded successfully."
    echo

    print_success "Excellent work!"
    print_info "You identified, verified, inspected logs, and tested reloading the RAID module."
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
    read -p "  > " post_choice

    if [[ "$post_choice" == "2" ]]; then
        exit 0
    fi
done
