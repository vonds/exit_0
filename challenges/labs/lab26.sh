#!/bin/bash

# Lab 26: User Setup and Permissions (Basic + Advanced Practice)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 26: User Setup and Permissions"
LAB_ID="lab26"
LAB_XP=2546
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

USERNAME="devstudent"
USER2="devstudent2"
GROUPNAME="devteam"

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
    center_text "You're onboarding two developers and assigning group permissions."
    center_text "You'll practice both basic and advanced user creation steps."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a new group called '$GROUPNAME'."
    read -p "  lab@lpic-lab26:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo groupadd $GROUPNAME" && "$cmd1" != "groupadd $GROUPNAME" ]] && {
        print_error "Incorrect. Use groupadd to create the group."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group '$GROUPNAME' created successfully."
    echo

    echo "  Step 2: Create the user '$USERNAME' (basic method, no flags)."
    read -p "  lab@lpic-lab26:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo useradd $USERNAME" && "$cmd2" != "useradd $USERNAME" ]] && {
        print_error "Incorrect. Use the basic useradd command with the username."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  User '$USERNAME' created (without -m or group assignment)."
    echo

    echo "  Step 3: Set a password for '$USERNAME'."
    read -p "  lab@lpic-lab26:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo passwd $USERNAME" && "$cmd3" != "passwd $USERNAME" ]] && {
        print_error "Incorrect. Use passwd to set the user password."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Password set successfully."
    echo

    echo "  Step 4: Add '$USERNAME' to the '$GROUPNAME' group using usermod."
    read -p "  lab@lpic-lab26:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo usermod -g $GROUPNAME $USERNAME" && "$cmd4" != "usermod -g $GROUPNAME $USERNAME" ]] && {
        print_error "Incorrect. Use usermod -g to change the primary group."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group assignment updated using usermod."
    echo

    echo "  Step 5: Create the user '$USER2' using full advanced useradd flags."
    echo "  Include: -g, -s, -c, -m, -d"
    read -p "  lab@lpic-lab26:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo useradd -g $GROUPNAME -s /bin/bash -c \"Dev employee\" -m -d /home/$USER2 $USER2" && "$cmd5" != "useradd -g $GROUPNAME -s /bin/bash -c \"Dev employee\" -m -d /home/$USER2 $USER2" ]] && {
        print_error "Incorrect. Use all required flags to create a customized user in devteam."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  User '$USER2' created with correct options."
    echo

    echo "  Step 6: Set password for '$USER2'."
    read -p "  lab@lpic-lab26:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo passwd $USER2" && "$cmd6" != "passwd $USER2" ]] && {
        print_error "Incorrect. Use passwd to set the password."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Password set successfully."
    echo

    echo "  Step 7: Create a shared directory and change its group to '$GROUPNAME' recursively."
    read -p "  lab@lpic-lab26:~$ " cmd7
    echo
    [[ "$cmd7" != "sudo mkdir -p /opt/devwork && sudo chgrp -R $GROUPNAME /opt/devwork" && "$cmd7" != "mkdir -p /opt/devwork && chgrp -R $GROUPNAME /opt/devwork" ]] && {
        print_error "Incorrect. Create the directory and chgrp it recursively."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Directory created and group ownership assigned."
    echo

    echo "  Step 8: Check '$USERNAME' in /etc/passwd."
    read -p "  lab@lpic-lab26:~$ " cmd8
    echo
    [[ "$cmd8" != "grep $USERNAME /etc/passwd" ]] && {
        print_error "Use grep to locate the user in /etc/passwd."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "$USERNAME:x:1001:1002::/home/$USERNAME:/bin/bash"
    echo

    echo "  Step 9: Check '$USER2' in /etc/passwd."
    read -p "  lab@lpic-lab26:~$ " cmd9
    echo
    [[ "$cmd9" != "grep $USER2 /etc/passwd" ]] && {
        print_error "Use grep to locate the second user."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "$USER2:x:1002:1002:Dev employee:/home/$USER2:/bin/bash"
    echo

    echo "  Step 10: Verify group membership of '$USERNAME'."
    read -p "  lab@lpic-lab26:~$ " cmd10
    echo
    [[ "$cmd10" != "id $USERNAME" ]] && {
        print_error "Use id to view the user's group information."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "uid=1001($USERNAME) gid=1002($GROUPNAME) groups=1002($GROUPNAME)"
    echo

    echo "  Step 11: Verify group membership of '$USER2'."
    read -p "  lab@lpic-lab26:~$ " cmd11
    echo
    [[ "$cmd11" != "id $USER2" ]] && {
        print_error "Use id to view the second user's group information."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "uid=1002($USER2) gid=1002($GROUPNAME) groups=1002($GROUPNAME)"
    echo

    echo "  Step 12: View /etc/group to confirm both users are only in '$GROUPNAME'."
    read -p "  lab@lpic-lab26:~$ " cmd12
    echo
    [[ "$cmd12" != "cat /etc/group" ]] && {
        print_error "Use cat to view group membership."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "$GROUPNAME:x:1002:$USERNAME,$USER2"
    echo

    echo "  Step 13: Clean up — delete both users and the group."
    read -p "  lab@lpic-lab26:~$ " cmd13
    echo
    [[ "$cmd13" != "sudo userdel -r $USERNAME && sudo userdel -r $USER2 && sudo groupdel $GROUPNAME" && "$cmd13" != "userdel -r $USERNAME && userdel -r $USER2 && groupdel $GROUPNAME" ]] && {
        print_error "Use userdel -r and groupdel to remove both users and group."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Users and group removed successfully."
    echo

    print_success "Excellent work!"
    print_info "You've earned $LAB_XP XP for completing this dual-user setup lab!"
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
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
