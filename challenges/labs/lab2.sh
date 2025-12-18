#!/bin/bash

# Lab 2: Real-Time Log Filter Setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 2: Real-Time Log Filter Setup"
LAB_ID="lab2"
LAB_XP=1650
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
    center_text "Your team wants to monitor critical system logs in real-time."
    center_text "You're tasked with writing a filter that watches for kernel panics,"
    center_text "failed logins, segmentation faults, and similar issues as they occur."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo
    
    echo "  Step 1: What command would you use to explore available system log files?"
    read -p "  lab@lpic-lab2:~$ " cmd1
    echo

    if [[ "$cmd1" != "ls /var/log" ]]; then
        print_error "Incorrect. Hint: Use 'ls' to list the contents of the log directory."
        read -p "  Press Enter to try again..." _
        continue
    fi


    echo "  alternatives.log  syslog  dmesg  messages  auth.log"

    echo
    echo "  Step 2: What command would you use to show only critical errors in real time?"
    read -p "  lab@lpic-lab2:~$ " cmd2
    echo

    if [[ "$cmd2" != "sudo tail -f /var/log/syslog | grep -Ei 'error|fail|panic|denied|segfault|crash'" && "$cmd2" != "sudo tail -f /var/log/messages | grep -Ei 'error|fail|panic|denied|segfault|crash'" ]]; then
        print_error "Close, but it must combine tail and grep with the right regex."
        read -p "  Press Enter to try again..." _
        continue
    fi

    echo "  Jul 16 08:11:17 kernel: [12345.678901] segfault at 00000000 ip 00007f3cd7e1d92c"
    echo "   sp 00007fff5ccfca60 error 4 in libc-2.27.so"
    echo "  Jul 16 08:11:20 sshd[1938]: Failed password for root from 192.168.1.42 port 55874 ssh2"
    echo "  Jul 16 08:11:22 kernel: panic: attempting to kill init!"
    echo "  Jul 16 08:11:23 audit[2001]: denied attempt to access /etc/shadow by uid 1000"
    echo "  Jul 16 08:11:25 systemd[1]: Failed to start Network Manager."
    echo "  Jul 16 08:11:26 gdm-password[1982]: gkr-pam: unable to locate daemon control file"
    echo "  Jul 16 08:11:27 systemd[1]: user@1000.service: Main process exited, code=exited," 
    echo "   status=1/FAILURE"
    echo "  Jul 16 08:11:28 kernel: device-mapper: thin: 253:1: reached low water mark"
    echo "  Jul 16 08:11:30 crash-handler[2042]: Process 1892 (firefox) crashed with signal 11 (SIGSEGV)"
    echo


    echo "  Step 3: What command would you use to inspect kernel-managed paths?"
    read -p "  lab@lpic-lab2:~$ " cmd3
    echo

    if [[ "$cmd3" != "ls /sys/module" && "$cmd3" != "ls /sys/kernel" ]]; then
        print_error "Incorrect. Hint: You're looking for locations commonly used to inspect kernel-managed features."
        read -p "  Press Enter to try again..." _
        continue
    fi

    if [[ "$cmd3" == "ls /sys/module" ]]; then
        echo "  8250             drm_kms_helper      intel_powerclamp  soundcore"
        echo "  acpi_cpufreq     e1000e              i915              serio_raw"
        echo "  ahci             crc32c_intel        input_core        rfkill"
    else
        echo "  debug            notes               printk            random"
        echo "  security         system              tracing           uevent_helper"
    fi

    echo
    print_success "Well done!"
    print_info "You've created a real-time log filter using tail and grep,"
    print_info "and identified key paths in /sys for kernel logging."
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
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
