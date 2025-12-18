#!/bin/bash

# Lab 45: System Monitoring Commands

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 45: System Monitoring Commands"
LAB_ID="lab45"
LAB_XP=17700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
    center_text "A user has reported degraded performance on your server."
    center_text "As the sysadmin, your task is to investigate the issue using monitoring commands."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Check disk usage across all mounted file systems."
    read -p "  lab@monitor01:~\$ " cmd1
    echo
    [[ "$cmd1" != "df -h" ]] && {
        print_error "Expected 'df -h' for human-readable disk usage."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Filesystem      Size  Used Avail Use% Mounted on"
    echo "  /dev/sda1        30G   28G  1.0G  97% /"
    echo "  tmpfs           1.9G     0  1.9G   0% /dev/shm"
    echo "  /dev/sdb1        50G   10G   40G  20% /home"
    echo

    echo "  Step 2: View recent kernel messages to check for hardware warnings."
    read -p "  lab@monitor01:~\$ " cmd2
    echo
    [[ "$cmd2" != "dmesg | tail" && "$cmd2" != "dmesg | tail -n 10" ]] && {
        print_error "Expected 'dmesg | tail' or similar to view recent logs."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [ 1551.392013] sd 2:0:0:0: [sda] tag#0 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE"
    echo "  [ 1551.392021] sd 2:0:0:0: [sda] tag#0 Sense Key : Medium Error [current]"
    echo "  [ 1551.392028] sd 2:0:0:0: [sda] tag#0 Add. Sense: Unrecovered read error"
    echo "  [ 1551.392036] blk_update_request: I/O error, dev sda, sector 4096208 op 0x0:(READ) flags 0x80700 phys_seg 1 prio class 0"
    echo "  [ 1551.392052] Buffer I/O error on dev sda1, logical block 51234, async page read"
    echo "  [ 1551.392091] JBD2: Detected IO errors while flushing file data on sda1-8"
    echo "  [ 1551.392113] EXT4-fs warning (device sda1): ext4_end_bio:343: I/O error -5 writing to inode 524305 (offset 0 size 4096)"
    echo "  [ 1551.392120] Aborting journal on device sda1-8."
    echo "  [ 1551.392122] EXT4-fs (sda1): previous I/O error to superblock detected"
    echo "  [ 1551.392135] EXT4-fs (sda1): Remounting filesystem read-only"
    echo

    echo "  Step 3: Check current memory usage."
    read -p "  lab@monitor01:~\$ " cmd3
    echo
    [[ "$cmd3" != "free -h" ]] && {
        print_error "Expected 'free -h' to check memory usage."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "                total        used        free      shared  buff/cache   available"
    echo "  Mem:           3.8G        3.0G        300M        120M        500M        500M"
    echo "  Swap:          2.0G        500M        1.5G"
    echo

    echo "  Step 4: View CPU I/O statistics."
    read -p "  lab@monitor01:~\$ " cmd4
    echo
    [[ "$cmd4" != "iostat" && "$cmd4" != "iostat -x" ]] && {
        print_error "Expected 'iostat' or 'iostat -x' for I/O statistics."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  avg-cpu:  %user   %nice %system %iowait  %steal   %idle"
    echo "             4.75    0.00    2.56    8.99    0.00   83.70"
    echo "  Device            tps    kB_read/s kB_wrtn/s kB_read kB_wrtn"
    echo "  sda               9.03      120.11     203.41   140243  237506"
    echo

    echo "  Step 5: Check network socket statistics."
    read -p "  lab@monitor01:~\$ " cmd5
    echo
    [[ "$cmd5" != "netstat -tuln" && "$cmd5" != "ss -tuln" ]] && {
        print_error "Expected 'netstat -tuln' or 'ss -tuln' for network sockets."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Proto Recv-Q Send-Q Local Address           Foreign Address         State"
    echo "  tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN"
    echo "  tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN"
    echo "  udp        0      0 0.0.0.0:68              0.0.0.0:*"
    echo

    echo "  Step 6: Launch a dynamic monitor for real-time CPU and process stats."
    read -p "  lab@monitor01:~\$ " cmd6
    echo
    
    [[ "$cmd6" != "top" ]] && {
        print_error "Expected 'top' to launch the live resource monitor."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  top - 15:20:01 up 1 day,  2:53,  1 user,  load average: 2.56, 2.12, 1.95"
    echo "  Tasks: 152 total,   2 running, 149 sleeping,   0 stopped,   1 zombie"
    echo "  %Cpu(s):  6.8 us,  1.9 sy,  0.0 ni, 89.7 id,  1.4 wa,  0.0 hi,  0.2 si,  0.0 st"
    echo "  MiB Mem :   7823.2 total,   6543.7 used,    412.4 free,    867.1 buff/cache"
    echo "  MiB Swap:   2048.0 total,      85.3 used,   1962.7 free.  2301.4 avail Mem"
    echo
    echo "    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND"
    echo "   1275 root      20   0  162284   8840   6328 S   7.3   0.1   0:15.28 systemd-journal"
    echo "   1984 root      20   0  302564  12160   8424 S   5.0   0.2   0:10.47 NetworkManager"
    echo "   2142 mysql     20   0 1512200 210412  18104 S   3.7   2.6   1:32.55 mysqld"
    echo "   2458 apache    20   0  292384  17896   9820 S   1.6   0.2   0:22.13 httpd"
    echo "   2667 lab       20   0  173820  10560   6404 R   1.3   0.1   0:05.09 top"
    echo "   2784 lab       20   0  231240  15600  10048 S   0.7   0.2   0:09.87 bash"
    echo "   2830 root      20   0  412604  24812  11200 S   0.3   0.3   0:18.42 gdm-session-wor"
    echo "   2927 root      20   0  262148  13384   9472 S   0.3   0.2   0:07.22 udisksd"
    echo "   2998 root      20   0  144432   8640   6260 S   0.0   0.1   0:02.13 cron"
    echo "   3011 root      20   0  141288   7444   5928 S   0.0   0.1   0:01.09 sshd"
    echo


    print_success "Excellent job diagnosing system health!"
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
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
