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
    echo "  Last metadata expiration check: 0:03:12 ago on Fri 19 Dec 2025 04:10:11 PM EST."
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package                Architecture    Version                 Repository  Size"
    echo "  ================================================================================"
    echo "   Installing:"
    echo "   easy-rsa                noarch          3.1.7-1.el9             epel       49 k"
    echo "   openvpn                 x86_64          2.6.8-1.el9              appstream  584 k"
    echo "   "
    echo "   Installing dependencies:"
    echo "   lz4-libs                x86_64          1.9.4-2.el9              baseos     62 k"
    echo "   "
    echo "  Transaction Summary"
    echo "  ================================================================================"
    echo "  Install  3 Packages"
    echo "  "
    echo "  Total download size: 695 k"
    echo "  Installed size: 2.3 M"
    echo "  Downloading Packages:"
    echo "  (1/3): openvpn-2.6.8-1.el9.x86_64.rpm                  1.6 MB/s | 584 kB  00:00"
    echo "  (2/3): easy-rsa-3.1.7-1.el9.noarch.rpm                 1.1 MB/s |  49 kB  00:00"
    echo "  (3/3): lz4-libs-1.9.4-2.el9.x86_64.rpm                 2.0 MB/s |  62 kB  00:00"
    echo "  --------------------------------------------------------------------------------"
    echo "  Total                                                   3.7 MB/s | 695 kB  00:00"
    echo "  Running transaction check"
    echo "  Transaction check succeeded."
    echo "  Running transaction test"
    echo "  Transaction test succeeded."
    echo "  Running transaction"
    echo "    Preparing        :                                                        1/1"
    echo "    Installing       : lz4-libs-1.9.4-2.el9.x86_64                           1/3"
    echo "    Installing       : openvpn-2.6.8-1.el9.x86_64                             2/3"
    echo "    Installing       : easy-rsa-3.1.7-1.el9.noarch                            3/3"
    echo "    Verifying        : lz4-libs-1.9.4-2.el9.x86_64                           1/3"
    echo "    Verifying        : openvpn-2.6.8-1.el9.x86_64                             2/3"
    echo "    Verifying        : easy-rsa-3.1.7-1.el9.noarch                            3/3"
    echo "  "
    echo "  Installed:"
    echo "    easy-rsa-3.1.7-1.el9.noarch  openvpn-2.6.8-1.el9.x86_64  lz4-libs-1.9.4-2.el9.x86_64"
    echo

    echo "  Step 2: Set up the PKI (Public Key Infrastructure) directory."
    read -p "  lab@lpic-lab104:~$ " cmd2
    echo
    [[ "$cmd2" != "make-cadir ~/openvpn-ca && cd ~/openvpn-ca" ]] && {
        print_error "Incorrect. Use: make-cadir ~/openvpn-ca && cd ~/openvpn-ca"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  NOTE: Easy-RSA 'make-cadir' is available on some distros; others ship /usr/share/easy-rsa/ directly."
    echo "  Created directory: /home/lab/openvpn-ca"
    echo "  Copied easy-rsa files into: /home/lab/openvpn-ca"
    echo

    echo "  Step 3: Build the Certificate Authority (CA)."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd3
    echo
    [[ "$cmd3" != "./easyrsa init-pki && ./easyrsa build-ca" ]] && {
        print_error "Incorrect. Use: ./easyrsa init-pki && ./easyrsa build-ca"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Notice"
    echo "  ------"
    echo "  'init-pki' complete; you may now create a CA or requests."
    echo "  "
    echo "  Using SSL: openssl OpenSSL 3.0.7 1 Nov 2022"
    echo "  "
    echo "  Enter New CA Key Passphrase:"
    echo "  Re-Enter New CA Key Passphrase:"
    echo "  "
    echo "  Common Name (eg: your user, host, or server name) [Easy-RSA CA]: rhel-lab-ca"
    echo "  "
    echo "  CA creation complete and you may now import and sign cert requests."
    echo "  Your new CA certificate file for publishing is at:"
    echo "    pki/ca.crt"
    echo

    echo "  Step 4: Generate server certificate and key."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd4
    echo
    [[ "$cmd4" != "./easyrsa gen-req server nopass && ./easyrsa sign-req server server" ]] && {
        print_error "Incorrect. Use: ./easyrsa gen-req server nopass && ./easyrsa sign-req server server"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Using SSL: openssl OpenSSL 3.0.7 1 Nov 2022"
    echo "  Generating a RSA private key"
    echo "  ........................................................+++++"
    echo "  ........................................+++++"
    echo "  writing new private key to 'pki/private/server.key'"
    echo "  -----"
    echo "  "
    echo "  Keypair and certificate request completed. Your files are:"
    echo "    req: pki/reqs/server.req"
    echo "    key: pki/private/server.key"
    echo "  "
    echo "  Using SSL: openssl OpenSSL 3.0.7 1 Nov 2022"
    echo "  "
    echo "  You are about to sign the following certificate request:"
    echo "    subject=CN = server"
    echo "  "
    echo "  Type the word 'yes' to continue, or any other input to abort."
    echo "    Confirm request details: yes"
    echo "  "
    echo "  Enter pass phrase for /home/lab/openvpn-ca/pki/private/ca.key:"
    echo "  "
    echo "  Certificate created at: pki/issued/server.crt"
    echo

    echo "  Step 5: Generate Diffie-Hellman parameters."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd5
    echo
    [[ "$cmd5" != "./easyrsa gen-dh" ]] && {
        print_error "Incorrect. Use: ./easyrsa gen-dh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Using SSL: openssl OpenSSL 3.0.7 1 Nov 2022"
    echo "  Generating DH parameters, 2048 bit long safe prime"
    echo "  This is going to take a long time"
    echo "  ..............................................................................+"
    echo "  ..........................................................+"
    echo "  DH parameters of size 2048 created at pki/dh.pem"
    echo

    echo "  Step 6: Copy certificates and keys to OpenVPN directory."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd6
    echo
    [[ "$cmd6" != "sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/" ]] && {
        print_error "Incorrect. Use: sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  cp: copy '/home/lab/openvpn-ca/pki/ca.crt' -> '/etc/openvpn/ca.crt'"
    echo "  cp: copy '/home/lab/openvpn-ca/pki/private/server.key' -> '/etc/openvpn/server.key'"
    echo "  cp: copy '/home/lab/openvpn-ca/pki/issued/server.crt' -> '/etc/openvpn/server.crt'"
    echo "  cp: copy '/home/lab/openvpn-ca/pki/dh.pem' -> '/etc/openvpn/dh.pem'"
    echo

    echo "  Step 7: Configure the OpenVPN server."
    read -p "  lab@lpic-lab104:~$ " cmd7
    echo
    [[ "$cmd7" != "sudo gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf > /dev/null" ]] && {
        print_error "Incorrect. Use: sudo gunzip -c ... | sudo tee /etc/openvpn/server.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  0+1 records in"
    echo "  0+1 records out"
    echo "  7556 bytes copied, 0.00231445 s, 3.3 MB/s"
    echo

    echo "  Step 8: Start and enable the OpenVPN server."
    read -p "  lab@lpic-lab104:~$ " cmd8
    echo
    [[ "$cmd8" != "sudo systemctl enable --now openvpn@server" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now openvpn@server"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Created symlink /etc/systemd/system/multi-user.target.wants/openvpn@server.service → /usr/lib/systemd/system/openvpn@.service."
    echo

    echo "  Step 9: Verify the server status."
    read -p "  lab@lpic-lab104:~$ " cmd9
    echo
    [[ "$cmd9" != "sudo systemctl status openvpn@server" ]] && {
        print_error "Incorrect. Use: sudo systemctl status openvpn@server"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ● openvpn@server.service - OpenVPN service for server"
    echo "     Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)"
    echo "     Active: active (running) since Fri 2025-12-19 16:12:44 EST; 6s ago"
    echo "       Docs: man:openvpn(8)"
    echo "   Main PID: 4128 (openvpn)"
    echo "     Status: \"Initialization Sequence Completed\""
    echo "      Tasks: 1 (limit: 11423)"
    echo "     Memory: 3.8M"
    echo "        CPU: 112ms"
    echo "     CGroup: /system.slice/system-openvpn\\x2dserver.slice/openvpn@server.service"
    echo "             └─4128 /usr/sbin/openvpn --config /etc/openvpn/server.conf"
    echo "  "
    echo "  Dec 19 16:12:44 rhel-lab openvpn[4128]: WARNING: file '/etc/openvpn/server.key' is group or others accessible"
    echo "  Dec 19 16:12:44 rhel-lab openvpn[4128]: NOTE: --cipher is not set. OpenVPN 2.5+ uses negotiated ciphers."
    echo "  Dec 19 16:12:44 rhel-lab openvpn[4128]: Initialization Sequence Completed"
    echo

    echo "  Step 10: Generate a client certificate (e.g., client1)."
    read -p "  lab@lpic-lab104:~/openvpn-ca$ " cmd10
    echo
    [[ "$cmd10" != "./easyrsa gen-req client1 nopass && ./easyrsa sign-req client client1" ]] && {
        print_error "Incorrect. Use: ./easyrsa gen-req client1 nopass && ./easyrsa sign-req client client1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Using SSL: openssl OpenSSL 3.0.7 1 Nov 2022"
    echo "  Generating a RSA private key"
    echo "  ...................................................+++++"
    echo "  .............................+++++"
    echo "  writing new private key to 'pki/private/client1.key'"
    echo "  -----"
    echo "  Keypair and certificate request completed. Your files are:"
    echo "    req: pki/reqs/client1.req"
    echo "    key: pki/private/client1.key"
    echo "  "
    echo "  You are about to sign the following certificate request:"
    echo "    subject=CN = client1"
    echo "  "
    echo "  Type the word 'yes' to continue, or any other input to abort."
    echo "    Confirm request details: yes"
    echo "  "
    echo "  Enter pass phrase for /home/lab/openvpn-ca/pki/private/ca.key:"
    echo "  "
    echo "  Certificate created at: pki/issued/client1.crt"
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
