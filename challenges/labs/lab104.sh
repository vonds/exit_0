#!/bin/bash

# Lab 104: Installing, Configuring, and Managing OpenVPN

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 104: Installing, Configuring, and Managing OpenVPN"
LAB_ID="lab104"
LAB_XP=5750
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
    center_text "Scenario: You're configuring a secure VPN tunnel for remote workers"
    center_text "using OpenVPN with TLS-based encryption."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the OpenVPN and Easy-RSA packages."
    read -p "  lab@lpic-lab104:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install openvpn easy-rsa -y" && "$cmd1" != "sudo pacman -S openvpn easy-rsa" && "$cmd1" != "sudo dnf install openvpn easy-rsa -y" ]] && {
        print_error "Incorrect. Use: sudo apt install openvpn easy-rsa -y  (or pacman/dnf equivalent)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  OpenVPN and Easy-RSA installed."
    echo

    echo "  Step 2: Set up the PKI (Public Key Infrastructure) directory."
    read -p "  lab@lpic-lab104:~$ " cmd2
    echo
    [[ "$cmd2" != "make-cadir ~/openvpn-ca && cd ~/openvpn-ca" ]] && {
        print_error "Incorrect. Use: make-cadir ~/openvpn-ca && cd ~/openvpn-ca"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Easy-RSA directory created at ~/openvpn-ca."
    echo

    echo "  Step 3: Build the Certificate Authority (CA)."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd3
    echo
    [[ "$cmd3" != "./easyrsa init-pki && ./easyrsa build-ca" ]] && {
        print_error "Incorrect. Use: ./easyrsa init-pki && ./easyrsa build-ca"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  CA created. You were prompted to enter a passphrase and CN."
    echo

    echo "  Step 4: Generate server certificate and key."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd4
    echo
    [[ "$cmd4" != "./easyrsa gen-req server nopass && ./easyrsa sign-req server server" ]] && {
        print_error "Incorrect. Use: ./easyrsa gen-req server nopass && ./easyrsa sign-req server server"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Server certificate signed and ready."
    echo

    echo "  Step 5: Generate Diffie-Hellman parameters."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd5
    echo
    [[ "$cmd5" != "./easyrsa gen-dh" ]] && {
        print_error "Incorrect. Use: ./easyrsa gen-dh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  DH parameters generated."
    echo

    echo "  Step 6: Copy certificates and keys to OpenVPN directory."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd6
    echo
    [[ "$cmd6" != "sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/" ]] && {
        print_error "Incorrect. Use: sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Files copied to /etc/openvpn/"
    echo

    echo "  Step 7: Configure the OpenVPN server."
    read -p "  lab@lpic-lab104:~$ " cmd7
    echo
    [[ "$cmd7" != "sudo gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf > /dev/null" ]] && {
        print_error "Incorrect. Use: sudo gunzip -c ... | sudo tee /etc/openvpn/server.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Sample server config deployed."
    echo

    echo "  Step 8: Start and enable the OpenVPN server."
    read -p "  lab@lpic-lab104:~$ " cmd8
    echo
    [[ "$cmd8" != "sudo systemctl enable --now openvpn@server" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now openvpn@server"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  OpenVPN server started and enabled."
    echo

    echo "  Step 9: Verify the server status."
    read -p "  lab@lpic-lab104:~$ " cmd9
    echo
    [[ "$cmd9" != "sudo systemctl status openvpn@server" ]] && {
        print_error "Incorrect. Use: sudo systemctl status openvpn@server"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  You should see active (running) in the output."
    echo

    echo "  Step 10: Generate a client certificate (e.g., client1)."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd10
    echo
    [[ "$cmd10" != "./easyrsa gen-req client1 nopass && ./easyrsa sign-req client client1" ]] && {
        print_error "Incorrect. Use: ./easyrsa gen-req client1 nopass && ./easyrsa sign-req client client1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Client certificate generated and signed."
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
