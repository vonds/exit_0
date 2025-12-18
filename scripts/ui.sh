#!/bin/bash

# ANSI-Compatible Color Palette
PALETTE_CYAN='\033[36m'        # #00bac7
PALETTE_LAVENDER='\033[35m'    # #9794c8
PALETTE_PINK='\033[1;35m'      # #e77eb2
PALETTE_CREAM='\033[1;37m'     # #f2e5d5
PALETTE_TEAL='\033[36m'        # #079aa5
NC='\033[0m'

# 🎯 Centered Output
center_menu() {
    local term_width
    term_width=$(tput cols)

    # Fixed-width for alignment (longest option should fit)
    local fixed_width=32

    # Get raw text and strip ANSI for length calculation
    local raw_text="$1"
    local plain_text
    plain_text=$(echo -e "$raw_text" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g')

    # Pad the left to fixed width
    local padded_text
    printf -v padded_text "%-${fixed_width}s" "$plain_text"

    # Center the padded text
    local padding=$(( (term_width - fixed_width) / 2 ))
    (( padding < 0 )) && padding=0

    # Print with original formatting
    printf "%*s%s\n" "$padding" "" "$(echo -e "$raw_text")"
}

center_text() {
    local term_width
    term_width=$(tput cols)

    local raw_text="$1"
    local plain_text
    plain_text=$(echo -e "$raw_text" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g')

    local padding=$(( (term_width - ${#plain_text}) / 2 ))
    (( padding < 0 )) && padding=0

    printf "%*s%s\n" "$padding" "" "$(echo -e "$raw_text")"
}

center_colored_text() {
    local raw_text="$1"
    local term_width
    term_width=$(tput cols)

    # Strip ANSI color codes for length calculation
    local plain_text
    plain_text=$(echo -e "$raw_text" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g')

    # Calculate left padding
    local padding=$(( (term_width - ${#plain_text}) / 2 ))
    (( padding < 0 )) && padding=0

    # Print the full colored text with proper padding
    printf "%*s%s\n" "$padding" "" "$(echo -e "$raw_text")"
}

center_title() {
    center_text "$1"
}

# 🧾 UI Print Functions
print_banner() {
    local title="${1:-Exit_0}"
    center_text "$(echo -e "${PALETTE_LAVENDER}==================================${NC}")"
    center_text "$(echo -e "${PALETTE_CREAM}  $title ${NC}")" 
    center_text "$(echo -e "${PALETTE_LAVENDER}==================================${NC}")"
}

print_success() {
    center_text "${PALETTE_PINK}$1${NC}"
}

print_error() {
    center_text "${PALETTE_CREAM}$1${NC}"
}

print_info() {
    center_text "${PALETTE_CYAN} $1${NC}"
}

draw_colored_title() {
  center_colored_text "$(echo -e '\033[36m░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓████████▓▒░▒▓████████▓▒░\033[0m')"
  center_colored_text "$(echo -e '\033[36m░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░\033[0m')"
  center_colored_text "$(echo -e '\033[36m░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░\033[0m')"
  center_colored_text "$(echo -e '\033[36m░▒▓██████▓▒░  ░▒▓██████▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░\033[0m')"
  center_colored_text "$(echo -e '\033[36m░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░\033[0m')"
  center_colored_text "$(echo -e '\033[36m░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░\033[0m')"
  center_colored_text "$(echo -e '\033[36m░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓████████▓▒░\033[0m')"
}


# 📊 XP Progress Bar (Centered)
center_draw_progress_bar() {
    local current=$1
    local max=$2
    local width=30

    # Guard against bad inputs
    [[ -z "$max" || "$max" -le 0 ]] && max=1
    [[ -z "$current" || "$current" -lt 0 ]] && current=0
    # Clamp current to max so we don’t overfill
    (( current > max )) && current=$max

    # Compute filled cells and clamp to width
    local filled=$(( current * width / max ))
    (( filled < 0 )) && filled=0
    (( filled > width )) && filled=$width
    local empty=$(( width - filled ))

    local bar="${PALETTE_CYAN}XP: ["
    for ((i = 0; i < filled; i++)); do
        bar+="${PALETTE_PINK}#"
    done
    for ((i = 0; i < empty; i++)); do
        bar+="${PALETTE_CREAM}."
    done
    bar+="${PALETTE_CYAN}]${NC}"

    center_text "$bar"
}


# 🧾 Player Stats Panel (Centered)
center_draw_stats_panel() {
    local level=$1
    local xp=$2
    local max_xp=$3
    local box=""
    box+="┌──────────────────────────────┐\n"
    box+="│  ⭐ Level: $level\n"          
    box+="│  🧬 XP:    $xp / $max_xp\n"
    box+="└──────────────────────────────┘"
    local width=$(tput cols)
    local max_line=""
    while IFS= read -r line; do [[ ${#line} -gt ${#max_line} ]] && max_line="$line"; done <<< "$(echo -e "$box")"
    local pad=$(( (width - ${#max_line}) / 2 ))
    while IFS= read -r line; do printf "%*s%s\n" $pad "" "$line"; done <<< "$(echo -e "$box")"
}
