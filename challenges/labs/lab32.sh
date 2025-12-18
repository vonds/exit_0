#!/bin/bash

# Lab 32: Linux Directory Services - Account Authentication

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 32: Directory Service - Account Authentication"
LAB_ID="lab32"
LAB_XP=13125
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
    center_text "Scenario: Your company is transitioning to a centralized account authentication system."
    center_text "Your role is to configure and verify user authentication using a directory service."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install LDAP client utilities."
    read -p "  lab@lpic-lab32:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install ldap-utils libnss-ldap libpam-ldap nscd" ]] && {
        print_error "Incorrect. Use apt to install ldap-utils and related packages."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  LDAP client utilities installed."
    echo

    echo "  Step 2: Configure LDAP base DN and URI using dpkg-reconfigure."
    read -p "  lab@lpic-lab32:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo dpkg-reconfigure ldap-auth-config" ]] && {
        print_error "Incorrect. Use: sudo dpkg-reconfigure ldap-auth-config"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -----------------------------------------------------------------"
    echo "  Configuring ldap-auth-config"
    echo
    echo "  LDAP server Uniform Resource Identifier:"
    echo "    ldap://ldap.example.com/"
    echo
    echo "  Distinguished name of the search base:"
    echo "    dc=example,dc=com"
    echo
    echo "  LDAP version to use: 3"
    echo "  -----------------------------------------------------------------"
    echo

    echo "  Step 3: Restart NSS and PAM services to apply LDAP settings."
    read -p "  lab@lpic-lab32:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo systemctl restart nscd" ]] && {
        print_error "Incorrect. Restart nscd to apply LDAP integration."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Verify that the LDAP user 'jdoe' can be resolved from the passwd database."
    read -p "  lab@lpic-lab32:~$ " cmd4
    echo
    [[ "$cmd4" != "getent passwd jdoe" ]] && {
        print_error "Incorrect. Use getent to check if jdoe exists in the directory."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  jdoe:x:1003:1003:John Doe:/home/jdoe:/bin/bash"
    echo

    echo "  Step 5: Check PAM configuration file for LDAP entries."
    read -p "  lab@lpic-lab32:~$ " cmd5
    echo
    [[ "$cmd5" != "cat /etc/pam.d/common-auth" ]] && {
        print_error "Incorrect. Use: cat /etc/pam.d/common-auth"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  auth sufficient pam_ldap.so"
    echo "  auth required pam_unix.so nullok_secure"
    echo

    echo "  Step 6: Lock down local sysadmin access except root."
    read -p "  lab@lpic-lab32:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo passwd -l sysadmin" ]] && {
        print_error "Incorrect. Lock a local user account using passwd -l."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 7: Simulate a login session as the LDAP user 'jdoe'."
    read -p "  lab@lpic-lab32:~$ " cmd7
    echo
    [[ "$cmd7" != "su - jdoe" ]] && {
        print_error "Incorrect. Use su - jdoe to simulate login."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 8: Verify that the login was successful"
    read -p "  jdoe@lpic-lab32:~$ " cmd8
    echo
    [[ "$cmd8" != "whoami" ]] && {
        print_error "Incorrect. Run whoami to verify the logged-in user."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  jdoe"
    echo

    print_success "Well done!"
    print_info "You earned $LAB_XP XP for completing the directory authentication lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
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
