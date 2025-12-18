#!/bin/bash

# Lab 92: Tracing Network Traffic with traceroute
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 92: Tracing Network Traffic with traceroute"
LAB_ID="lab92"
LAB_XP=4000
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
    center_text "Scenario: You need to trace the route taken by packets to a remote server."
    center_text "You'll use traceroute to view the path and diagnose network issues."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install traceroute if not already installed."
    read -p "  lab@lpic-lab92:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install traceroute -y" && "$cmd1" != "sudo dnf install traceroute -y" && "$cmd1" != "sudo pacman -S traceroute" ]] && {
        print_error "Incorrect. Use: sudo apt install traceroute -y (or dnf/pacman depending on distro)"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated package manager output:"
    if [[ "$cmd1" == "sudo apt install traceroute -y" ]]; then
        echo "    Reading package lists... Done"
        echo "    Building dependency tree..."
        echo "    Reading state information... Done"
        echo "    Suggested packages:"
        echo "      tcptraceroute"
        echo "    The following NEW packages will be installed:"
        echo "      traceroute"
        echo "    0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded."
        echo "    After this operation, 120 kB of additional disk space will be used."
        echo "    Setting up traceroute (1:2.1.0-2) ..."
    elif [[ "$cmd1" == "sudo dnf install traceroute -y" ]]; then
        echo "    Dependencies resolved."
        echo "    ================================================================="
        echo "     Package         Architecture   Version              Repository"
        echo "    ================================================================="
        echo "     traceroute      x86_64         3:2.1.0-12.el9       baseos    "
        echo
        echo "    Installed:"
        echo "      traceroute-3:2.1.0-12.el9.x86_64"
        echo "    Complete!"
    else
        echo "    resolving dependencies..."
        echo "    looking for conflicting packages..."
        echo
        echo "    Packages (1) traceroute-2.1.0-5"
        echo
        echo "    Total Installed Size: 0.12 MiB"
        echo "    :: Proceed with installation? [Y/n] y"
        echo "    (1/1) installing traceroute"
        echo "    (1/1) checking keys in keyring"
        echo "    (1/1) checking package integrity"
        echo "    (1/1) Package 'traceroute' installed."
    fi
    echo

    echo "  Step 2: Run traceroute to a public domain (e.g., google.com)."
    read -p "  lab@lpic-lab92:~$ " cmd2
    echo
    [[ "$cmd2" != "traceroute google.com" ]] && {
        print_error "Incorrect. Use: traceroute google.com"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated traceroute output:"
    echo "    traceroute to google.com (142.250.72.46), 30 hops max, 60 byte packets"
    echo "     1  192.168.1.1 (192.168.1.1)           1.123 ms   0.956 ms   0.902 ms"
    echo "     2  10.0.0.1 (10.0.0.1)                 7.412 ms   6.983 ms   7.201 ms"
    echo "     3  96.120.45.1 (96.120.45.1)          12.881 ms  12.604 ms  12.447 ms"
    echo "     4  68.86.190.45 (68.86.190.45)        18.522 ms  18.410 ms  18.367 ms"
    echo "     5  142.250.72.46 (142.250.72.46)      23.771 ms  23.593 ms  23.541 ms"
    echo "    Each line represents a hop along the path, with three round-trip times."
    echo

    echo "  Step 3: Use traceroute with numeric IP output only."
    read -p "  lab@lpic-lab92:~$ " cmd3
    echo
    [[ "$cmd3" != "traceroute -n google.com" ]] && {
        print_error "Incorrect. Use: traceroute -n google.com"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated traceroute -n output (no DNS lookups):"
    echo "    traceroute to 142.250.72.46 (142.250.72.46), 30 hops max, 60 byte packets"
    echo "     1  192.168.1.1           0.945 ms   0.881 ms   0.864 ms"
    echo "     2  10.0.0.1              6.972 ms   6.751 ms   6.538 ms"
    echo "     3  96.120.45.1          12.204 ms  12.093 ms  11.984 ms"
    echo "     4  68.86.190.45         18.207 ms  18.165 ms  18.143 ms"
    echo "     5  142.250.72.46        23.432 ms  23.317 ms  23.281 ms"
    echo

    echo "  Step 4: Trace to a non-responding IP and observe timeout behavior."
    read -p "  lab@lpic-lab92:~$ " cmd4
    echo
    [[ "$cmd4" != "traceroute 10.255.255.1" ]] && {
        print_error "Incorrect. Try using traceroute 10.255.255.1"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated unreachable traceroute output:"
    echo "    traceroute to 10.255.255.1 (10.255.255.1), 30 hops max, 60 byte packets"
    echo "     1  192.168.1.1 (192.168.1.1)           1.011 ms   0.948 ms   0.932 ms"
    echo "     2  * * *"
    echo "     3  * * *"
    echo "     4  * * *"
    echo "     5  * * *"
    echo "    Hops showing '*' indicate that no ICMP responses were received."
    echo

    echo "  Step 5: Limit the number of hops to 5."
    read -p "  lab@lpic-lab92:~$ " cmd5
    echo
    [[ "$cmd5" != "traceroute -m 5 google.com" ]] && {
        print_error "Incorrect. Use: traceroute -m 5 google.com"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated traceroute with max hops set to 5:"
    echo "    traceroute to google.com (142.250.72.46), 5 hops max, 60 byte packets"
    echo "     1  192.168.1.1           0.987 ms   0.921 ms   0.904 ms"
    echo "     2  10.0.0.1              6.822 ms   6.599 ms   6.447 ms"
    echo "     3  96.120.45.1          11.947 ms  11.853 ms  11.774 ms"
    echo "     4  68.86.190.45         17.954 ms  17.903 ms  17.861 ms"
    echo "     5  142.250.72.46        23.275 ms  23.163 ms  23.121 ms"
    echo "    traceroute stopped after reaching the maximum hop count of 5."
    echo

    echo "  Step 6: Use ICMP instead of UDP packets (Linux systems only)."
    read -p "  lab@lpic-lab92:~$ " cmd6
    echo
    [[ "$cmd6" != "traceroute -I google.com" ]] && {
        print_error "Incorrect. Use: traceroute -I google.com"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated ICMP-based traceroute:"
    echo "    traceroute to google.com (142.250.72.46), 30 hops max, 60 byte packets"
    echo "    traceroute: using ICMP ECHO"
    echo "     1  192.168.1.1           0.991 ms   0.934 ms   0.917 ms"
    echo "     2  10.0.0.1              7.034 ms   6.841 ms   6.705 ms"
    echo "     3  96.120.45.1          12.157 ms  12.064 ms  11.992 ms"
    echo "     4  68.86.190.45         18.003 ms  17.962 ms  17.926 ms"
    echo "     5  142.250.72.46        23.321 ms  23.214 ms  23.189 ms"
    echo

    echo "  Step 7: Use TCP SYN packets for firewall-friendly tracing."
    read -p "  lab@lpic-lab92:~$ " cmd7
    echo
    [[ "$cmd7" != "traceroute -T google.com" ]] && {
        print_error "Incorrect. Use: traceroute -T google.com"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated TCP-based traceroute:"
    echo "    traceroute to google.com (142.250.72.46), 30 hops max, 60 byte packets"
    echo "    traceroute: using TCP SYN, port 80"
    echo "     1  192.168.1.1           1.031 ms   0.973 ms   0.951 ms"
    echo "     2  10.0.0.1              7.142 ms   6.935 ms   6.782 ms"
    echo "     3  96.120.45.1          12.264 ms  12.155 ms  12.067 ms"
    echo "     4  68.86.190.45         18.119 ms  18.072 ms  18.041 ms"
    echo "     5  142.250.72.46        23.439 ms  23.328 ms  23.295 ms"
    echo

    echo "  Step 8: Save the traceroute results to a file."
    read -p "  lab@lpic-lab92:~$ " cmd8
    echo
    [[ "$cmd8" != "traceroute google.com > trace.log" ]] && {
        print_error "Incorrect. Use: traceroute google.com > trace.log"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Command executed. No on-screen output because stdout was redirected to trace.log."
    echo "  File 'trace.log' created in the current directory."
    echo

    echo "  Step 9: Review the saved file using less."
    read -p "  lab@lpic-lab92:~$ " cmd9
    echo
    [[ "$cmd9" != "less trace.log" ]] && {
        print_error "Incorrect. Use: less trace.log"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Simulated 'less trace.log' view (first few lines):"
    echo "    traceroute to google.com (142.250.72.46), 30 hops max, 60 byte packets"
    echo "     1  192.168.1.1           0.987 ms   0.921 ms   0.904 ms"
    echo "     2  10.0.0.1              6.822 ms   6.599 ms   6.447 ms"
    echo "     3  96.120.45.1          11.947 ms  11.853 ms  11.774 ms"
    echo "     4  68.86.190.45         17.954 ms  17.903 ms  17.861 ms"
    echo "     5  142.250.72.46        23.275 ms  23.163 ms  23.121 ms"
    echo "    (Press 'q' to quit less in a real session.)"
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
    print_info "You have completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
