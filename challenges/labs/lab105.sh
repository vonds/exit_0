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
    echo "  Last metadata expiration check: 0:01:44 ago on Fri 19 Dec 2025 05:02:11 PM EST."
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package                      Architecture    Version              Repository  Size"
    echo "  ================================================================================"
    echo "   Installing:"
    echo "   dhcp-server                   x86_64          12:4.4.2-19.el9      appstream  1.2 M"
    echo "   dhcp-common                    noarch         12:4.4.2-19.el9      appstream  158 k"
    echo "   "
    echo "  Transaction Summary"
    echo "  ================================================================================"
    echo "  Install  2 Packages"
    echo "  "
    echo "  Total download size: 1.4 M"
    echo "  Installed size: 4.8 M"
    echo "  Downloading Packages:"
    echo "  (1/2): dhcp-common-4.4.2-19.el9.noarch.rpm                 3.2 MB/s | 158 kB  00:00"
    echo "  (2/2): dhcp-server-4.4.2-19.el9.x86_64.rpm                 7.1 MB/s | 1.2 MB  00:00"
    echo "  --------------------------------------------------------------------------------"
    echo "  Total                                                   9.4 MB/s | 1.4 MB  00:00"
    echo "  Running transaction check"
    echo "  Transaction check succeeded."
    echo "  Running transaction test"
    echo "  Transaction test succeeded."
    echo "  Running transaction"
    echo "    Preparing        :                                                        1/1"
    echo "    Installing       : dhcp-common-12:4.4.2-19.el9.noarch                    1/2"
    echo "    Installing       : dhcp-server-12:4.4.2-19.el9.x86_64                    2/2"
    echo "    Verifying        : dhcp-common-12:4.4.2-19.el9.noarch                    1/2"
    echo "    Verifying        : dhcp-server-12:4.4.2-19.el9.x86_64                    2/2"
    echo "  "
    echo "  Installed:"
    echo "    dhcp-server-12:4.4.2-19.el9.x86_64   dhcp-common-12:4.4.2-19.el9.noarch"
    echo

    echo "  Step 2: Edit the main DHCP configuration file."
    read -p "  lab@lpic-lab105:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo nano /etc/dhcp/dhcpd.conf" && "$cmd2" != "sudo vim /etc/dhcp/dhcpd.conf" ]] && {
        print_error "Incorrect. Use: sudo nano /etc/dhcp/dhcpd.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [editor opened: /etc/dhcp/dhcpd.conf]"
    echo "  [you added a subnet scope, DNS servers, and default gateway]"
    echo "  [saved and exited]"
    echo
    echo "  Example config:"
    echo "  subnet 192.168.50.0 netmask 255.255.255.0 {"
    echo "    range 192.168.50.10 192.168.50.100;"
    echo "    option domain-name-servers 8.8.8.8, 1.1.1.1;"
    echo "    option routers 192.168.50.1;"
    echo "    default-lease-time 600;"
    echo "    max-lease-time 7200;"
    echo "  }"
    echo

    echo "  Step 3: Define the network interface to use."
    read -p "  lab@lpic-lab105:~$ " cmd3
    echo
    [[ "$cmd3" != "echo 'INTERFACESv4=\"eth0\"' | sudo tee /etc/default/isc-dhcp-server > /dev/null" && "$cmd3" != "echo 'DHCPDARGS=eth0' | sudo tee /etc/sysconfig/dhcpd > /dev/null" ]] && {
        print_error "Incorrect. Use: echo 'INTERFACESv4=\"eth0\"' ... or DHCPDARGS depending on distro"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [updated interface binding]"
    echo "  [dhcpd will listen on: eth0]"
    echo

    echo "  Step 4: Enable and start the DHCP server."
    read -p "  lab@lpic-lab105:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo systemctl enable --now isc-dhcp-server" && "$cmd4" != "sudo systemctl enable --now dhcpd" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now isc-dhcp-server (or dhcpd)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Created symlink /etc/systemd/system/multi-user.target.wants/dhcpd.service → /usr/lib/systemd/system/dhcpd.service."
    echo

    echo "  Step 5: Check server status for successful launch."
    read -p "  lab@lpic-lab105:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo systemctl status isc-dhcp-server" && "$cmd5" != "sudo systemctl status dhcpd" ]] && {
        print_error "Incorrect. Use: sudo systemctl status isc-dhcp-server (or dhcpd)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ● dhcpd.service - DHCPv4 Server Daemon"
    echo "     Loaded: loaded (/usr/lib/systemd/system/dhcpd.service; enabled; vendor preset: disabled)"
    echo "     Active: active (running) since Fri 2025-12-19 17:04:28 EST; 6s ago"
    echo "       Docs: man:dhcpd(8)"
    echo "             man:dhcpd.conf(5)"
    echo "   Main PID: 5312 (dhcpd)"
    echo "     Status: \"Dispatching packets...\""
    echo "      Tasks: 1 (limit: 11423)"
    echo "     Memory: 4.7M"
    echo "        CPU: 86ms"
    echo "     CGroup: /system.slice/dhcpd.service"
    echo "             └─5312 /usr/sbin/dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf -pf /run/dhcpd.pid eth0"
    echo "  "
    echo "  Dec 19 17:04:28 rhel-lab dhcpd[5312]: Listening on LPF/eth0/52:54:00:7a:2c:19/192.168.50.0/24"
    echo "  Dec 19 17:04:28 rhel-lab dhcpd[5312]: Sending on   LPF/eth0/52:54:00:7a:2c:19/192.168.50.0/24"
    echo "  Dec 19 17:04:28 rhel-lab dhcpd[5312]: Sending on   Socket/fallback/fallback-net"
    echo

    echo "  Step 6: Check DHCP leases (once a client has requested one)."
    read -p "  lab@lpic-lab105:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo cat /var/lib/dhcp/dhcpd.leases" && "$cmd6" != "sudo cat /var/lib/dhcpd/dhcpd.leases" ]] && {
        print_error "Incorrect. Use: sudo cat /var/lib/dhcp/dhcpd.leases"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  # The format is one lease block per client that has requested an address."
    echo "  lease 192.168.50.10 {"
    echo "    starts 5 2025/12/19 22:05:01;"
    echo "    ends 5 2025/12/19 22:15:01;"
    echo "    tstp 5 2025/12/19 22:15:01;"
    echo "    cltt 5 2025/12/19 22:05:01;"
    echo "    binding state active;"
    echo "    next binding state free;"
    echo "    rewind binding state free;"
    echo "    hardware ethernet 3c:52:82:19:aa:0f;"
    echo "    uid \"\\001<R\\202\\031\\252\\017\";"
    echo "    client-hostname \"laptop-qa\";"
    echo "  }"
    echo
    echo "  lease 192.168.50.11 {"
    echo "    starts 5 2025/12/19 22:06:12;"
    echo "    ends 5 2025/12/19 22:16:12;"
    echo "    cltt 5 2025/12/19 22:06:12;"
    echo "    binding state active;"
    echo "    hardware ethernet 70:ee:50:9c:11:20;"
    echo "    client-hostname \"printer-ops\";"
    echo "  }"
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
