#!/bin/bash

# Lab 27: Password Aging and Expiration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 27: Password Aging and Expiration"
LAB_ID="lab27"
LAB_XP=2538
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

USERNAME="expiringuser"

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
    center_text "You're auditing password policies for users on your system."
    center_text "You'll practice enabling, checking, and disabling password aging."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a user called '$USERNAME'."
    read -p "  lab@lpic-lab27:~\$ " cmd1
    echo
    [[ "$cmd1" != "sudo useradd $USERNAME" && "$cmd1" != "useradd $USERNAME" ]] && {
        print_error "Incorrect. Use useradd to create the user."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  User '$USERNAME' created successfully."
    echo

    echo "  Step 2: Set a password for '$USERNAME'."
    read -p "  lab@lpic-lab27:~\$ " cmd2
    echo
    [[ "$cmd2" != "sudo passwd $USERNAME" && "$cmd2" != "passwd $USERNAME" ]] && {
        print_error "Incorrect. Use passwd to set the user password."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Password updated successfully."
    echo

    echo "  Step 3: Enable password expiration to 30 days for '$USERNAME'."
    read -p "  lab@lpic-lab27:~\$ " cmd3
    echo
    [[ "$cmd3" != "sudo chage -M 30 $USERNAME" && "$cmd3" != "chage -M 30 $USERNAME" ]] && {
        print_error "Incorrect. Use chage -M 30 to enforce max age."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Maximum password age set to 30 days."
    echo

    echo "  Step 4: Set a minimum password age of 7 days."
    read -p "  lab@lpic-lab27:~\$ " cmd4
    echo
    [[ "$cmd4" != "sudo chage -m 7 $USERNAME" && "$cmd4" != "chage -m 7 $USERNAME" ]] && {
        print_error "Incorrect. Use chage -m 7 to enforce min age."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Minimum password age set to 7 days."
    echo

    echo "  Step 5: Set warning before expiration to 5 days."
    read -p "  lab@lpic-lab27:~\$ " cmd5
    echo
    [[ "$cmd5" != "sudo chage -W 5 $USERNAME" && "$cmd5" != "chage -W 5 $USERNAME" ]] && {
        print_error "Incorrect. Use chage -W 5 to set warning days."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Warning set to 5 days before password expiration."
    echo

    echo "  Step 6: View aging policy for '$USERNAME'."
    read -p "  lab@lpic-lab27:~\$ " cmd6
    echo
    [[ "$cmd6" != "sudo chage -l $USERNAME" && "$cmd6" != "chage -l $USERNAME" ]] && {
        print_error "Incorrect. Use chage -l to view current aging settings."
        read -p "Press Enter to try again..." _
        continue
    }
    echo -e "   Last password change\t\t\t: Jul 18, 2025\n   Password expires\t\t\t: Aug 17, 2025\n   Password inactive\t\t\t: never\n   Account expires\t\t\t: never\n   Minimum number of days between password change\t: 7\n   Maximum number of days between password change\t: 30\n   Number of days of warning before password expires\t: 5"
    echo

    echo "  Step 7: Disable password aging."
    read -p "  lab@lpic-lab27:~\$ " cmd7
    echo
    [[ "$cmd7" != "sudo chage -M -1 $USERNAME" && "$cmd7" != "chage -M -1 $USERNAME" ]] && {
        print_error "Incorrect. Use chage -M -1 to disable aging."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Password aging disabled for '$USERNAME'."
    echo

    echo "  Step 8: Clean up (remove the user)."
    read -p "  lab@lpic-lab27:~\$ " cmd8
    echo
    [[ "$cmd8" != "sudo userdel $USERNAME" && "$cmd8" != "userdel $USERNAME" ]] && {
        print_error "Incorrect. Use userdel to remove the user."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  User '$USERNAME' deleted."
    echo

    print_success "Outstanding!"
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
