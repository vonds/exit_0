#!/bin/bash

# Lab Security 3: SSH Server, inetd/xinetd, Systemd & Runlevels

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Security 3: SSH Server, inetd/xinetd, Systemd & Runlevels"
LAB_ID="lab_sec_3"
LAB_XP=8600
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
    center_text "Harden SSH server, manage legacy inetd/xinetd, systemd units, runlevels."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Allow X11 forwarding on the SSH server (echo the sshd_config directive)."
    read -p "  lab@security-3:~$ " cmd1
    echo
    [[ "$cmd1" != "echo X11Forwarding yes" ]] && {
        print_error "Echo the directive: X11Forwarding yes"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  X11Forwarding yes"
    echo

    echo "  Step 2: Control root login (echo the sshd_config keyword used)."
    read -p "  lab@security-3:~$ " cmd2
    echo
    [[ "$cmd2" != "echo PermitRootLogin" ]] && {
        print_error "Echo: PermitRootLogin"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PermitRootLogin"
    echo

    echo "  Step 3: Disable an xinetd-managed service (echo the directive line)."
    read -p "  lab@security-3:~$ " cmd3
    echo
    [[ "$cmd3" != "echo 'disable = yes'" ]] && {
        print_error "Echo: disable = yes"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  disable = yes"
    echo

    echo "  Step 4: Limit xinetd service access times to 08:00-17:00 (echo directive)."
    read -p "  lab@security-3:~$ " cmd4
    echo
    [[ "$cmd4" != "echo 'access_times = 08:00-17:00'" ]] && {
        print_error "Echo: access_times = 08:00-17:00"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  access_times = 08:00-17:00"
    echo

    echo "  Step 5: Comment out a service line in /etc/inetd.conf (echo the character)."
    read -p "  lab@security-3:~$ " cmd5
    echo
    [[ "$cmd5" != "echo '#'" ]] && {
        print_error "Echo the comment character used in inetd.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  #"
    echo

    echo "  Step 6: Prevent httpd from starting at boot (systemd)."
    read -p "  lab@security-3:~$ " cmd6
    echo
    [[ "$cmd6" != "systemctl disable httpd.service" ]] && {
        print_error "Use: systemctl disable httpd.service"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Disabled httpd.service at boot."
    echo

    echo "  Step 7: Create SysV init links on Debian (echo the tool used)."
    read -p "  lab@security-3:~$ " cmd7
    echo
    [[ "$cmd7" != "echo update-rc.d" ]] && {
        print_error "Echo: update-rc.d"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  update-rc.d"
    echo

    echo "  Step 8: State the runlevel for single-user mode (echo the number)."
    read -p "  lab@security-3:~$ " cmd8
    echo
    [[ "$cmd8" != "echo 1" ]] && {
        print_error "Echo: 1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  1"
    echo

    echo "  Step 9: Start a login shell with su to apply normal login environment."
    read -p "  lab@security-3:~$ " cmd9
    echo
    [[ "$cmd9" != "su -" ]] && {
        print_error "Use: su -"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Login shell started."
    echo

    echo "  Step 10: State the unit extension for IPC/listening endpoints managed by systemd."
    read -p "  lab@security-3:~$ " cmd10
    echo
    [[ "$cmd10" != "echo .socket" ]] && {
        print_error "Echo: .socket"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  .socket"
    echo

    echo "  Step 11: In sshd host key generation, set an empty passphrase."
    read -p "  lab@security-3:~$ " cmd11
    echo
    [[ "$cmd11" != "ssh-keygen -N \"\"" ]] && {
        print_error "Use: ssh-keygen -N \"\""
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Empty passphrase set."
    echo

    echo "  Step 12: Generate a DSA SSH key (legacy, for completeness)."
    read -p "  lab@security-3:~$ " cmd12
    echo
    [[ "$cmd12" != "ssh-keygen -t dsa" ]] && {
        print_error "Use: ssh-keygen -t dsa"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  DSA key generation started."
    echo

    echo "  Step 13: Provide the keyword for allowing root SSH login (echo)."
    read -p "  lab@security-3:~$ " cmd13
    echo
    [[ "$cmd13" != "echo PermitRootLogin" ]] && {
        print_error "Echo: PermitRootLogin"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PermitRootLogin"
    echo

    echo "  Step 14: State the file where per-user SSH authorized keys live."
    read -p "  lab@security-3:~$ " cmd14
    echo
    [[ "$cmd14" != "echo ~/.ssh/authorized_keys" ]] && {
        print_error "Echo: ~/.ssh/authorized_keys"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ~/.ssh/authorized_keys"
    echo

    echo "  Step 15: Give the path for a server-wide known hosts cache file."
    read -p "  lab@security-3:~$ " cmd15
    echo
    [[ "$cmd15" != "echo /etc/ssh/ssh_known_hosts" && "$cmd15" != "echo /etc/ssh/known_hosts" ]] && {
        print_error "Echo: /etc/ssh/ssh_known_hosts (or /etc/ssh/known_hosts)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (path accepted)"
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
