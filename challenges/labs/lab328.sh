#!/bin/bash

# Lab 328: Laptop Storage Upgrade (A+ Focus)
# Focus: SSD vs HDD, PCIe Gen3 x2 vs M.2, SATA, caddies, ZIF ribbon, data backup & migration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 328: A+ Section 1.1 — Storage Upgrade"
LAB_ID="lab328"
LAB_XP=20600
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

accept_any() {
    # case-insensitive contains match helper: $1 = user input, $2.. = accepted variants
    local input="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    shift
    for v in "$@"; do
        local norm="$(echo "$v" | tr '[:upper:]' '[:lower:]')"
        [[ "$input" == "$norm" ]] && return 0
    done
    return 1
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Upgrade a laptop that has a PCIe-based SSD for OS/apps and a 2.5\" SATA HDD for data."
    center_text "Goal: Identify parts, follow safe replacement steps, and plan data migration."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1 — Identify SSD vs HDD roles
    draw_lab_ui
    echo "  Question 1: Which device should typically host the OS and apps for best performance?"
    read -p "  lab@a-plus-lab328:~$ " cmd1
    echo
    if ! accept_any "$cmd1" "SSD" "solid state drive" "solid-state drive"; then
        print_error "Incorrect. Install the OS/apps on the SSD for much faster performance."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SSD is best for OS and apps."
    echo

    # Q2 — Recognize PCIe Gen3 x2 card
    echo "  Question 2: The small card in a slot that looks like Mini PCIe but is labeled 'PCIe Gen3 x2' is a(n) ______."
    read -p "  lab@a-plus-lab328:~$ " cmd2
    echo
    if ! accept_any "$cmd2" "ssd" "nvme ssd" "pcie ssd"; then
        print_error "Incorrect. That small PCIe Gen3 x2 card is the SSD module."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: It’s an SSD module (PCIe)."
    echo

    # Q3 — Angle insert
    echo "  Question 3: When removing/reinstalling that PCIe SSD module, at what angle is it inserted before being fastened?"
    read -p "  lab@a-plus-lab328:~$ " cmd3
    echo
    if ! accept_any "$cmd3" "45" "45 degrees" "at a 45-degree angle"; then
        print_error "Incorrect. Insert/remove at about a 45-degree angle, then secure with the screw."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: ~45-degree angle, then screw down."
    echo

    # Q4 — Keying awareness
    echo "  Question 4: Why won’t an SSD with different keying line up in the wrong slot orientation?"
    read -p "  lab@a-plus-lab328:~$ " cmd4
    echo
    if ! accept_any "$cmd4" "notch" "keying" "mismatch" "prevent incorrect insertion" "physical keying prevents wrong orientation"; then
        print_error "Incorrect. Physical keying/notches prevent incorrect orientation and wrong-slot insertion."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Physical keying/notches prevent wrong insertion."
    echo

    # Q5 — HDD interface
    echo "  Question 5: A 2.5\" laptop HDD uses which interface and connectors?"
    read -p "  lab@a-plus-lab328:~$ " cmd5
    echo
    if ! accept_any "$cmd5" "sata" "sata data and power" "7-pin sata data and 15-pin sata power"; then
        print_error "Incorrect. A 2.5\" HDD uses SATA with 7-pin data and 15-pin power."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SATA (7-pin data + 15-pin power)."
    echo

    # Q6 — ZIF ribbon adapter
    echo "  Question 6: In some laptops the 2.5\" drive connects via a short ribbon into a board socket. This low-force socket is called a ______."
    read -p "  lab@a-plus-lab328:~$ " cmd6
    echo
    if ! accept_any "$cmd6" "zif" "zero insertion force" "zif socket"; then
        print_error "Incorrect. That’s a ZIF (Zero Insertion Force) socket for the ribbon adapter."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: ZIF (Zero Insertion Force) socket."
    echo

    # Q7 — Caddy purpose
    echo "  Question 7: Why do many laptops use a metal 'caddy' and foam/plastic under a 2.5\" HDD?"
    read -p "  lab@a-plus-lab328:~$ " cmd7
    echo
    if ! accept_any "$cmd7" "mounting and shock absorption" "stability and vibration damping" "secure mounting and shock/vibration absorption"; then
        print_error "Incorrect. The caddy secures the drive and adds shock/vibration absorption and alignment."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Secure mounting + shock/vibration absorption."
    echo

    # Q8 — Backup/migration
    echo "  Question 8: Before replacing the SSD containing the OS, what critical step should you take to avoid data loss?"
    read -p "  lab@a-plus-lab328:~$ " cmd8
    echo
    if ! accept_any "$cmd8" "backup" "full backup" "image clone" "clone the drive" "back up data" "disk imaging"; then
        print_error "Incorrect. Perform a full backup or clone/image the drive before hardware changes."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Back up or clone the drive first."
    echo

    # Q9 — Post-install steps
    echo "  Question 9: After installing a blank 2.5\" HDD for data, what must you do in the OS to make it usable?"
    read -p "  lab@a-plus-lab328:~$ " cmd9
    echo
    if ! accept_any "$cmd9" "initialize and format" "partition and format" "create filesystem" "disk management format"; then
        print_error "Incorrect. Initialize/partition and format the new drive (create a filesystem) before use."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Initialize/partition and format the drive."
    echo

    # Q10 — External enclosure for old HDD
    echo "  Question 10: What’s an easy way to recover files from the old 2.5\" SATA HDD after removal?"
    read -p "  lab@a-plus-lab328:~$ " cmd10
    echo
    if ! accept_any "$cmd10" "usb enclosure" "sata-to-usb adapter" "external enclosure" "usb 3.0 enclosure"; then
        print_error "Incorrect. Place it in a USB 3.x external enclosure or use a SATA-to-USB adapter to copy files."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Use a USB enclosure or SATA-to-USB adapter."
    echo

    # Q11 — RPM fact
    echo "  Question 11: A 7,200 RPM HDD is (choose one): slower/faster than a 5,400 RPM HDD?"
    read -p "  lab@a-plus-lab328:~$ " cmd11
    echo
    if ! accept_any "$cmd11" "faster"; then
        print_error "Incorrect. 7,200 RPM is faster (lower latency and higher throughput) than 5,400 RPM."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: It’s faster."
    echo

    # Q12 — M.2 vs Mini PCIe awareness
    echo "  Question 12: Modern laptops more commonly use which slot for SSDs: Mini PCIe or M.2?"
    read -p "  lab@a-plus-lab328:~$ " cmd12
    echo
    if ! accept_any "$cmd12" "m.2" "m2"; then
        print_error "Incorrect. Modern systems typically use M.2 for SSDs (NVMe or SATA over M.2)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: M.2 is most common for modern SSDs."
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
