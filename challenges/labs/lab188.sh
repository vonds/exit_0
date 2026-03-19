#!/bin/bash

# Lab 188: Practice Basic File Permissions with chmod
# Objective: Create a file and practice changing its permissions using symbolic and numeric modes.
# NOTE: This lab is fully simulated and does not modify the real filesystem.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 188: Basic File Permissions"
LAB_ID="lab188"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

F="/tmp/perm_file1"
U="$(id -un)"
G="$(id -gn)"
TS_M="$(date +%b)"
TS_D="$(date +%e)"
TS_T="$(date +%H:%M)"
SIM_MODE="-rw-r--r--"
SIM_OCTAL="644"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
    echo
}

print_ls_sim() {
    printf "  %s 1 %-8s %-8s %4d %s %2s %s %s\n" \
        "$SIM_MODE" "$U" "$G" 0 "$TS_M" "$TS_D" "$TS_T" "$F"
}

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

while true; do
    SIM_MODE="-rw-r--r--"
    SIM_OCTAL="644"

    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Goal: Practice changing file permissions with chmod."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create an empty file at $F."
    read -p "  lab@lab188:~$ " cmd1
    echo
    [[ "$cmd1" != "touch /tmp/perm_file1" ]] && {
        print_error "Use: touch /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  File created."
    echo

    echo "  Step 2: Show the current permissions on $F."
    read -p "  lab@lab188:~$ " cmd2
    echo
    [[ "$cmd2" != "ls -l /tmp/perm_file1" ]] && {
        print_error "Use: ls -l /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    print_ls_sim
    echo

    echo "  Step 3: Give the owner execute permission on $F."
    read -p "  lab@lab188:~$ " cmd3
    echo
    [[ "$cmd3" != "chmod u+x /tmp/perm_file1" ]] && {
        print_error "Use: chmod u+x /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_MODE="-rwxr--r--"
    SIM_OCTAL="744"

    echo "  Permissions updated."
    echo

    echo "  Step 4: Verify the updated permissions."
    read -p "  lab@lab188:~$ " cmd4
    echo
    [[ "$cmd4" != "ls -l /tmp/perm_file1" ]] && {
        print_error "Use: ls -l /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    print_ls_sim
    echo

    echo "  Step 5: Add write permission for the group."
    read -p "  lab@lab188:~$ " cmd5
    echo
    [[ "$cmd5" != "chmod g+w /tmp/perm_file1" ]] && {
        print_error "Use: chmod g+w /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_MODE="-rwxrw-r--"
    SIM_OCTAL="764"

    echo "  Permissions updated."
    echo

    echo "  Step 6: Verify the new permissions using numeric format."
    read -p "  lab@lab188:~$ " cmd6
    echo
    [[ "$cmd6" != "stat -c %a /tmp/perm_file1" ]] && {
        print_error "Use: stat -c %a /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  $SIM_OCTAL"
    echo

    echo "  Step 7: Set the permissions on $F to 640 using numeric mode."
    read -p "  lab@lab188:~$ " cmd7
    echo
    [[ "$cmd7" != "chmod 640 /tmp/perm_file1" ]] && {
        print_error "Use: chmod 640 /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    SIM_MODE="-rw-r-----"
    SIM_OCTAL="640"

    echo "  Permissions updated."
    echo

    echo "  Step 8: Verify the final permissions with a long listing."
    read -p "  lab@lab188:~$ " cmd8
    echo
    [[ "$cmd8" != "ls -l /tmp/perm_file1" ]] && {
        print_error "Use: ls -l /tmp/perm_file1"
        read -p "Press Enter to try again..." _
        continue
    }

    print_ls_sim
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
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