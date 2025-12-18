#!/bin/bash

# Lab 162: locale Command Basics (10 questions, realistic outputs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "  Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "  Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 162: locale Command Basics"
LAB_ID="lab162"
LAB_XP=15800
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
    echo "  Practice working with the locale command to view and configure localization."
    echo "  Use exact commands as prompted."
    echo
    echo "  Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Display all current locale settings."
    read -p "  lab@lpic-lab162:~$ " cmd1
    echo
    if [[ "$cmd1" != "locale" ]]; then
        echo "  Incorrect. Use: locale"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  LANG=en_US.UTF-8"
    echo "  LC_CTYPE=\"en_US.UTF-8\""
    echo "  LC_NUMERIC=\"en_US.UTF-8\""
    echo "  LC_TIME=\"en_US.UTF-8\""
    echo "  LC_COLLATE=\"en_US.UTF-8\""
    echo "  LC_MONETARY=\"en_US.UTF-8\""
    echo "  LC_MESSAGES=\"en_US.UTF-8\""
    echo "  LC_PAPER=\"en_US.UTF-8\""
    echo "  LC_NAME=\"en_US.UTF-8\""
    echo "  LC_ADDRESS=\"en_US.UTF-8\""
    echo "  LC_TELEPHONE=\"en_US.UTF-8\""
    echo "  LC_MEASUREMENT=\"en_US.UTF-8\""
    echo "  LC_IDENTIFICATION=\"en_US.UTF-8\""
    echo "  LC_ALL="
    echo

    echo "  Step 2: Display the value of LANG only."
    read -p "  lab@lpic-lab162:~$ " cmd2
    echo
    if [[ "$cmd2" != "locale LANG" ]]; then
        echo "  Incorrect. Use: locale LANG"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  en_US.UTF-8"
    echo

    echo "  Step 3: Display the character type classification setting."
    read -p "  lab@lpic-lab162:~$ " cmd3
    echo
    if [[ "$cmd3" != "locale LC_CTYPE" ]]; then
        echo "  Incorrect. Use: locale LC_CTYPE"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  en_US.UTF-8"
    echo

    echo "  Step 4: Display the numeric formatting setting."
    read -p "  lab@lpic-lab162:~$ " cmd4
    echo
    if [[ "$cmd4" != "locale LC_NUMERIC" ]]; then
        echo "  Incorrect. Use: locale LC_NUMERIC"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  en_US.UTF-8"
    echo

    echo "  Step 5: Show available locales on the system."
    read -p "  lab@lpic-lab162:~$ " cmd5
    echo
    if [[ "$cmd5" != "locale -a" ]]; then
        echo "  Incorrect. Use: locale -a"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  C"
    echo "  C.UTF-8"
    echo "  en_US.utf8"
    echo "  fr_FR.utf8"
    echo "  ja_JP.utf8"
    echo

    echo "  Step 6: Change LANG to fr_FR.UTF-8 for the current shell only."
    read -p "  lab@lpic-lab162:~$ " cmd6
    echo
    if [[ "$cmd6" != "export LANG=fr_FR.UTF-8" ]]; then
        echo "  Incorrect. Use: export LANG=fr_FR.UTF-8"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  LANG set to fr_FR.UTF-8 for this shell."
    echo

    echo "  Step 7: Display the LC_TIME setting after changing LANG."
    read -p "  lab@lpic-lab162:~$ " cmd7
    echo
    if [[ "$cmd7" != "locale LC_TIME" ]]; then
        echo "  Incorrect. Use: locale LC_TIME"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  fr_FR.UTF-8"
    echo

    echo "  Step 8: Revert LANG back to en_US.UTF-8."
    read -p "  lab@lpic-lab162:~$ " cmd8
    echo
    if [[ "$cmd8" != "export LANG=en_US.UTF-8" ]]; then
        echo "  Incorrect. Use: export LANG=en_US.UTF-8"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  LANG set back to en_US.UTF-8 for this shell."
    echo

    echo "  Step 9: Show the measurement units setting."
    read -p "  lab@lpic-lab162:~$ " cmd9
    echo
    if [[ "$cmd9" != "locale LC_MEASUREMENT" ]]; then
        echo "  Incorrect. Use: locale LC_MEASUREMENT"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  en_US.UTF-8"
    echo

    echo "  Step 10: Display all locale environment variables in use."
    read -p "  lab@lpic-lab162:~$ " cmd10
    echo
    if [[ "$cmd10" != "locale -k LC_ALL" ]]; then
        echo "  Incorrect. Use: locale -k LC_ALL"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  lc-ctype=\"en_US.UTF-8\""
    echo "  lc-numeric=\"en_US.UTF-8\""
    echo "  lc-time=\"en_US.UTF-8\""
    echo "  lc-collate=\"en_US.UTF-8\""
    echo "  lc-monetary=\"en_US.UTF-8\""
    echo "  lc-messages=\"en_US.UTF-8\""
    echo "  lc-paper=\"en_US.UTF-8\""
    echo "  lc-name=\"en_US.UTF-8\""
    echo "  lc-address=\"en_US.UTF-8\""
    echo "  lc-telephone=\"en_US.UTF-8\""
    echo "  lc-measurement=\"en_US.UTF-8\""
    echo "  lc-identification=\"en_US.UTF-8\""
    echo

    echo "  Excellent work!"
    echo "  You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    echo "  You've successfully completed this lab $completion_count time(s)."
    echo
    echo "  Would you like to:"
    echo "  1) Retry this lab"
    echo "  2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
