#!/bin/bash

# Lab 183: Recover from a Bad Kernel — Boot Older Kernel & Set It as Default (grubby)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 183: Recover from a Bad Kernel — Boot Older Kernel & Set It as Default"
LAB_ID="lab183"
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
    center_text "Scenario: The newest kernel fails to boot. You must boot an older kernel, make it default,"
    center_text "then optionally remove the bad kernel so it won't be selected again."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- Simulate choosing an older kernel from GRUB Advanced options ---
    draw_lab_ui
    echo "  GRUB menu (simulated)."
    echo "    Red Hat Enterprise Linux (KERNEL-<BAD-VERSION>)"
    echo "    Advanced options for Red Hat Enterprise Linux  →"
    echo

    echo "  Step 1: Open 'Advanced options for Red Hat Enterprise Linux'."
    echo "          (Simulate selection by typing: Enter)"
    read -p "  grub menu> " cmd1
    echo
    if [[ "$cmd1" != "Enter" && "$cmd1" != "enter" ]]; then
        print_error "Incorrect. Try again. (Type: Enter)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Advanced options opened (simulated)."
    echo "    * Red Hat Enterprise Linux (KERNEL-<GOOD-VERSION>)"
    echo "      Red Hat Enterprise Linux (KERNEL-<BAD-VERSION>)"
    echo

    echo "  Step 2: Select the older, known-good kernel entry."
    echo "          (Simulate selection by typing: Enter)"
    read -p "  grub advanced> " cmd2
    echo
    if [[ "$cmd2" != "Enter" && "$cmd2" != "enter" ]]; then
        print_error "Incorrect. Try again. (Type: Enter)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loading Linux kernel (KERNEL-<GOOD-VERSION>) ..."
    echo "  Loading initial ramdisk ..."
    echo "  Boot successful (simulated)."
    echo

    # --- In the running system: verify kernel, set good kernel as default with grubby ---
    echo "  Step 3: Verify the currently running kernel version."
    read -p "  lab@lab183:~$ " cmd3
    echo
    if [[ "$cmd3" != "uname -r" ]]; then
        print_error "Incorrect. Try again. (Use: uname -r)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  <GOOD-VERSION>"
    echo

    echo "  Step 4: List installed kernel packages."
    read -p "  lab@lab183:~$ " cmd4
    echo
    if [[ "$cmd4" != "rpm -q kernel" ]]; then
        print_error "Incorrect. Try again. (Use: rpm -q kernel)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  kernel-<GOOD-VERSION>"
    echo "  kernel-<BAD-VERSION>"
    echo

    echo "  Step 5: Show the current default kernel path."
    read -p "  lab@lab183:~$ " cmd5
    echo
    if [[ "$cmd5" != "grubby --default-kernel" ]]; then
        print_error "Incorrect. Try again. (Use: grubby --default-kernel)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /boot/vmlinuz-<BAD-VERSION>"
    echo

    echo "  Step 6: Inspect all kernel entries known to grubby (truncated)."
    read -p "  lab@lab183:~$ " cmd6
    echo
    if [[ "$cmd6" != "grubby --info=ALL" ]]; then
        print_error "Incorrect. Try again. (Use: grubby --info=ALL)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  index=0"
    echo "  kernel=\"/boot/vmlinuz-<BAD-VERSION>\""
    echo "  initrd=\"/boot/initramfs-<BAD-VERSION>.img\""
    echo "  title=\"Red Hat Enterprise Linux (<BAD-VERSION>)\""
    echo "  index=1"
    echo "  kernel=\"/boot/vmlinuz-<GOOD-VERSION>\""
    echo "  initrd=\"/boot/initramfs-<GOOD-VERSION>.img\""
    echo "  title=\"Red Hat Enterprise Linux (<GOOD-VERSION>)\""
    echo

    echo "  Step 7: Set the known-good kernel as the default for future boots."
    read -p "  lab@lab183:~$ " cmd7
    echo
    if [[ "$cmd7" != "grubby --set-default /boot/vmlinuz-<GOOD-VERSION>" ]]; then
        print_error "Incorrect. Try again. (Use: grubby --set-default /boot/vmlinuz-<GOOD-VERSION>)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # (no output on success)
    echo

    echo "  Step 8: Verify the default kernel changed."
    read -p "  lab@lab183:~$ " cmd8
    echo
    if [[ "$cmd8" != "grubby --default-kernel" ]]; then
        print_error "Incorrect. Try again. (Use: grubby --default-kernel)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /boot/vmlinuz-<GOOD-VERSION>"
    echo

    echo "  Step 9: (Optional) Regenerate GRUB configuration file."
    read -p "  lab@lab183:~$ " cmd9
    echo
    if [[ "$cmd9" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-mkconfig -o /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-<GOOD-VERSION>"
    echo "  Found initrd image: /boot/initramfs-<GOOD-VERSION>.img"
    echo "  Found linux image: /boot/vmlinuz-<BAD-VERSION>"
    echo "  Found initrd image: /boot/initramfs-<BAD-VERSION>.img"
    echo "  done"
    echo

    echo "  Step 10: (Optional) Remove the bad kernel package to prevent accidental use."
    read -p "  lab@lab183:~$ " cmd10
    echo
    if [[ "$cmd10" != "dnf remove kernel-<BAD-VERSION>" && "$cmd10" != "yum remove kernel-<BAD-VERSION>" ]]; then
        print_error "Incorrect. Try again. (Use: dnf remove kernel-<BAD-VERSION>)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Dependencies resolved."
    echo "  ================================================================="
    echo "   Removing: kernel-<BAD-VERSION>"
    echo "  ================================================================="
    echo "  Is this ok [y/N]:"
    echo

    echo "  Step 11: Confirm only the good kernel remains installed."
    read -p "  lab@lab183:~$ " cmd11
    echo
    if [[ "$cmd11" != "rpm -q kernel" ]]; then
        print_error "Incorrect. Try again. (Use: rpm -q kernel)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  kernel-<GOOD-VERSION>"
    echo

    echo "  Step 12: Reboot to validate that the system now boots the good kernel by default."
    read -p "  lab@lab183:~$ " cmd12
    echo
    if [[ "$cmd12" != "reboot" && "$cmd12" != "reboot -f" ]]; then
        print_error "Incorrect. Try again. (Use: reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated)."
    echo "  GRUB selects default kernel: /boot/vmlinuz-<GOOD-VERSION> (simulated)."
    echo "  System boot successful."
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
