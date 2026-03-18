#!/bin/bash

# Lab 180: Configure autofs for On-Demand NFS Mounts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 180: Configure autofs for On-Demand NFS Mounts"
LAB_ID="lab180"
LAB_XP=12000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
    echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Developers need an NFS share mounted on demand at /projects."
    center_text "Goal: Configure autofs with an indirect map, start the service,"
    center_text "trigger the mount, and verify the share is mounted automatically."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Verify that the autofs package is installed."
    read -p "  root@servera:~# " cmd1
    echo
    if [[ "$cmd1" != "rpm -q autofs" ]]; then
        print_error "Incorrect. Try again. (Use: rpm -q autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  autofs-5.1.7-58.el9.x86_64"
    echo

    echo "  Step 2: Inspect the active entries in the autofs master map."
    read -p "  root@servera:~# " cmd2
    echo
    if [[ "$cmd2" != "grep -vE '^(#|$)' /etc/auto.master" ]]; then
        print_error "Incorrect. Try again. (Use: grep -vE '^(#|$)' /etc/auto.master)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /misc   /etc/auto.misc"
    echo "  /net    -hosts"
    echo

    echo "  Step 3: Add an indirect map so autofs manages /projects using /etc/auto.projects."
    read -p "  root@servera:~# " cmd3
    echo
    if [[ "$cmd3" != "echo '/projects /etc/auto.projects' >> /etc/auto.master" ]]; then
        print_error "Incorrect. Try again. (Use: echo '/projects /etc/auto.projects' >> /etc/auto.master)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 4: Create the map entry so /projects/dev mounts from the NFS export."
    read -p "  root@servera:~# " cmd4
    echo
    if [[ "$cmd4" != "echo 'dev -fstype=nfs4,rw,sync serverb.lab.example.com:/exports/projects/dev' > /etc/auto.projects" ]]; then
        print_error "Incorrect. Try again. (Use: echo 'dev -fstype=nfs4,rw,sync serverb.lab.example.com:/exports/projects/dev' > /etc/auto.projects)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 5: Enable and start the autofs service."
    read -p "  root@servera:~# " cmd5
    echo
    if [[ "$cmd5" != "systemctl enable --now autofs" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl enable --now autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Created symlink /etc/systemd/system/multi-user.target.wants/autofs.service → /usr/lib/systemd/system/autofs.service."
    echo

    echo "  Step 6: Access the mount point to trigger the automount."
    read -p "  root@servera:~# " cmd6
    echo
    if [[ "$cmd6" != "ls /projects/dev" ]]; then
        print_error "Incorrect. Try again. (Use: ls /projects/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  README.md"
    echo "  build-scripts"
    echo "  releases"
    echo

    echo "  Step 7: Verify that the NFS share is now mounted by autofs."
    read -p "  root@servera:~# " cmd7
    echo
    if [[ "$cmd7" != "mount | grep /projects/dev" ]]; then
        print_error "Incorrect. Try again. (Use: mount | grep /projects/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  serverb.lab.example.com:/exports/projects/dev on /projects/dev type nfs4"
    echo "  (rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.10,local_lock=none,addr=192.168.122.20)"
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