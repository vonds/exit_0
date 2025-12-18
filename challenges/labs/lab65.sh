#!/bin/bash
# Lab 65: The ss Command - View and Analyze Socket Connections

#set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 65: The ss Command"
LAB_ID="lab65"
LAB_XP=26000
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
    center_text "Scenario: You need to inspect network socket activity on a production server."
    center_text "Use the 'ss' command to analyze TCP, UDP, and listening sockets."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Display all listening TCP sockets."
    read -p "  lab@lpic-lab65:~\$ " cmd1
    echo
    [[ "$cmd1" != "ss -tln" ]] && {
        print_error "Incorrect. Use 'ss -tln' to list listening TCP sockets."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  State      Recv-Q Send-Q  Local Address:Port  Peer Address:Port"
    echo "  LISTEN     0      128     127.0.0.1:5432      *:*"
    echo "  LISTEN     0      128     0.0.0.0:22          *:*"
    echo

    echo "  Step 2: Display all UDP sockets."
    read -p "  lab@lpic-lab65:~\$ " cmd2
    echo
    if [[ "$cmd2" != "ss -ua" && "$cmd2" != "ss -un" && "$cmd2" != "ss -uln" ]]; then
        print_error "Acceptable answers: 'ss -ua' (all), 'ss -un' (non-listening), or 'ss -uln' (listening)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Netid  State   Recv-Q Send-Q Local Address:Port   Peer Address:Port"
    echo "  udp    UNCONN  0      0      127.0.0.1:123        *:*"
    echo

    echo "  Step 3: Show all established TCP connections."
    read -p "  lab@lpic-lab65:~\$ " cmd3
    echo
    if [[ "$cmd3" != "ss -tn state established" && "$cmd3" != "ss -tna state established" ]]; then
        print_error "Use 'ss -tn state established' to filter to established TCP connections."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  State  Recv-Q Send-Q  Local Address:Port   Peer Address:Port"
    echo "  ESTAB  0      0       192.168.1.10:22      192.168.1.5:53324"
    echo

    echo "  Step 4: Display summary statistics for all sockets."
    read -p "  lab@lpic-lab65:~\$ " cmd4
    echo
    [[ "$cmd4" != "ss -s" ]] && {
        print_error "Incorrect. Use 'ss -s' to show summary statistics."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Total: 3 (kernel 4)"
    echo "  TCP:   1 (estab 1, closed 0, orphaned 0, timewait 0)"
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
