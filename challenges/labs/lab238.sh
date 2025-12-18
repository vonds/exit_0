#!/bin/bash

# Lab 238: DNF Module Management — PostgreSQL stream 10 (default profile) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real system changes occur.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 238: Module mgmt (PostgreSQL stream 10, default profile)"
LAB_ID="lab238"
LAB_XP=20850
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PKG_SERVER="postgresql-server"

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
  center_text "Goal: Inspect PostgreSQL module streams, enable stream 10, install its default profile,"
  center_text "verify installation/status, and understand how to reset/disable (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: List available streams for PostgreSQL
  draw_lab_ui
  echo "  Step 1: List available module streams for PostgreSQL."
  read -p "  lab@lab238:~$ " cmd1
  if [[ "$cmd1" == "dnf module list postgresql" || "$cmd1" == "yum module list postgresql" ]]; then
    echo "  Last metadata expiration check: 0:01:42 ago."
    echo "  CentOS Stream 8 - AppStream Modules"
    echo "  Name        Stream     Profiles                              Summary"
    echo "  postgresql  9.6        client, server [d]                    PostgreSQL server and client module"
    echo "  postgresql  10         client, server [d]                    PostgreSQL server and client module"
    echo "  postgresql  12         client, server [d]                    PostgreSQL server and client module"
    echo "  Hint: [d] = default profile; no stream enabled yet."
  else
    print_error "Hint: Use the package manager's module subcommand to list streams for PostgreSQL."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Show info about stream 10 (profiles & defaults)
  echo "  Step 2: Show detailed information for the PostgreSQL stream 10."
  read -p "  lab@lab238:~$ " cmd2
  if [[ "$cmd2" == "dnf module info postgresql:10" || "$cmd2" == "yum module info postgresql:10" ]]; then
    echo "  Name        : postgresql"
    echo "  Stream      : 10"
    echo "  Profiles    : client, server [d]"
    echo "  Summary     : PostgreSQL server and client module"
    echo "  Description : The PostgreSQL object-relational database system."
  else
    print_error "Hint: Inspect module details for stream 10 with the module info subcommand."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Enable stream 10
  echo "  Step 3: Enable the PostgreSQL stream 10."
  read -p "  lab@lab238:~$ " cmd3
  if [[ "$cmd3" == "dnf module enable -y postgresql:10" || "$cmd3" == "dnf module enable postgresql:10" || \
        "$cmd3" == "yum module enable -y postgresql:10"  || "$cmd3" == "yum module enable postgresql:10" ]]; then
    echo "  Enabling module streams:"
    echo "   postgresql:10"
    echo "  Complete!"
  else
    print_error "Hint: Use the module enable subcommand to activate stream 10."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Install default profile for stream 10 (accept plain or explicit profile)
  echo "  Step 4: Install the default profile for stream 10."
  read -p "  lab@lab238:~$ " cmd4
  if [[ "$cmd4" == "dnf module install -y postgresql:10" || "$cmd4" == "dnf module install postgresql:10" || \
        "$cmd4" == "dnf module install -y postgresql:10/server" || "$cmd4" == "dnf module install postgresql:10/server" || \
        "$cmd4" == "yum module install -y postgresql:10" || "$cmd4" == "yum module install postgresql:10" || \
        "$cmd4" == "yum module install -y postgresql:10/server" || "$cmd4" == "yum module install postgresql:10/server" ]]; then
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package               Arch     Version               Repository      Size"
    echo "  ================================================================================"
    echo "  Installing group/module packages:"
    echo "   postgresql            x86_64   10.23-1.module       AppStream       1.5 M"
    echo "   postgresql-server     x86_64   10.23-1.module       AppStream       5.2 M"
    echo "   libpq                 x86_64   10.23-1.module       AppStream       190 k"
    echo
    echo "  Installed:"
    echo "    postgresql-server-10.23-1.module.x86_64"
    echo "    postgresql-10.23-1.module.x86_64"
    echo "    libpq-10.23-1.module.x86_64"
  else
    print_error "Hint: Use the module install subcommand for stream 10 (default profile installs the server bits)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Verify module status shows stream enabled and profile installed
  echo "  Step 5: Verify the module shows stream 10 enabled and a profile installed."
  read -p "  lab@lab238:~$ " cmd5
  if [[ "$cmd5" == "dnf module list postgresql" || "$cmd5" == "dnf module list --installed" || \
        "$cmd5" == "yum module list postgresql" || "$cmd5" == "yum module list --installed" ]]; then
    echo "  Name        Stream     Profiles                 Summary"
    echo "  postgresql  10 [e]     client, server [d]       PostgreSQL server and client module"
    echo "  Hint: [e] = enabled stream; default profile installed."
  else
    print_error "Hint: List modules again to confirm the enabled stream and installed profile."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Verify key package presence
  echo "  Step 6: Confirm server package from the module is present."
  read -p "  lab@lab238:~$ " cmd6
  if [[ "$cmd6" == "rpm -q postgresql-server" || "$cmd6" == "rpm -q ${PKG_SERVER}" ]]; then
    echo "  postgresql-server-10.23-1.module.x86_64"
  else
    print_error "Hint: Query your RPM database for the server package."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: (Knowledge) Show how to reset/disable the module (no changes performed)
  echo "  Step 7: (Knowledge) Display the commands to reset/disable the module (no action taken)."
  read -p "  lab@lab238:~$ " cmd7
  if [[ "$cmd7" == "echo 'dnf module reset postgresql && dnf module disable postgresql'" || "$cmd7" == "true" ]]; then
    echo "  Example commands:"
    echo "   dnf module reset postgresql"
    echo "   dnf module disable postgresql"
  else
    print_error "Hint: Provide the two commands (reset, then disable) as an example without running them."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! Stream 10 enabled, default profile installed, and status verified (simulated)."
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
