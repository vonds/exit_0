#!/bin/bash

# Lab Security 1: Accounts, Aging, Limits & Sudo (part 1)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Security 1: Accounts, Aging, Limits & Sudo (1)"
LAB_ID="lab_sec_1"
LAB_XP=28600
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
    center_text "Work with login control, password aging, limits and sudo policy."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Temporarily prevent non-root logins."
    read -p "  lab@security-1:~$ " cmd1
    echo
    [[ "$cmd1" != "touch /etc/nologin" ]] && {
        print_error "Incorrect. Create /etc/nologin"
        read -p "Press Enter to try again..." _
        continue
    }
    # touch has no stdout on success
    echo "  "
    echo

    echo "  Step 2: Provide a message shown to refused users."
    read -p "  lab@security-1:~$ " cmd2
    echo
    [[ "$cmd2" != "echo 'System maintenance in progress' > /etc/nologin" ]] && {
        print_error "Incorrect. Write text into /etc/nologin"
        read -p "Press Enter to try again..." _
        continue
    }
    # redirect produces no stdout
    echo "  "
    echo

    echo "  Step 3: Show password aging info for 'testuser'."
    read -p "  lab@security-1:~$ " cmd3
    echo
    [[ "$cmd3" != "chage -l testuser" ]] && {
        print_error "Use: chage -l testuser"
        read -p "Press Enter to try again..." _
        continue
    }
    cat <<'EOF'
  Last password change                                    : Aug 01, 2025
  Password expires                                        : never
  Password inactive                                       : never
  Account expires                                         : never
  Minimum number of days between password change          : 0
  Maximum number of days between password change          : 99999
  Number of days of warning before password expires       : 7
EOF
    echo

    echo "  Step 4: Set account 'testuser' to expire on 2025-12-31."
    read -p "  lab@security-1:~$ " cmd4
    echo
    [[ "$cmd4" != "usermod -e 2025-12-31 testuser" ]] && {
        print_error "Use: usermod -e YYYY-MM-DD USER"
        read -p "Press Enter to try again..." _
        continue
    }
    # usermod typically prints nothing on success
    echo "  "
    echo

    echo "  Step 5: Lock 'testuser' (either command is fine)."
    read -p "  lab@security-1:~$ " cmd5
    echo
    if [[ "$cmd5" == "passwd -l testuser" ]]; then
        echo "  passwd: password expiry information changed."
    elif [[ "$cmd5" == "usermod -L testuser" ]]; then
        # usermod prints nothing
        echo "  "
    else
        print_error "Use usermod -L testuser OR passwd -l testuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 6: Unlock 'testuser' (either command is fine)."
    read -p "  lab@security-1:~$ " cmd6
    echo
    if [[ "$cmd6" == "passwd -u testuser" ]]; then
        echo "  passwd: password expiry information changed."
    elif [[ "$cmd6" == "usermod -U testuser" ]]; then
        echo "  "
    else
        print_error "Use usermod -U testuser OR passwd -u testuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 7: Set maximum password age to 90 days for 'testuser'."
    read -p "  lab@security-1:~$ " cmd7
    echo
    [[ "$cmd7" != "passwd -x 90 testuser" ]] && {
        print_error "Use: passwd -x DAYS USER"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo

    echo "  Step 8: Warn 7 days before expiration using chage."
    read -p "  lab@security-1:~$ " cmd8
    echo
    [[ "$cmd8" != "chage -W 7 testuser" ]] && {
        print_error "Use: chage -W DAYS USER"
        read -p "Press Enter to try again..." _
        continue
    }
    # chage prints nothing on success
    echo "  "
    echo

    echo "  Step 9: Show who is currently logged in."
    read -p "  lab@security-1:~$ " cmd9
    echo
    [[ "$cmd9" != "w" ]] && {
        print_error "Use: w"
        read -p "Press Enter to try again..." _
        continue
    }
    cat <<'EOF'
  14:35:22 up 2 days,  3 users,  load average: 0.12, 0.09, 0.05
  USER     TTY      FROM         LOGIN@   IDLE   JCPU   PCPU WHAT
  lab      pts/0    10.0.0.10    14:20    1:12   0.08s  0.08s -bash
  alice    pts/1    10.0.0.25    13:58       2   0.03s  0.01s tmux
  bob      pts/2    10.0.0.30    14:02       -   0.01s  0.01s top
EOF
    echo

    echo "  Step 10: Show usernames and a count of users."
    read -p "  lab@security-1:~$ " cmd10
    echo
    [[ "$cmd10" != "who -q" ]] && {
        print_error "Use: who -q"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  alice bob lab"
    echo "  # users=3"
    echo

    echo "  Step 11: Display all current shell limits."
    read -p "  lab@security-1:~$ " cmd11
    echo
    [[ "$cmd11" != "ulimit -a" ]] && {
        print_error "Use: ulimit -a"
        read -p "Press Enter to try again..." _
        continue
    }
    cat <<'EOF'
  core file size          (blocks, -c) 0
  data seg size           (kbytes, -d) unlimited
  scheduling priority             (-e) 0
  file size               (blocks, -f) unlimited
  pending signals                 (-i) 515191
  max locked memory       (kbytes, -l) 64
  max memory size         (kbytes, -m) unlimited
  open files                      (-n) 1024
  pipe size            (512 bytes, -p) 8
  POSIX message queues     (bytes, -q) 819200
  real-time priority              (-r) 0
  stack size              (kbytes, -s) 8192
  cpu time               (seconds, -t) unlimited
  max user processes              (-u) 63998
  virtual memory          (kbytes, -v) unlimited
  file locks                      (-x) unlimited
EOF
    echo

    echo "  Step 12: Set a hard limit of 25 processes for user 'suehring'."
    read -p "  lab@security-1:~$ " cmd12
    echo
    [[ "$cmd12" != "echo 'suehring hard nproc 25' >> /etc/security/limits.conf" ]] && {
        print_error "Append: suehring hard nproc 25  to limits.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  "
    echo

    echo "  Step 13: Limit concurrent logins for 'lee' to 2."
    read -p "  lab@security-1:~$ " cmd13
    echo
    [[ "$cmd13" != "echo 'lee hard maxlogins 2' >> /etc/security/limits.conf" ]] && {
        print_error "Append: lee hard maxlogins 2  to limits.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  "
    echo

    echo "  Step 14: Limit max file size for group @devs to 100000 blocks."
    read -p "  lab@security-1:~$ " cmd14
    echo
    [[ "$cmd14" != "echo '@devs hard fsize 100000' >> /etc/security/limits.conf" ]] && {
        print_error "Append: @devs hard fsize 100000"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  "
    echo

    # Replace the Step 15 prompt line with:
    echo "  Step 15: Using sudo's run-as capability, execute a single 'id' command as the user 'alice'."
    read -p "  lab@security-1:~$ " cmd15
    echo
    [[ "$cmd15" != "sudo -u alice id" ]] && {
        print_error "Use: sudo -u USER command"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  uid=1001(alice) gid=1001(alice) groups=1001(alice),27(sudo),1002(dev)"
    echo

    echo "  Step 16: Prepare a noninteractive sudo call that fails instead of prompting."
    read -p "  lab@security-1:~$ " cmd16
    echo
    [[ "$cmd16" != "sudo -n true" ]] && {
        print_error "Use: sudo -n command"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sudo: a password is required"
    echo

    echo "  Step 17: Safely edit sudoers."
    read -p "  lab@security-1:~$ " cmd17
    echo
    [[ "$cmd17" != "visudo" ]] && {
        print_error "Use: visudo"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  visudo: /etc/sudoers: parsed OK"
    echo

    echo "  Step 18: Add a NOPASSWD rule for %admins to use /bin/systemctl."
    read -p "  lab@security-1:~$ " cmd18
    echo
    [[ "$cmd18" != "echo '%admins ALL=(ALL:ALL) NOPASSWD: /bin/systemctl' >> /etc/sudoers" ]] && {
        print_error "Append the exact line to /etc/sudoers"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  "
    echo

    echo "  Step 19: In sudo policy, define a user alias named 'ADMINS' that groups the accounts 'alice' and 'bob'."
    read -p "  lab@security-1:~$ " cmd19
    echo
    [[ "$cmd19" != "echo 'User_Alias ADMINS = alice, bob' >> /etc/sudoers" ]] && {
        print_error "Append: User_Alias ADMINS = alice, bob"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  "
    echo

    echo "  Step 20: Identify the file used to set account, process, memory limits."
    read -p "  lab@security-1:~$ " cmd20
    echo
    [[ "$cmd20" != "echo /etc/security/limits.conf" ]] && {
        print_error "Answer by echoing: /etc/security/limits.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /etc/security/limits.conf"
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
