#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAVE_FILE="${SAVE_FILE:-$SCRIPT_DIR/../data/.player_save}"
SAVE_JSON="${SAVE_JSON:-$SCRIPT_DIR/../data/.player_save.json}"

# --- INIT/GUARDS: ensure sane state on load ---
# XP defaults to 0 if not set.
: "${XP:=0}"

# GLOBAL_LEVEL is the *only* source of truth for progression.
# Never derive GLOBAL_LEVEL from LEVEL.
: "${GLOBAL_LEVEL:=1}"
if [ -z "$GLOBAL_LEVEL" ] || [ "$GLOBAL_LEVEL" -lt 1 ]; then
    GLOBAL_LEVEL=1
fi

# Display level is always computed from GLOBAL_LEVEL (wrap 1..99).
LEVEL=$(( ((GLOBAL_LEVEL - 1) % 99) + 1 ))

save_progress() {
    # Make sure LEVEL is always consistent with GLOBAL_LEVEL before saving.
    LEVEL=$(( ((GLOBAL_LEVEL - 1) % 99) + 1 ))

    # Save to shell-compatible save file
    {
        echo "XP=$XP"
        # display level (wraps 1..99)
        echo "LEVEL=$LEVEL"
        # monotonic progression level (the one used for XP curve)
        echo "GLOBAL_LEVEL=$GLOBAL_LEVEL"
        echo "declare -a COMPLETED=(${COMPLETED[@]})"
    } > "$SAVE_FILE"

    # Also save to JSON file
    if [ -f "$SAVE_JSON" ]; then
        jq --argjson xp "$XP" \
           --argjson level "$LEVEL" \
           --argjson glevel "$GLOBAL_LEVEL" \
           '.XP = $xp | .LEVEL = $level | .GLOBAL_LEVEL = $glevel' \
           "$SAVE_JSON" > "${SAVE_JSON}.tmp" && mv "${SAVE_JSON}.tmp" "$SAVE_JSON"
    fi
}

calculate_xp_to_next_level() {
    # Always use the monotonic progression level; never fall back to LEVEL.
    local eff=${GLOBAL_LEVEL:-1}
    (( eff < 1 )) && eff=1

    # Integer-safe growth curve: eff^2*125 + eff*500
    local req=$(( eff*eff*125 + eff*500 ))
    (( req < 1 )) && req=1
    echo "$req"
}

award_xp() {
    local amount=$1
    XP=$((XP + amount))

    # Ensure GLOBAL_LEVEL is valid
    : "${GLOBAL_LEVEL:=1}"
    (( GLOBAL_LEVEL < 1 )) && GLOBAL_LEVEL=1

    local required
    required=$(calculate_xp_to_next_level)

    while [ "$XP" -ge "$required" ]; do
        XP=$((XP - required))
        GLOBAL_LEVEL=$((GLOBAL_LEVEL + 1))

        # Display level wraps 1..99 → 1, derived from GLOBAL_LEVEL
        LEVEL=$(( ((GLOBAL_LEVEL - 1) % 99) + 1 ))

        print_success "You leveled up! Now at Level $LEVEL!"
        required=$(calculate_xp_to_next_level)
    done

    save_progress
}
