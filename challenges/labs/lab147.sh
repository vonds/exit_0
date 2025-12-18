#!/bin/bash

# Lab 147: User and Group Administration (tsuli Account)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 147: User and Group Administration"
LAB_ID="lab147"
LAB_XP=20000
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
    center_text "In this lab, you'll practice creating a user, checking IDs and"
    center_text "groups, reviewing password aging, and inspecting security files."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a new user account named tsuli and ensure it has a home directory created automatically."
    read -p "  lab@lpic-lab147:~$ " cmd1
    echo
    [[ "$cmd1" != "useradd -m tsuli" ]] && {
        print_error "Incorrect. Use: useradd -m tsuli"
        read -p "Press Enter to try again..." _
        continue
    }
    # no output on success

    echo "  Step 1b: Identify UID, GID, and shell of tsuli."
    read -p "  lab@lpic-lab147:~$ " cmd1b
    echo
    [[ "$cmd1b" != "id tsuli" ]] && {
        print_error "Incorrect. Use: id tsuli"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  uid=1002(tsuli) gid=1002(tsuli) groups=1002(tsuli)"
    echo

    echo "  Step 2: Identify the name of Tsuli’s primary group."
    read -p "  lab@lpic-lab147:~$ " cmd2
    echo
    [[ "$cmd2" != "id -gn tsuli" ]] && {
        print_error "Incorrect. Use: id -gn tsuli"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tsuli"
    echo

    echo "  Step 3: Review password aging info for tsuli with getent."
    read -p "  lab@lpic-lab147:~$ " cmd3
    echo
    [[ "$cmd3" != "getent shadow tsuli" ]] && {
        print_error "Incorrect. Use: getent shadow tsuli"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tsuli:\$6\$somehash:19700:0:99999:7:::"
    echo

    echo "  Step 4a: Add tsuli to groups editor and devops."
    read -p "  lab@lpic-lab147:~$ " cmd4a
    echo
    [[ "$cmd4a" != "usermod -aG editor,devops tsuli" ]] && {
        print_error "Incorrect. Use: usermod -aG editor,devops tsuli"
        read -p "Press Enter to try again..." _
        continue
    }
    # no output on success

    echo "  Step 4b: Verify group membership of editor."
    read -p "  lab@lpic-lab147:~$ " cmd4b
    echo
    [[ "$cmd4b" != "getent group editor" ]] && {
        print_error "Incorrect. Use: getent group editor"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  editor:x:1005:emma,dave,tsuli"
    echo

    echo "  Step 5: List passwd/group/shadow/gshadow and review permissions."
    read -p "  lab@lpic-lab147:~$ " cmd5
    echo
    [[ "$cmd5" != "ls -l /etc/passwd /etc/group /etc/shadow /etc/gshadow" ]] && {
        print_error "Incorrect. Use: ls -l /etc/passwd /etc/group /etc/shadow /etc/gshadow"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -rw-r--r-- 1 root root   2450 Sep 10 10:30 /etc/passwd"
    echo "  -rw-r--r-- 1 root root   1200 Sep 10 10:30 /etc/group"
    echo "  -rw------- 1 root shadow 1700 Sep 10 10:30 /etc/shadow"
    echo "  -rw-r----- 1 root shadow  600 Sep 10 10:30 /etc/gshadow"
    echo

    print_success "Excellent work!"
    print_info "You earned $LAB_XP XP for completing this lab!"
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
