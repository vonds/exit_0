#!/bin/bash

# Lab 153: getent Database Lookup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 153: getent Database Lookup"
LAB_ID="lab153"
LAB_XP=20000
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
    center_text "Query system databases using getent."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Display all entries from the passwd database."
    read -p "  lab@lab153:~$ " cmd1
    echo
    [[ "$cmd1" != "getent passwd" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  root:x:0:0:root:/root:/bin/bash"
    echo "  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin"
    echo "  bin:x:2:2:bin:/bin:/usr/sbin/nologin"
    echo "  sys:x:3:3:sys:/dev:/usr/sbin/nologin"
    echo "  satoshi:x:1001:1001:Satoshi Nakamoto:/home/satoshi:/bin/bash"
    echo

    echo "  Step 2: Display the passwd entry for user 'satoshi'."
    read -p "  lab@lab153:~$ " cmd2
    echo
    [[ "$cmd2" != "getent passwd satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  satoshi:x:1001:1001:Satoshi Nakamoto:/home/satoshi:/bin/bash"
    echo

    echo "  Step 3: Display all entries from the group database."
    read -p "  lab@lab153:~$ " cmd3
    echo
    [[ "$cmd3" != "getent group" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  root:x:0:"
    echo "  daemon:x:1:"
    echo "  bin:x:2:"
    echo "  sys:x:3:"
    echo "  developers:x:1002:satoshi"
    echo "  docker:x:998:satoshi"
    echo "  wheel:x:10:satoshi"
    echo

    echo "  Step 4: Display the group entry for 'developers'."
    read -p "  lab@lab153:~$ " cmd4
    echo
    [[ "$cmd4" != "getent group developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  developers:x:1002:satoshi"
    echo

    echo "  Step 5: Display all entries from the hosts database."
    read -p "  lab@lab153:~$ " cmd5
    echo
    [[ "$cmd5" != "getent hosts" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  127.0.0.1       localhost"
    echo "  ::1             localhost ip6-localhost ip6-loopback"
    echo "  192.168.1.10    workstation01"
    echo

    echo "  Step 6: Lookup the IP address for 'localhost' using getent."
    read -p "  lab@lab153:~$ " cmd6
    echo
    [[ "$cmd6" != "getent hosts localhost" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  127.0.0.1       localhost"
    echo "  ::1             localhost"
    echo

    echo "  Step 7: Display all entries from the services database."
    read -p "  lab@lab153:~$ " cmd7
    echo
    [[ "$cmd7" != "getent services" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ssh               22/tcp"
    echo "  ssh               22/udp"
    echo "  http              80/tcp www www-http"
    echo "  https             443/tcp"
    echo "  domain            53/udp dns"
    echo

    echo "  Step 8: Lookup the service entry for 'ssh'."
    read -p "  lab@lab153:~$ " cmd8
    echo
    [[ "$cmd8" != "getent services ssh" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ssh               22/tcp"
    echo

    echo "  Step 9: Display all entries from the protocols database."
    read -p "  lab@lab153:~$ " cmd9
    echo
    [[ "$cmd9" != "getent protocols" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ip                0 IP"
    echo "  icmp              1 ICMP"
    echo "  tcp               6 TCP"
    echo "  udp              17 UDP"
    echo

    echo "  Step 10: Lookup the protocol entry for 'tcp'."
    read -p "  lab@lab153:~$ " cmd10
    echo
    [[ "$cmd10" != "getent protocols tcp" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tcp               6 TCP"
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
