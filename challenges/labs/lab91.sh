#!/bin/bash

# Lab 91: OpenLDAP Server Installation and Configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 91: OpenLDAP Server Installation and Initial Configuration"
LAB_ID="lab91"
LAB_XP=4500
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
    center_text "Scenario: Install and configure an OpenLDAP directory server for basic user management."
    center_text "You will install packages, generate a password hash, configure a base DN, and test access."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install OpenLDAP server and client utilities."
    read -p "  lab@lpic-lab91:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install slapd ldap-utils -y" && "$cmd1" != "sudo dnf install openldap-servers openldap-clients -y" && "$cmd1" != "sudo pacman -S openldap" ]] && {
        print_error "Incorrect. Use: sudo apt install slapd ldap-utils -y (or dnf/pacman equivalent)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  OpenLDAP server and client tools installed."
    echo

    echo "  Step 2: Reconfigure slapd and define admin password, domain, and base DN."
    read -p "  lab@lpic-lab91:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo dpkg-reconfigure slapd" ]] && {
        print_error "Incorrect. Use: sudo dpkg-reconfigure slapd (on Debian/Ubuntu)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  slapd reconfigured with your specified domain and base DN."
    echo

    echo "  Step 3: Generate an LDAP password hash."
    read -p "  lab@lpic-lab91:~$ " cmd3
    echo
    [[ "$cmd3" != "slappasswd" ]] && {
        print_error "Incorrect. Use: slappasswd"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Password hash generated for use in configuration."
    echo

    echo "  Step 4: Verify slapd is running and enabled on boot."
    read -p "  lab@lpic-lab91:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo systemctl status slapd" ]] && {
        print_error "Incorrect. Use: sudo systemctl status slapd"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  slapd is active."
    echo

    echo "  Step 5: Load core schema if not already present."
    read -p "  lab@lpic-lab91:~$ " cmd5
    echo
    [[ "$cmd5" != "ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/core.ldif" && "$cmd5" != "ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif" ]] && {
        print_error "Incorrect. Example: ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/core.ldif"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  core.ldif schema loaded successfully."
    echo

    echo "  Step 6: Create a basic base.ldif for the domain."
    read -p "  lab@lpic-lab91:~$ " cmd6
    echo
    [[ "$cmd6" != "nano ~/base.ldif" && "$cmd6" != "vim ~/base.ldif" ]] && {
        print_error "Incorrect. Use nano or vim to create ~/base.ldif"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Example contents:"
    echo
    echo "  dn: dc=example,dc=com"
    echo "  objectClass: top"
    echo "  objectClass: dcObject"
    echo "  objectClass: organization"
    echo "  o: Example Company"
    echo "  dc: example"
    echo

    echo "  Step 7: Add the base DN using ldapadd."
    read -p "  lab@lpic-lab91:~$ " cmd7
    echo
    [[ "$cmd7" != "ldapadd -x -D cn=admin,dc=example,dc=com -W -f ~/base.ldif" ]] && {
        print_error "Incorrect. Use: ldapadd -x -D cn=admin,dc=example,dc=com -W -f ~/base.ldif"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Base DN structure added to LDAP directory."
    echo

    echo "  Step 8: Verify the LDAP directory content."
    read -p "  lab@lpic-lab91:~$ " cmd8
    echo
    [[ "$cmd8" != "ldapsearch -x -LLL -b dc=example,dc=com" ]] && {
        print_error "Incorrect. Use: ldapsearch -x -LLL -b dc=example,dc=com"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  LDAP base content listed successfully."
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
