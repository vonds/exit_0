#!/bin/bash

# Lab 324: Replace an Internal Laptop Battery (A+ Focus)
# Focus: Safety, identification, removal, replacement, disposal, and validation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 324: A+ Section 1.1 — Battery Replacement"
LAB_ID="lab324"
LAB_XP=18800
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
    center_text "Scenario: A laptop no longer holds a charge. Replace the internal Li-ion battery safely."
    center_text "Goal: Follow safe disassembly, swap, disposal, and validation steps."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1 — Pre-disassembly safety
    draw_lab_ui
    echo "  Before opening the chassis, list the two critical safety steps."
    read -p "  lab@lab324:~$ " cmd1
    echo
    if [[ "$cmd1" != "Power off and unplug; use ESD protection" && "$cmd1" != "Shut down and disconnect AC; wear ESD strap" && "$cmd1" != "Power down/unplug AC and use ESD wrist strap" ]]; then
        print_error "Incorrect. Power down and disconnect AC, then use ESD protection (strap/mat)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Power off/unplug and use ESD protection."
    echo

    # Question 2 — Internal battery isolation
    echo "  What must you do immediately after removing the bottom cover?"
    read -p "  lab@lab324:~$ " cmd2
    echo
    if [[ "$cmd2" != "Disconnect the internal battery" && "$cmd2" != "Unplug the internal battery connector" && "$cmd2" != "Disable/disconnect internal battery" ]]; then
        print_error "Incorrect. Disconnect/disable the internal battery before touching other components."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Disconnect/disable internal battery first."
    echo

    # Question 3 — Identification of the correct part
    echo "  How do you confirm the correct replacement battery before removing the old one?"
    read -p "  lab@lab324:~$ " cmd3
    echo
    if [[ "$cmd3" != "Match model number and specs to the service manual" && "$cmd3" != "Verify part number and electrical specs against manufacturer documentation" && "$cmd3" != "Check PN/voltage/capacity against service guide" ]]; then
        print_error "Incorrect. Match the exact model/part number and electrical specs with the service manual/manufacturer docs."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Verify PN and specs with official documentation."
    echo

    # Question 4 — Fasteners and layout
    echo "  What is the best practice for tracking battery screw locations during removal?"
    read -p "  lab@lab324:~$ " cmd4
    echo
    if [[ "$cmd4" != "Map screws on a magnetic parts tray with labels" && "$cmd4" != "Lay out screws in a labeled diagram/parts tray" && "$cmd4" != "Use a labeled magnetic mat/diagram for screws" ]]; then
        print_error "Incorrect. Use a labeled magnetic tray/mat or diagram to preserve screw positions and lengths."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Use labeled tray/mat/diagram."
    echo

    # Question 5 — Connector care
    echo "  What tool/technique should you use to release a tight battery connector safely?"
    read -p "  lab@lab324:~$ " cmd5
    echo
    if [[ "$cmd5" != "Use plastic spudger or tweezers; lift evenly from the connector" && "$cmd5" != "Gently wiggle with a plastic spudger; avoid pulling wires" && "$cmd5" != "Non-metal spudger; lift evenly without tugging cables" ]]; then
        print_error "Incorrect. Use a plastic spudger/tweezers; lift evenly at the connector body and avoid pulling on wires."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Non-metal leverage at the connector body."
    echo

    # Question 6 — Installation order
    echo "  After placing the new battery, what order should you follow before closing the laptop?"
    read -p "  lab@lab324:~$ " cmd6
    echo
    if [[ "$cmd6" != "Align battery, reinstall screws, reconnect battery, inspect cable routing" && "$cmd6" != "Seat battery, install fasteners, reconnect cable, verify routing/strain relief" && "$cmd6" != "Position, fasten, reconnect, and check cable path/strain" ]]; then
        print_error "Incorrect. Position the pack, fasten, reconnect the battery, and verify routing/strain relief before reassembly."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Position → fasten → reconnect → cable check."
    echo

    # Question 7 — Post-repair validation
    echo "  Which two checks confirm a successful battery replacement before returning the device?"
    read -p "  lab@lab324:~$ " cmd7
    echo
    if [[ "$cmd7" != "System powers on from battery; OS reports charging/discharging correctly" && "$cmd7" != "Boot on battery only; verify charge state changes when AC is connected" && "$cmd7" != "POST/boot on battery; confirm OS sees battery health/charge cycling" ]]; then
        print_error "Incorrect. Confirm the system boots on battery alone and that the OS shows proper charge/discharge when AC is plugged/unplugged."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Boots on battery; OS reflects proper charge/discharge."
    echo
    # Question 8 — Safety/disposal
    echo "  Where should the old Lithium Ion battery be disposed of?"
    read -p "  lab@lab324:~$ " cmd8
    echo
    if [[ "$cmd8" != "Certified e-waste or battery recycling facility" && "$cmd8" != "Authorized battery recycler/e-waste program" && "$cmd8" != "Manufacturer take-back or certified recycler" ]]; then
        print_error "Incorrect. Use a certified e-waste/battery recycling program or manufacturer take-back; never trash Li-ion."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Recycle via certified e-waste/battery program."
    echo

    # Question 9 — Common mistake
    echo "  The laptop won’t power on from the battery. What is the most likely oversight?"
    read -p "  lab@lab324:~$ " cmd9
    echo
    if [[ "$cmd9" != "Battery connector not fully seated" && "$cmd9" != "Forgot to reconnect internal battery" && "$cmd9" != "Loose/disconnected battery cable" ]]; then
        print_error "Incorrect. Most often the internal battery connector is loose or not reconnected."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Reseat/reconnect the battery connector."
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to A+ Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
