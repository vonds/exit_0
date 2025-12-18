#!/bin/bash
# Lab 66: Using curl and ping for Network Testing

#set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 66: Using curl and ping for Network Testing"
LAB_ID="lab66"
LAB_XP=14500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

TEST_HOST="example.com"

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
    center_text "Scenario: A web service is reportedly down."
    center_text "Test both basic reachability and HTTP connectivity for $TEST_HOST."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Use ping to test basic connectivity to $TEST_HOST."
    read -p "  lab@lpic-lab66:~\$ " cmd1
    echo
    [[ "$cmd1" != "ping -c 4 $TEST_HOST" ]] && {
        print_error "Incorrect. Use 'ping -c 4 $TEST_HOST'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING $TEST_HOST (93.184.216.34) 56(84) bytes of data."
    echo "  64 bytes from 93.184.216.34: icmp_seq=1 ttl=56 time=22.4 ms"
    echo "  64 bytes from 93.184.216.34: icmp_seq=2 ttl=56 time=22.1 ms"
    echo "  64 bytes from 93.184.216.34: icmp_seq=3 ttl=56 time=21.9 ms"
    echo "  64 bytes from 93.184.216.34: icmp_seq=4 ttl=56 time=22.3 ms"
    echo
    echo "  --- $TEST_HOST ping statistics ---"
    echo "  4 packets transmitted, 4 received, 0% packet loss, time 3006ms"
    echo "  rtt min/avg/max/mdev = 21.900/22.175/22.400/0.199 ms"
    echo

    echo "  Step 2: Use curl to make a request to $TEST_HOST."
    read -p "  lab@lpic-lab66:~\$ " cmd2
    echo
    [[ "$cmd2" != "curl http://$TEST_HOST" ]] && {
        print_error "Incorrect. Use 'curl http://$TEST_HOST'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  <html>"
    echo "  <head><title>301 Moved Permanently</title></head>"
    echo "  <body>"
    echo "  <center><h1>301 Moved Permanently</h1></center>"
    echo "  <p>Resource has moved to <a href=\"https://$TEST_HOST/\">https://$TEST_HOST/</a></p>"
    echo "  </body>"
    echo "  </html>"
    echo

    echo "  Step 3: Use curl to fetch only HTTP headers."
    read -p "  lab@lpic-lab66:~\$ " cmd3
    echo
    [[ "$cmd3" != "curl -I http://$TEST_HOST" ]] && {
        print_error "Incorrect. Use 'curl -I http://$TEST_HOST'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  HTTP/1.1 301 Moved Permanently"
    echo "  Location: https://$TEST_HOST/"
    echo "  Content-Type: text/html; charset=UTF-8"
    echo "  Content-Length: 162"
    echo "  Date: Thu, 06 Nov 2025 10:15:42 GMT"
    echo "  Server: ECD (example)"
    echo

    echo "  Step 4: Use curl to follow a redirect from http to https."
    read -p "  lab@lpic-lab66:~\$ " cmd4
    echo
    [[ "$cmd4" != "curl -L http://$TEST_HOST" ]] && {
        print_error "Incorrect. Use 'curl -L http://$TEST_HOST'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  * Redirecting to: https://$TEST_HOST/"
    echo "  * Successfully fetched via HTTPS"
    echo "  <!doctype html>"
    echo "  <html>"
    echo "    <head>"
    echo "      <title>Example Domain</title>"
    echo "      <meta charset=\"utf-8\" />"
    echo "      <meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\" />"
    echo "      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />"
    echo "    </head>"
    echo "    <body>"
    echo "      <div>"
    echo "        <h1>Example Domain</h1>"
    echo "        <p>This domain is for use in illustrative examples in documents. You may use this"
    echo "        domain in literature without prior coordination or asking for permission.</p>"
    echo "        <p><a href=\"https://www.iana.org/domains/example\">More information...</a></p>"
    echo "      </div>"
    echo "    </body>"
    echo "  </html>"
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
