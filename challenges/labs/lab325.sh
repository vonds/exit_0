#!/bin/bash

# Lab 325: Laptop Keyboard & Touchpad Replacement (A+ Focus)
# Focus: Replaceability checks, safe disassembly, ZIF ribbons, single-key fixes, drivers, and testing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 325: A+ Section 1.1 — Keyboard/Touchpad"
LAB_ID="lab325"
LAB_XP=19000
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
    center_text "Scenario: A user reports dead keys and erratic cursor input."
    center_text "Goal: Determine replaceability, safely disassemble, replace parts, and validate."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1 — Replaceability check
    draw_lab_ui
    echo "  Question 1: What is the FIRST thing you should consult to determine if the keyboard is field-replaceable?"
    read -p "  lab@a-plus-lab325:~$ " cmd1
    echo
    if [[ "$cmd1" != "Service manual" && "$cmd1" != "Manufacturer documentation" && "$cmd1" != "Model service guide" ]]; then
        print_error "Incorrect. Check the model's service manual/manufacturer documentation."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Service manual/manufacturer documentation."
    echo

    # Question 2 — Power and ESD
    echo "  Question 2: Before opening the chassis, list the two critical safety steps."
    read -p "  lab@a-plus-lab325:~$ " cmd2
    echo
    if [[ "$cmd2" != "Shut down and disconnect AC; use ESD protection" && "$cmd2" != "Power off and unplug; use ESD strap" && "$cmd2" != "Power down, remove charger, and wear ESD wrist strap" ]]; then
        print_error "Incorrect. Power down and disconnect AC, then use ESD protection."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Power off/unplug and use ESD protection."
    echo

    # Question 3 — Internal battery
    echo "  Question 3: The laptop uses an internal battery. What must you do before touching ribbon cables?"
    read -p "  lab@a-plus-lab325:~$ " cmd3
    echo
    if [[ "$cmd3" != "Disconnect the internal battery" && "$cmd3" != "Unplug the internal battery" && "$cmd3" != "Disable the internal battery" ]]; then
        print_error "Incorrect. Disconnect/disable the internal battery before handling cables."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Disconnect/disable internal battery."
    echo

    # Question 4 — Typical access methods
    echo "  Question 4: Name a common access method to reach a laptop keyboard for removal."
    read -p "  lab@a-plus-lab325:~$ " cmd4
    echo
    if [[ "$cmd4" != "Remove top bezel and lift keyboard" && "$cmd4" != "Remove bottom case then top cover" && "$cmd4" != "Remove underside screws marked for keyboard" ]]; then
        print_error "Incorrect. Common paths include removing the top bezel, removing bottom case then top cover, or underside keyboard-marked screws."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Known access paths acknowledged."
    echo

    # Question 5 — ZIF ribbons
    echo "  Question 5: What connector type commonly secures keyboard/touchpad cables and how is it released?"
    read -p "  lab@a-plus-lab325:~$ " cmd5
    echo
    if [[ "$cmd5" != "ZIF ribbon; flip/lift latch to release" && "$cmd5" != "ZIF connector; open the locking tab" && "$cmd5" != "Zero Insertion Force; lift latch then slide ribbon" ]]; then
        print_error "Incorrect. It is a ZIF connector; lift/flip the latch, then slide the ribbon out."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: ZIF connector with lift/flip latch."
    echo

    # Question 6 — Soldered keyboards
    echo "  Question 6: If the keyboard is factory-soldered to the palmrest, what is the practical replacement approach?"
    read -p "  lab@a-plus-lab325:~$ " cmd6
    echo
    if [[ "$cmd6" != "Replace the entire top case assembly" && "$cmd6" != "Replace palmrest/top cover assembly" ]]; then
        print_error "Incorrect. Replace the entire palmrest/top case assembly with preinstalled keyboard."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Replace the full top case assembly."
    echo

    # Question 7 — Single key repair
    echo "  Question 7: A single key is missing. What can you replace without a full keyboard swap?"
    read -p "  lab@a-plus-lab325:~$ " cmd7
    echo
    if [[ "$cmd7" != "Keycap and retainer" && "$cmd7" != "Keycap and scissor mechanism" && "$cmd7" != "Keycap and hinge/retainer" ]]; then
        print_error "Incorrect. Replace the keycap and its scissor/retainer mechanism."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Keycap + retainer/scissor mechanism."
    echo

    # Question 8 — Touchpad cable symptom
    echo "  Question 8: What symptom often indicates a touchpad ribbon is not fully seated?"
    read -p "  lab@a-plus-lab325:~$ " cmd8
    echo
    if [[ "$cmd8" != "Erratic cursor or unintended clicks" && "$cmd8" != "No cursor movement" && "$cmd8" != "Intermittent touchpad response" ]]; then
        print_error "Incorrect. Erratic or absent input commonly indicates an improperly seated ribbon."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Erratic/absent input from a loose ribbon."
    echo

    # Question 9 — Post-repair validation
    echo "  Question 9: After reassembly, what two checks should you perform before returning the laptop?"
    read -p "  lab@a-plus-lab325:~$ " cmd9
    echo
    if [[ "$cmd9" != "Verify POST/BIOS and test keys/touchpad in OS" && "$cmd9" != "POST check then OS test of all keys and clicks" && "$cmd9" != "BIOS recognition and full input test in OS" ]]; then
        print_error "Incorrect. Confirm POST/BIOS, then test all keys and touchpad clicks/gestures in the OS."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: POST/BIOS then OS input tests."
    echo

    # Question 10 — Drivers/firmware and spills
    echo "  Question 10: Special keys/gestures fail after replacement. What software step can resolve this, and what is the typical remedy after a liquid spill?"
    read -p "  lab@a-plus-lab325:~$ " cmd10
    echo
    if [[ "$cmd10" != "Install/update OEM drivers; replace keyboard after spill" && "$cmd10" != "Update keyboard/touchpad drivers; replace keyboard for spills" && "$cmd10" != "Update drivers/firmware; replace the liquid-damaged keyboard" ]]; then
        print_error "Incorrect. Install/update OEM drivers/firmware for features; liquid spills typically require keyboard replacement."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Update OEM drivers/firmware; replace liquid-damaged keyboards."
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
