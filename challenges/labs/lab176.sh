#!/bin/bash

# Lab 176: GRUB Rescue → Normal Boot (set root/prefix, insmod normal, normal/configfile)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 176: GRUB Rescue → Normal Boot"
LAB_ID="lab176"
LAB_XP=50000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}
get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}
draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo; echo; echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: System dropped to 'grub rescue>' due to a bad prefix/boot path."
    center_text "Goal: Find the right partition, set root/prefix, load 'normal', and boot."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- In GRUB rescue mode ---
    draw_lab_ui
    echo "  You are at the minimal GRUB environment:"
    echo "  grub rescue> "
    echo

    echo "  Step 1: List available disks/partitions."
    read -p "  grub rescue> " cmd1
    echo
    if [[ "$cmd1" != "ls" ]]; then
        print_error "Incorrect. Try again. (Use: ls)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (hd0) (hd0,gpt1) (hd0,gpt2) (hd1) (hd1,gpt1)"
    echo

    echo "  Step 2: Probe a candidate partition (expect failure)."
    echo "          (Try listing the root of (hd0,gpt1).)"
    read -p "  grub rescue> " cmd2
    echo
    if [[ "$cmd2" != "ls (hd0,gpt1)/" ]]; then
        print_error "Incorrect. Try again. (Use: ls (hd0,gpt1)/ )"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Filesystem is unknown."
    echo

    echo "  Step 3: Probe the next partition and look for /boot/grub2."
    read -p "  grub rescue> " cmd3
    echo
    if [[ "$cmd3" != "ls (hd0,gpt2)/" ]]; then
        print_error "Incorrect. Try again. (Use: ls (hd0,gpt2)/ )"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ./  ../  boot/  etc/  lost+found/  usr/  var/"
    echo

    echo "  Step 4: Confirm GRUB assets exist."
    read -p "  grub rescue> " cmd4
    echo
    if [[ "$cmd4" != "ls (hd0,gpt2)/boot/grub2" && "$cmd4" != "ls (hd0,gpt2)/boot/grub2/" ]]; then
        print_error "Incorrect. Try again. (Use: ls (hd0,gpt2)/boot/grub2 )"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  grub.cfg  fonts/  locale/  themes/  x86_64-efi/  i386-pc/  modules/"
    echo

    echo "  Step 5: Set GRUB's root to the discovered partition."
    read -p "  grub rescue> " cmd5
    echo
    if [[ "$cmd5" != "set root=(hd0,gpt2)" ]]; then
        print_error "Incorrect. Try again. (Use: set root=(hd0,gpt2))"
        read -p "Press Enter to try again..." _
        continue
    fi
    # (no output on success)
    echo

    echo "  Step 6: Set the prefix to the GRUB directory."
    read -p "  grub rescue> " cmd6
    echo
    if [[ "$cmd6" != "set prefix=(hd0,gpt2)/boot/grub2" ]]; then
        print_error "Incorrect. Try again. (Use: set prefix=(hd0,gpt2)/boot/grub2)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # (no output on success)
    echo

    echo "  Step 7: Load the 'normal' module."
    read -p "  grub rescue> " cmd7
    echo
    if [[ "$cmd7" != "insmod normal" ]]; then
        print_error "Incorrect. Try again. (Use: insmod normal)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # (no output on success)
    echo

    echo "  Step 8: (Optional) Verify your variables."
    read -p "  grub rescue> " cmd8
    echo
    if [[ "$cmd8" != "set" ]]; then
        print_error "Incorrect. Try again. (Use: set)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  prefix=(hd0,gpt2)/boot/grub2"
    echo "  root=(hd0,gpt2)"
    echo

    echo "  Step 9: Switch from rescue to the full GRUB menu."
    read -p "  grub rescue> " cmd9
    echo
    if [[ "$cmd9" != "normal" ]]; then
        print_error "Incorrect. Try again. (Use: normal)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  GRUB menu loaded (simulated). Use arrow keys to select, Enter to boot."
    echo "  Example entries:"
    echo "    * Red Hat Enterprise Linux (KERNEL-<VERSION>)"
    echo "      Advanced options for Red Hat Enterprise Linux"
    echo

    echo "  Step 10: Practice the alternate method: open GRUB console and load the config directly."
    echo "           (First, open the GRUB command line.)"
    read -p "  grub> " cmd10
    echo
    if [[ "$cmd10" != "configfile (hd0,gpt2)/boot/grub2/grub.cfg" && "$cmd10" != "configfile (hd0,gpt2)/boot/grub2/grub.cfg " ]]; then
        print_error "Incorrect. Try again. (Use: configfile (hd0,gpt2)/boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loading configuration file..."
    echo "  GRUB menu reloaded (simulated)."
    echo

    echo "  Step 11: Boot the default entry."
    echo "           (Simulate by typing: Enter)"
    read -p "  grub menu> " cmd11
    echo
    if [[ "$cmd11" != "Enter" && "$cmd11" != "enter" ]]; then
        print_error "Incorrect. Try again. (Type: Enter)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loading Linux kernel ..."
    echo "  Loading initial ramdisk ..."
    echo "  Boot successful (simulated)."
    echo

    echo "  Step 12: (After boot) Optionally regenerate the GRUB config to prevent recurrence."
    read -p "  lab@lab176:~$ " cmd12
    echo
    if [[ "$cmd12" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-mkconfig -o /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-<KERNEL-VERSION>"
    echo "  Found initrd image: /boot/initramfs-<KERNEL-VERSION>.img"
    echo "  done"
    echo

    print_success "Nice work!"
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
