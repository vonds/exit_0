#!/bin/bash

# Lab 61: Modern Network Management Tools (nmtui, nmcli, nm-connection-editor, GNOME)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 61: Modern Network Management Tools"
LAB_ID="lab61"
LAB_XP=31000
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
    center_text "You’re configuring a new laptop running NetworkManager."
    center_text "Use graphical and CLI tools to inspect and edit connections."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Launch the text-based connection manager."
    read -p "  lab@lpic-lab61:~\$ " cmd1
    echo
    [[ "$cmd1" != "nmtui" ]] && {
        print_error "Incorrect. Use: nmtui"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Launching nmtui..."
    echo "  [ ] Edit a connection"
    echo "  [ ] Activate a connection"
    echo "  [ ] Set system hostname"
    echo

    echo "  Step 2: Show all connections using the command line."
    read -p "  lab@lpic-lab61:~\$ " cmd2
    echo
    [[ "$cmd2" != "nmcli connection show" ]] && {
        print_error "Incorrect. Use: nmcli connection show"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  NAME                UUID                                  TYPE      DEVICE"
    echo "  Wired connection 1  e9b2f442-9c6f-11ee-a0e4-bb3b1a480001  ethernet  eth0"
    echo "  Wi-Fi Home          a3c4e210-9c6f-11ee-a0e4-bb3b1a480002  wifi      wlan0"
    echo

    echo "  Step 3: Modify the Wi-Fi connection's IP method to manual."
    read -p "  lab@lpic-lab61:~\$ " cmd3
    [[ "$cmd3" != "nmcli connection modify \"Wi-Fi Home\" ipv4.method manual" ]] && {
        print_error "Incorrect. Use: nmcli connection modify \"Wi-Fi Home\" ipv4.method manual"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connection 'Wi-Fi Home' successfully updated."
    echo

    echo "  Step 4: Set the static IP address to 192.168.10.100/24 and gateway to 192.168.10.1."
    read -p "  lab@lpic-lab61:~\$ " cmd4
    [[ "$cmd4" != "nmcli connection modify \"Wi-Fi Home\" ipv4.addresses 192.168.10.100/24 ipv4.gateway 192.168.10.1" ]] && {
        print_error "Incorrect. Use: nmcli connection modify \"Wi-Fi Home\" ipv4.addresses 192.168.10.100/24 ipv4.gateway 192.168.10.1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connection 'Wi-Fi Home' successfully updated."
    echo

    echo "  Step 5: Restart the connection."
    read -p "  lab@lpic-lab61:~\$ " cmd5
    [[ "$cmd5" != "nmcli connection down \"Wi-Fi Home\" && nmcli connection up \"Wi-Fi Home\"" ]] && {
        print_error "Incorrect. Use: nmcli connection down \"Wi-Fi Home\" && nmcli connection up \"Wi-Fi Home\""
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connection 'Wi-Fi Home' successfully activated."
    echo

    print_success "Well done! You've practiced managing connections using modern tools."
    print_info "You earned $LAB_XP XP for completing this lab!"
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
