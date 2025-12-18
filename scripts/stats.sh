#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAVE_JSON="$SCRIPT_DIR/../data/.player_save.json"
SUCCESS_JSON="$SCRIPT_DIR/../data/.challenge_success.json"

# print_banner() {
#     echo "=================================="
#     echo "        🧙 Player Stats           "
#     echo "=================================="
# }

# view_stats() {
#     print_banner "🧙 Player Stats"

#     XP=$(jq '.XP' "$SAVE_JSON")
#     LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
#     COMPLETED=$(jq '.COMPLETED | length' "$SAVE_JSON")

#     THRESHOLD=$((LEVEL * 100 * 125 / 100 + LEVEL * 500))
#     XP_REMAINING=$((THRESHOLD - XP))
#     TOTAL=$(jq 'to_entries | map(.value) | add' "$SUCCESS_JSON")

#     echo "⭐ Level:        $LEVEL"
#     echo "🧬 XP:           $XP/$THRESHOLD"
#     # echo "🏁 Challenges Completed: $COMPLETED"
# }




# view_stats
