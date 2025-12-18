#!/bin/bash

# Lab 125: YUM/DNF Repository Configuration (/etc/yum.repos.d/*.repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 125: YUM/DNF Repository Configuration"
LAB_ID="lab125"
LAB_XP=3200
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

# Helpers for accepting yum or dnf variants
is_repolist_enabled() {
  [[ "$1" == "yum repolist enabled" || "$1" == "dnf repolist enabled" || "$1" == "sudo yum repolist enabled" || "$1" == "sudo dnf repolist enabled" ]]
}
is_repolist_all_grep_custom() {
  [[ "$1" == "dnf repolist all | grep custom-utils" || "$1" == "yum repolist all | grep custom-utils" || \
     "$1" == "sudo dnf repolist all | grep custom-utils" || "$1" == "sudo yum repolist all | grep custom-utils" ]]
}
is_makecache() {
  [[ "$1" == "yum makecache" || "$1" == "sudo yum makecache" || "$1" == "dnf makecache" || "$1" == "sudo dnf makecache" ]]
}
is_clean_all() {
  [[ "$1" == "yum clean all" || "$1" == "sudo yum clean all" || "$1" == "dnf clean all" || "$1" == "sudo dnf clean all" ]]
}
is_disable_repo() {
  [[ "$1" == "dnf config-manager --set-disabled custom-utils" || "$1" == "sudo dnf config-manager --set-disabled custom-utils" || \
     "$1" == "yum-config-manager --disable custom-utils" || "$1" == "sudo yum-config-manager --disable custom-utils" || \
     "$1" == "sudo sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/custom-utils.repo" ]]
}
is_enable_repo() {
  [[ "$1" == "dnf config-manager --set-enabled custom-utils" || "$1" == "sudo dnf config-manager --set-enabled custom-utils" || \
     "$1" == "yum-config-manager --enable custom-utils" || "$1" == "sudo yum-config-manager --enable custom-utils" || \
     "$1" == "sudo sed -i 's/^enabled=0/enabled=1/' /etc/yum.repos.d/custom-utils.repo" ]]
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Configure repositories on an RPM-based system."
    center_text "List repo files, inspect settings, add a custom repo, refresh metadata, enable/disable, and verify."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: List repository definition files under /etc/yum.repos.d."
    read -p "  lab@lpic-lab125:~$ " cmd1
    echo
    [[ "$cmd1" != "ls -1 /etc/yum.repos.d" ]] && {
        print_error "Incorrect. Use: ls -1 /etc/yum.repos.d"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "base.repo"
    echo "appstream.repo"
    echo "extras.repo"
    echo

    echo "  Step 2: Show enabled repositories."
    read -p "  lab@lpic-lab125:~$ " cmd2
    echo
    if ! is_repolist_enabled "$cmd2"; then
        print_error "Incorrect. Use: dnf repolist enabled   or   yum repolist enabled"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "repo id                 repo name"
    echo "appstream               AppStream"
    echo "baseos                  BaseOS"
    echo "extras                  Extras"
    echo

    echo "  Step 3: Display key settings (name, baseurl, enabled, gpgcheck) from all repo files."
    read -p "  lab@lpic-lab125:~$ " cmd3
    echo
    if [[ "$cmd3" != "grep -E '^(\\[|name=|baseurl=|enabled=|gpgcheck=)' /etc/yum.repos.d/*.repo" && \
          "$cmd3" != "egrep '^(\\[|name=|baseurl=|enabled=|gpgcheck=)' /etc/yum.repos.d/*.repo" ]]; then
        print_error "Incorrect. Example: grep -E '^(\\[|name=|baseurl=|enabled=|gpgcheck=)' /etc/yum.repos.d/*.repo"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "[baseos]"
    echo "name=BaseOS"
    echo "baseurl=http://mirror.example/baseos/$releasever/$basearch/os/"
    echo "enabled=1"
    echo "gpgcheck=1"
    echo

    echo "  Step 4: Create a new repository file named custom-utils.repo."
    echo "          Use printf piped to sudo tee with enabled=1 and gpgcheck=0."
    read -p "  lab@lpic-lab125:~$ " cmd4
    echo
    EXPECT="printf \"[custom-utils]\nname=Custom Utils\nbaseurl=http://example.com/repos/el9/\$basearch/\nenabled=1\ngpgcheck=0\n\" | sudo tee /etc/yum.repos.d/custom-utils.repo"
    if [[ "$cmd4" != "$EXPECT" ]]; then
        print_error "Incorrect. Use: $EXPECT"
        read -p "Press Enter to try again..." _
        continue
    fi
    printf "[custom-utils]\nname=Custom Utils\nbaseurl=http://example.com/repos/el9/\$basearch/\nenabled=1\ngpgcheck=0\n"
    echo

    echo "  Step 5: Refresh repository metadata."
    read -p "  lab@lpic-lab125:~$ " cmd5
    echo
    if ! is_makecache "$cmd5"; then
        print_error "Incorrect. Use: dnf makecache   or   yum makecache"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Custom Utils                               100% |  30 kB  00:00"
    echo "Metadata cache created."
    echo

    echo "  Step 6: Verify that custom-utils appears in the repo list."
    read -p "  lab@lpic-lab125:~$ " cmd6
    echo
    if ! is_repolist_all_grep_custom "$cmd6"; then
        print_error "Incorrect. Example: dnf repolist all | grep custom-utils"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "custom-utils          Custom Utils                         enabled"
    echo

    echo "  Step 7: Disable the custom-utils repository."
    read -p "  lab@lpic-lab125:~$ " cmd7
    echo
    if ! is_disable_repo "$cmd7"; then
        print_error "Incorrect. Use: dnf config-manager --set-disabled custom-utils   or   yum-config-manager --disable custom-utils"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Repository 'custom-utils' disabled."
    echo

    echo "  Step 8: Confirm the repo is disabled by checking its file."
    read -p "  lab@lpic-lab125:~$ " cmd8
    echo
    if [[ "$cmd8" != "grep '^enabled=' /etc/yum.repos.d/custom-utils.repo" ]]; then
        print_error "Incorrect. Use: grep '^enabled=' /etc/yum.repos.d/custom-utils.repo"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "enabled=0"
    echo

    echo "  Step 9: Re-enable the custom-utils repository."
    read -p "  lab@lpic-lab125:~$ " cmd9
    echo
    if ! is_enable_repo "$cmd9"; then
        print_error "Incorrect. Use: dnf config-manager --set-enabled custom-utils   or   yum-config-manager --enable custom-utils"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Repository 'custom-utils' enabled."
    echo

    echo "  Step 10: Clean cached data to force fresh downloads next time."
    read -p "  lab@lpic-lab125:~$ " cmd10
    echo
    if ! is_clean_all "$cmd10"; then
        print_error "Incorrect. Use: dnf clean all   or   yum clean all"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Cleaning repos: baseos appstream extras custom-utils"
    echo "Cleaning up everything."
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
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
