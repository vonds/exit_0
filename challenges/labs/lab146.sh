#!/bin/bash

# Lab 146: Administrative Tasks (Set 2)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Administrative Tasks: Set 2"
LAB_ID="lab146"
LAB_XP=65500
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

accept_cmd() {
  # Accept command either bare or with sudo (first token)
  local input="$1"; shift
  for candidate in "$@"; do
    if [[ "$input" == "$candidate" || "$input" == "sudo $candidate" ]]; then
      return 0
    fi
  done
  return 1
}

while true; do
    emma_secondary_done=false

    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Practice Linux user and group administration tasks. (Set 2)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1a: Create the group 'administrators'."
    read -p "  lab@lab146:~$ " cmd1a
    if ! accept_cmd "$cmd1a" "groupadd administrators"; then
        print_error "Incorrect. Use: groupadd administrators"
        read -p "Press Enter to retry..." _
        continue
    fi
    # groupadd: no output on success

    echo
    echo "  Step 1b: Create the group 'developers'."
    read -p "  lab@lab146:~$ " cmd1b
    if ! accept_cmd "$cmd1b" "groupadd developers"; then
        print_error "Incorrect. Use: groupadd developers"
        read -p "Press Enter to retry..." _
        continue
    fi
    # groupadd: no output on success

    echo
    echo "  Step 2a: Create user 'kevin' and add them to the secondary groups administrators and developers."
    read -p "  lab@lab146:~$ " cmd2a
    if ! accept_cmd "$cmd2a" "useradd -G administrators,developers kevin"; then
        print_error "Incorrect. Use: useradd -G administrators,developers kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    # useradd: no output on success

    echo
    echo "  Step 2b: Which files are typically affected by user creation?"
    read -p "  lab@lab146:~$ " cmd2b
    if [[ "$cmd2b" != "/etc/passwd,/etc/shadow,/etc/group" && \
          "$cmd2b" != "/etc/passwd,/etc/shadow,/etc/group,/etc/gshadow" ]]; then
        print_error "Tip: Commonly: /etc/passwd,/etc/shadow,/etc/group,/etc/gshadow"
        read -p "Press Enter to continue..." _
    fi
    # informational: no system output

    echo
    echo "  Step 3a: Create a group named 'designers'."
    read -p "  lab@lab146:~$ " cmd3a
    if ! accept_cmd "$cmd3a" "groupadd designers"; then
        print_error "Incorrect. Use: groupadd designers"
        read -p "Press Enter to retry..." _
        continue
    fi
    # groupadd: no output

    echo
    echo "  Step 3b: Rename 'designers' to 'web-designers'."
    read -p "  lab@lab146:~$ " cmd3b
    if ! accept_cmd "$cmd3b" "groupmod -n web-designers designers"; then
        print_error "Incorrect. Use: groupmod -n web-designers designers"
        read -p "Press Enter to retry..." _
        continue
    fi
    # groupmod: no output

    echo
    echo "  Step 3c: Add 'kevin' to the 'web-designers' group (as a secondary group)."
    read -p "  lab@lab146:~$ " cmd3c
    if ! accept_cmd "$cmd3c" "usermod -aG web-designers kevin"; then
        print_error "Incorrect. Use: usermod -aG web-designers kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    # usermod: no output

    echo
    echo "  Step 4a: Remove ONLY the 'developers' group from 'kevin'’s secondary groups."
    read -p "  lab@lab146:~$ " cmd4a
    if ! accept_cmd "$cmd4a" "gpasswd -d kevin developers"; then
        print_error "Incorrect. Use: gpasswd -d kevin developers"
        read -p "Press Enter to retry..." _
        continue
    fi
    # gpasswd -d prints a confirmation line
    echo "  Removing user kevin from group developers"

    echo
    echo "  Step 4b: Which command shows 'kevin'’s current group memberships?"
    read -p "  lab@lab146:~$ " cmd4b
    if [[ "$cmd4b" != "id kevin" ]]; then
        print_error "Tip: Use: id kevin"
        read -p "Press Enter to continue..." _
    else
        echo
        # Simulated id output (example UIDs/GIDs)
        echo "  uid=1001(kevin) gid=1001(kevin) groups=1001(kevin),1000(administrators),1003(web-designers)"
    fi

    echo
    echo "  Step 5: Set the password for user 'kevin'."
    read -p "  lab@lab146:~$ " cmd5
    if ! accept_cmd "$cmd5" "passwd kevin"; then
        print_error "Incorrect. Use: passwd kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo
    # passwd shows interactive prompts
    echo "  Changing password for user kevin."
    echo "  New password:"
    echo "  Retype new password:"
    echo "  passwd: all authentication tokens updated successfully."

    echo
    echo "  Step 6a: Check the expiry date of the 'kevin' account."
    read -p "  lab@lab146:~$ " cmd6a
    if ! accept_cmd "$cmd6a" "chage -l kevin"; then
        print_error "Incorrect. Use: chage -l kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo
    # chage -l prints account aging info (pre-expire example)
    echo "  Last password change                                    : Aug 20, 2025"
    echo "  Password expires                                        : never"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : never"
    echo "  Minimum number of days between password change          : 0"
    echo "  Maximum number of days between password change          : 99999"
    echo "  Number of days of warning before password expires       : 7"

    echo
    echo "  Step 6b: Set the account expiration date to Dec 31, 2022 using chage."
    read -p "  lab@lab146:~$ " cmd6b
    if ! accept_cmd "$cmd6b" "chage -E 2022-12-31 kevin" "chage --expiredate 2022-12-31 kevin"; then
        print_error "Incorrect. Use: chage -E 2022-12-31 kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    # chage -E: no output on success

    echo
    echo "  Step 6c: Provide ANOTHER valid command that would set the same expiration date."
    read -p "  lab@lab146:~$ " cmd6c
    if [[ "$cmd6c" != "usermod -e 2022-12-31 kevin" && "$cmd6c" != "usermod --expiredate 2022-12-31 kevin" ]]; then
        print_error "Incorrect. For example: usermod -e 2022-12-31 kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    # informational alternative: no output

    echo
    echo "  Step 7a: Create a new user 'emma' with UID 1050 and primary group 'administrators'."
    read -p "  lab@lab146:~$ " cmd7a
    if accept_cmd "$cmd7a" "useradd -u 1050 -g administrators emma"; then
        created_emma_primary=true
    elif accept_cmd "$cmd7a" "useradd -u 1050 -g administrators -G developers,web-designers emma"; then
        created_emma_primary=true
        emma_secondary_done=true
    else
        print_error "Incorrect. Use, e.g.: useradd -u 1050 -g administrators emma"
        read -p "Press Enter to retry..." _
        continue
    fi
    # useradd: no output

    if [[ "$emma_secondary_done" != "true" ]]; then
      echo
      echo "  Step 7b: Add 'emma' to the secondary groups 'developers' and 'web-designers'."
      read -p "  lab@lab146:~$ " cmd7b
      if ! accept_cmd "$cmd7b" "usermod -aG developers,web-designers emma"; then
          print_error "Incorrect. Use: usermod -aG developers,web-designers emma"
          read -p "Press Enter to retry..." _
          continue
      fi
      # usermod: no output
    fi

    echo
    echo "  Step 8: Change 'emma'’s login shell to /bin/sh."
    read -p "  lab@lab146:~$ " cmd8
    if ! accept_cmd "$cmd8" "usermod -s /bin/sh emma"; then
        print_error "Incorrect. Use: usermod -s /bin/sh emma"
        read -p "Press Enter to retry..." _
        continue
    fi
    # usermod: no output

    echo
    echo "  Step 9a: Delete the user 'emma' and their home directory."
    read -p "  lab@lab146:~$ " cmd9a
    if ! accept_cmd "$cmd9a" "userdel -r emma"; then
        print_error "Incorrect. Use: userdel -r emma"
        read -p "Press Enter to retry..." _
        continue
    fi
    # userdel -r: no output

    echo
    echo "  Step 9b: Delete the user 'kevin' and their home directory."
    read -p "  lab@lab146:~$ " cmd9b
    if ! accept_cmd "$cmd9b" "userdel -r kevin"; then
        print_error "Incorrect. Use: userdel -r kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    # userdel -r: no output

    echo
    echo "  Step 9c: Delete the groups 'administrators', 'developers', and 'web-designers'."
    read -p "  lab@lab146:~$ " cmd9c
    if ! accept_cmd "$cmd9c" "groupdel administrators && groupdel developers && groupdel web-designers"; then
        print_error "Incorrect. Use: groupdel administrators && groupdel developers && groupdel web-designers"
        read -p "Press Enter to retry..." _
        continue
    fi
    # groupdel: no output

    print_success "Excellent! You’ve completed the lab."
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
