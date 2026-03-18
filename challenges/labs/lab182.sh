#!/bin/bash

# Lab 182: Configure autofs for On-Demand NFS Mounts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 182: Configure autofs for On-Demand NFS Mounts"
LAB_ID="lab182"
LAB_XP=50000
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
    echo; echo; echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Developers need access to an NFS share,"
    center_text "but it should mount only when accessed."
    center_text "Goal: Configure autofs so /projects/dev automatically" 
    center_text "mounts from serverb.lab.example.com on demand."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the autofs package."
    read -p "  [rhel@lab182 ~]\$ " cmd1
    echo
    if [[ "$cmd1" != "sudo dnf install -y autofs" ]]; then
        print_error "Incorrect. Try again. (Use: sudo dnf install -y autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Updating Subscription Management repositories."
    echo "  Package autofs-5.1.7-62.el9.x86_64 is already installed."
    echo "  Dependencies resolved."
    echo "  Nothing to do."
    echo "  Complete!"
    echo

    echo "  Step 2: Review the autofs master map."
    read -p "  [rhel@lab182 ~]\$ " cmd2
    echo
    if [[ "$cmd2" != "cat /etc/auto.master" ]]; then
        print_error "Incorrect. Try again. (Use: cat /etc/auto.master)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  # Sample auto.master file"
    echo "  +dir:/etc/auto.master.d"
    echo

    echo "  Step 3: Create an indirect map entry so /projects is managed by autofs."
    read -p "  [rhel@lab182 ~]\$ " cmd3
    echo
    if [[ "$cmd3" != "echo '/projects /etc/auto.projects' | sudo tee /etc/auto.master.d/projects.autofs" ]]; then
        print_error "Incorrect. Try again. (Use: echo '/projects /etc/auto.projects' | sudo tee /etc/auto.master.d/projects.autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /projects /etc/auto.projects"
    echo

    echo "  Step 4: Create the autofs map so the key 'dev' mounts the NFS export."
    read -p "  [rhel@lab182 ~]\$ " cmd4
    echo
    if [[ "$cmd4" != "echo 'dev -rw,sync serverb.lab.example.com:/exports/dev' | sudo tee /etc/auto.projects" ]]; then
        print_error "Incorrect. Try again. (Use: echo 'dev -rw,sync serverb.lab.example.com:/exports/dev' | sudo tee /etc/auto.projects)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dev -rw,sync serverb.lab.example.com:/exports/dev"
    echo

    echo "  Step 5: Verify the custom master map entry."
    read -p "  [rhel@lab182 ~]\$ " cmd5
    echo
    if [[ "$cmd5" != "cat /etc/auto.master.d/projects.autofs" ]]; then
        print_error "Incorrect. Try again. (Use: cat /etc/auto.master.d/projects.autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /projects /etc/auto.projects"
    echo

    echo "  Step 6: Verify the indirect map file."
    read -p "  [rhel@lab182 ~]\$ " cmd6
    echo
    if [[ "$cmd6" != "cat /etc/auto.projects" ]]; then
        print_error "Incorrect. Try again. (Use: cat /etc/auto.projects)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dev -rw,sync serverb.lab.example.com:/exports/dev"
    echo

    echo "  Step 7: Enable and start the autofs service."
    read -p "  [rhel@lab182 ~]\$ " cmd7
    echo
    if [[ "$cmd7" != "sudo systemctl enable --now autofs" ]]; then
        print_error "Incorrect. Try again. (Use: sudo systemctl enable --now autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Created symlink /etc/systemd/system/multi-user.target.wants/autofs.service → /usr/lib/systemd/system/autofs.service."
    echo

    echo "  Step 8: Confirm autofs is active."
    read -p "  [rhel@lab182 ~]\$ " cmd8
    echo
    if [[ "$cmd8" != "systemctl status autofs" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl status autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● autofs.service - Automounts filesystems on demand"
    echo "       Loaded: loaded (/usr/lib/systemd/system/autofs.service; enabled)"
    echo "       Active: active (running)"
    echo

    echo "  Step 9: Check whether /projects/dev is mounted before access."
    read -p "  [rhel@lab182 ~]\$ " cmd9
    echo
    if [[ "$cmd9" != "mount | grep /projects/dev" ]]; then
        print_error "Incorrect. Try again. (Use: mount | grep /projects/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 10: Trigger the automount by listing the directory."
    read -p "  [rhel@lab182 ~]\$ " cmd10
    echo
    if [[ "$cmd10" != "ls /projects/dev" ]]; then
        print_error "Incorrect. Try again. (Use: ls /projects/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  app"
    echo "  builds"
    echo "  docs"
    echo "  shared"
    echo

    echo "  Step 11: Verify that the NFS export is now mounted on demand."
    read -p "  [rhel@lab182 ~]\$ " cmd11
    echo
    if [[ "$cmd11" != "mount | grep /projects/dev" ]]; then
        print_error "Incorrect. Try again. (Use: mount | grep /projects/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  serverb.lab.example.com:/exports/dev on /projects/dev type nfs4 (rw,relatime,sync)"
    echo

    echo "  Step 12: Confirm the automounted path with findmnt."
    read -p "  [rhel@lab182 ~]\$ " cmd12
    echo
    if [[ "$cmd12" != "findmnt /projects/dev" ]]; then
        print_error "Incorrect. Try again. (Use: findmnt /projects/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  TARGET        SOURCE                                   FSTYPE OPTIONS"
    echo "  /projects/dev serverb.lab.example.com:/exports/dev    nfs4   rw,relatime,sync"
    echo

    echo "  Step 13: Check recent autofs log messages."
    read -p "  [rhel@lab182 ~]\$ " cmd13
    echo
    if [[ "$cmd13" != "journalctl -u autofs --no-pager -n 5" ]]; then
        print_error "Incorrect. Try again. (Use: journalctl -u autofs --no-pager -n 5)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Mar 12 automount: key \"dev\" matched map entry"
    echo "  Mar 12 automount: mounted /projects/dev"
    echo

    echo "  Step 14: Reload autofs after configuration validation."
    read -p "  [rhel@lab182 ~]\$ " cmd14
    echo
    if [[ "$cmd14" != "sudo systemctl reload autofs" ]]; then
        print_error "Incorrect. Try again. (Use: sudo systemctl reload autofs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 15: Final verification that the indirect map is registered."
    read -p "  [rhel@lab182 ~]\$ " cmd15
    echo
    if [[ "$cmd15" != "automount -m" ]]; then
        print_error "Incorrect. Try again. (Use: automount -m)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Mount point: /projects"
    echo "   map: /etc/auto.projects"
    echo "    dev | -rw,sync serverb.lab.example.com:/exports/dev"
    echo

    print_success "Nice work!"
    print_info "You configured autofs to mount an NFS share only when accessed."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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