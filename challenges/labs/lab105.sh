#!/bin/bash

# Lab 105: Installing, Configuring, and Managing a DHCP Server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 105: Installing, Configuring, and Managing a DHCP Server"
LAB_ID="lab105"
LAB_XP=5250
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
    center_text "Scenario: Your network requires automatic IP assignment using DHCP."
    center_text "You will install and configure a functional DHCP server on your system."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the ISC DHCP server package."
    read -p "  lab@lpic-lab105:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install isc-dhcp-server -y" && "$cmd1" != "sudo pacman -S dhcp" && "$cmd1" != "sudo dnf install dhcp-server -y" ]] && {
        print_error "Incorrect. Use: sudo apt install isc-dhcp-server -y (or pacman/dnf equivalent)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  DHCP server package installed."
    echo

    echo "  Step 2: Edit the main DHCP configuration file."
    read -p "  lab@lpic-lab105:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo nano /etc/dhcp/dhcpd.conf" && "$cmd2" != "sudo vim /etc/dhcp/dhcpd.conf" ]] && {
        print_error "Incorrect. Use: sudo nano /etc/dhcp/dhcpd.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Example config:"
    echo 'subnet 192.168.50.0 netmask 255.255.255.0 {'
    echo '  range 192.168.50.10 192.168.50.100;'
    echo '  option domain-name-servers 8.8.8.8, 1.1.1.1;'
    echo '  option routers 192.168.50.1;'
    echo '  default-lease-time 600;'
    echo '  max-lease-time 7200;'
    echo '}'
    echo

    echo "  Step 3: Define the network interface to use."
    read -p "  lab@lpic-lab105:~$ " cmd3
    echo
    [[ "$cmd3" != "echo 'INTERFACESv4=\"eth0\"' | sudo tee /etc/default/isc-dhcp-server > /dev/null" && "$cmd3" != "echo 'DHCPDARGS=eth0' | sudo tee /etc/sysconfig/dhcpd > /dev/null" ]] && {
        print_error "Incorrect. Use: echo 'INTERFACESv4=\"eth0\"' ... or DHCPDARGS depending on distro"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Interface configuration updated."
    echo

    echo "  Step 4: Enable and start the DHCP server."
    read -p "  lab@lpic-lab105:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo systemctl enable --now isc-dhcp-server" && "$cmd4" != "sudo systemctl enable --now dhcpd" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now isc-dhcp-server (or dhcpd)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  DHCP server started and enabled."
    echo

    echo "  Step 5: Check server status for successful launch."
    read -p "  lab@lpic-lab105:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo systemctl status isc-dhcp-server" && "$cmd5" != "sudo systemctl status dhcpd" ]] && {
        print_error "Incorrect. Use: sudo systemctl status isc-dhcp-server (or dhcpd)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Server status should show active (running)."
    echo

    echo "  Step 6: Check DHCP leases (once a client has requested one)."
    read -p "  lab@lpic-lab105:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo cat /var/lib/dhcp/dhcpd.leases" && "$cmd6" != "sudo cat /var/lib/dhcpd/dhcpd.leases" ]] && {
        print_error "Incorrect. Use: sudo cat /var/lib/dhcp/dhcpd.leases"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Lease file displayed."
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
    print_info "You have completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
