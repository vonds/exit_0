#!/bin/bash

# Lab 72: Creating a Local Package Repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 72: Creating a Local Package Repository"
LAB_ID="lab72"
LAB_XP=2250
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

REPO_DIR="/var/www/html/repo"

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
  center_text "Scenario: Create local RPM, APT, and pacman repositories for custom packages."
  echo
  center_text "Press Enter to begin the lab..."
  read _

  draw_lab_ui
  echo "  Step 1: Prepare a local RPM repository."
  echo "  - Repo path: /var/www/html/repo"
  echo "  - In ONE line, create the directory (including parents) and copy all .rpm files there."
  echo
  read -p "  lab@lpic-lab72:~$ " cmd1
  echo
  [[ "$cmd1" != "mkdir -p /var/www/html/repo && cp *.rpm /var/www/html/repo" ]] && {
    print_error "  The command must both create /var/www/html/repo and copy all .rpm files there in a single line."
    read -p "  Press Enter to try again..." _
    continue
  }
  echo "  Repository directory created and RPM files copied."
  echo

  echo "  Step 2: Initialize RPM repository metadata."
  echo "  - Use the standard RPM repo metadata tool."
  echo "  - Run it against: /var/www/html/repo in ONE command."
  echo
  read -p "  lab@lpic-lab72:~$ " cmd2
  echo
  [[ "$cmd2" != "createrepo /var/www/html/repo" ]] && {
    print_error "  You must generate metadata for /var/www/html/repo using the repo metadata tool in one command."
    read -p "  Press Enter to try again..." _
    continue
  }
  echo "  Spawning worker 0 with 1 pkgs"
  echo "  Workers finished"
  echo "  Saving Primary metadata"
  echo "  Repo created successfully."
  echo

  echo "  Step 3: Prepare a local APT repository."
  echo "  - Repo path: /srv/aptrepo"
  echo "  - In ONE line, create the directory (including parents) and copy all .deb files there."
  echo
  read -p "  lab@lpic-lab72:~$ " cmd3
  echo
  [[ "$cmd3" != "mkdir -p /srv/aptrepo && cp *.deb /srv/aptrepo" ]] && {
    print_error "  The command must create /srv/aptrepo and copy all .deb files there in a single line."
    read -p "  Press Enter to try again..." _
    continue
  }
  echo "  APT repository folder populated."
  echo

  echo "  Step 4: Generate APT package index."
  echo "  - Scan /srv/aptrepo for .deb files with the APT index tool."
  echo "  - Pipe output to gzip with -9 and redirect to /srv/aptrepo/Packages.gz in ONE pipeline."
  echo
  read -p "  lab@lpic-lab72:~$ " cmd4
  echo
  [[ "$cmd4" != "dpkg-scanpackages /srv/aptrepo /dev/null | gzip -9 > /srv/aptrepo/Packages.gz" ]] && {
    print_error "  You must scan /srv/aptrepo, gzip the output, and save it as /srv/aptrepo/Packages.gz in a single pipeline."
    read -p "  Press Enter to try again..." _
    continue
  }
  echo "  Package list generated and compressed for apt indexing."
  echo

  echo "  Step 5: Create/update a pacman repository database."
  echo "  - All pacman packages are in the current directory as *.pkg.tar.zst"
  echo "  - Use the pacman repo tool to create/update myrepo.db.tar.gz and add all *.pkg.tar.zst in ONE command."
  echo
  read -p "  lab@lpic-lab72:~$ " cmd5
  echo
  [[ "$cmd5" != "repo-add myrepo.db.tar.gz *.pkg.tar.zst" ]] && {
    print_error "  You must use the pacman repo tool to update myrepo.db.tar.gz with all *.pkg.tar.zst in a single command."
    read -p "  Press Enter to try again..." _
    continue
  }
  echo "  :: Creating 'myrepo.db.tar.gz' database..."
  echo "  :: Adding package 'custompkg-1.0-1-x86_64.pkg.tar.zst'"
  echo "  Repo index updated."
  echo

  print_success "  Lab complete."
  print_info   "  You earned 2250 XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "  You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice

  [[ "$post_choice" == "2" ]] && exit 0
done
