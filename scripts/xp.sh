#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAVE_JSON="${SAVE_JSON:-$SCRIPT_DIR/../data/.player_save.json}"

# --- INIT/GUARDS: ensure sane state on load ---
: "${XP:=0}"
: "${LEVEL:=1}"

# Validate numerics (avoid empty/null/non-numeric)
[[ "$XP" =~ ^[0-9]+$ ]] || XP=0
[[ "$LEVEL" =~ ^[0-9]+$ ]] || LEVEL=1
[ "$LEVEL" -ge 1 ] 2>/dev/null || LEVEL=1

save_progress() {
    # Save ONLY to JSON (single source of truth for persistence)
    if [ -f "$SAVE_JSON" ]; then
        jq --argjson xp "$XP" \
           --argjson level "$LEVEL" \
           '.XP = $xp | .LEVEL = $level | del(.GLOBAL_LEVEL)' \
           "$SAVE_JSON" > "${SAVE_JSON}.tmp" && mv "${SAVE_JSON}.tmp" "$SAVE_JSON"
    else
        # If for some reason the JSON doesn't exist, create it.
        printf '{"XP":%s,"LEVEL":%s,"COMPLETED":[]}\n' "$XP" "$LEVEL" > "$SAVE_JSON"
    fi
}

calculate_xp_to_next_level() {
    # Use LEVEL as the only source of truth.
    local eff="${LEVEL:-1}"
    [[ "$eff" =~ ^[0-9]+$ ]] || eff=1
    (( eff < 1 )) && eff=1

    # Integer-safe growth curve: eff^2*125 + eff*500
    local req=$(( eff*eff*125 + eff*500 ))
    (( req < 1 )) && req=1
    echo "$req"
}

award_xp() {
    local amount="$1"
    [[ "$amount" =~ ^-?[0-9]+$ ]] || amount=0
    (( amount < 0 )) && amount=0

    XP=$((XP + amount))

    # Ensure LEVEL is valid
    [[ "$LEVEL" =~ ^[0-9]+$ ]] || LEVEL=1
    (( LEVEL < 1 )) && LEVEL=1

    local required
    required="$(calculate_xp_to_next_level)"

    # Normalize: handle multiple level-ups if XP is large
    while [ "$XP" -ge "$required" ]; do
        XP=$((XP - required))
        LEVEL=$((LEVEL + 1))

        print_success "You leveled up! Now at Level $LEVEL!"
        required="$(calculate_xp_to_next_level)"
    done

    save_progress
}
