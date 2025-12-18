#!/bin/bash

# Lab 112: /proc Hardware Resources (interrupts, ioports, iomem)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 112: /proc Hardware Resources (interrupts, ioports, iomem)"
LAB_ID="lab112"
LAB_XP=8090
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
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
  center_text "Explore how your system assigns hardware resources by reading /proc:"
  center_text "interrupts (IRQs), I/O ports, and physical memory maps, and correlate a device"
  center_text "to its IRQ and kernel module."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: View /proc/interrupts snapshot
  echo "  Step 1: Show a snapshot of the first 10 lines of /proc/interrupts."
  echo "          (Hint: cat /proc/interrupts | head -n 10)"
  read -p "  lab@lpic-lab112:~$ " cmd1
  echo
  if [[ "$cmd1" != "cat /proc/interrupts | head -n 10" && "$cmd1" != "head -n 10 /proc/interrupts" && "$cmd1" != "cat /proc/interrupts | head" ]]; then
    print_error "Incorrect. Try: cat /proc/interrupts | head -n 10"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "             CPU0       CPU1       CPU2       CPU3"
  echo "  0:         1024        980       1002        987   IO-APIC   2-edge      timer"
  echo "  1:            2          1          0          0   IO-APIC   1-edge      i8042"
  echo "  8:            0          0          0          0   IO-APIC   8-edge      rtc0"
  echo "  9:            0          0          0          0   IO-APIC   9-fasteoi   acpi"
  echo " 16:          250        211        198        205   IO-APIC  16-fasteoi   e1000"
  echo " 23:            0          0          0          0   IO-APIC  23-fasteoi   ehci_hcd:usb1"
  echo " NMI:          15         12         10         11   Non-maskable interrupts"
  echo " LOC:        1012        990         995         993   Local timer interrupts"
  echo

  # STEP 2: Live changes in interrupt counts
  echo "  Step 2: Watch interrupt counts update live (1-second refresh, highlight changes)."
  echo "          (Hint: watch -n 1 -d cat /proc/interrupts)"
  read -p "  lab@lpic-lab112:~$ " cmd2
  echo
  if [[ "$cmd2" != "watch -n 1 -d cat /proc/interrupts" && "$cmd2" != "watch -d -n 1 cat /proc/interrupts" ]]; then
    print_error "Incorrect. Use: watch -n 1 -d cat /proc/interrupts"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Every 1.0s: cat /proc/interrupts"
  echo "             CPU0       CPU1       CPU2       CPU3"
  echo " 16:          251        213        199        206   IO-APIC  16-fasteoi   e1000"
  echo "  (Press Ctrl+C to stop)"
  echo

  # STEP 3: Locate the network card IRQ line
  echo "  Step 3: Filter /proc/interrupts to show the line for the e1000 NIC."
  echo "          (Hint: grep -i e1000 /proc/interrupts)"
  read -p "  lab@lpic-lab112:~$ " cmd3
  echo
  if [[ "$cmd3" != "grep -i e1000 /proc/interrupts" && "$cmd3" != "cat /proc/interrupts | grep -i e1000" ]]; then
    print_error "Incorrect. Try: grep -i e1000 /proc/interrupts"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  16:          251        213        199        206   IO-APIC  16-fasteoi   e1000"
  echo

  # STEP 4: Sum total interrupts serviced by that IRQ across CPUs
  echo "  Step 4: Compute the total interrupts on that line (sum CPU columns)."
  echo "          (Hint: awk to add fields 2..NF-3 on the matched e1000 line)"
  read -p "  lab@lpic-lab112:~$ " cmd4
  echo
  if [[ "$cmd4" != "awk '/e1000/ {s=0; for(i=2;i<=NF-3;i++) s+=$i; print s}' /proc/interrupts" && \
        "$cmd4" != "grep -i e1000 /proc/interrupts | awk '{s=0; for(i=2;i<=NF-3;i++) s+=$i; print s}'" ]]; then
    print_error "Incorrect. Example: awk '/e1000/ {s=0; for(i=2;i<=NF-3;i++) s+=$i; print s}' /proc/interrupts"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  869"
  echo

  # STEP 5: Inspect I/O ports (legacy/PCI BAR I/O windows)
  echo "  Step 5: Show the first 15 lines of /proc/ioports."
  echo "          (Hint: head -n 15 /proc/ioports)"
  read -p "  lab@lpic-lab112:~$ " cmd5
  echo
  if [[ "$cmd5" != "head -n 15 /proc/ioports" && "$cmd5" != "cat /proc/ioports | head -n 15" ]]; then
    print_error "Incorrect. Use: head -n 15 /proc/ioports"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  0000-001f : dma1"
  echo "  0020-0021 : pic1"
  echo "  0040-0043 : timer0"
  echo "  0060-0060 : keyboard"
  echo "  0064-0064 : keyboard"
  echo "  00a0-00a1 : pic2"
  echo "  00f0-00ff : fpu"
  echo "  02f8-02ff : serial"
  echo "  03c0-03df : vga+"
  echo "  c000-c07f : ich6"
  echo "  e000-e03f : Intel 82540EM (e1000)"
  echo

  # STEP 6: Inspect physical memory map
  echo "  Step 6: Show 'System RAM' regions from /proc/iomem."
  echo "          (Hint: grep -i 'System RAM' /proc/iomem | head -n 5)"
  read -p "  lab@lpic-lab112:~$ " cmd6
  echo
  if [[ "$cmd6" != "grep -i 'System RAM' /proc/iomem | head -n 5" && \
        "$cmd6" != "cat /proc/iomem | grep -i 'System RAM' | head -n 5" ]]; then
    print_error "Incorrect. Example: grep -i 'System RAM' /proc/iomem | head -n 5"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  00000000-00000fff : System RAM"
  echo "  00100000-bfffffff : System RAM"
  echo "  100000000-3ffffffff : System RAM"
  echo

  # STEP 7: Correlate PCI device -> driver -> module
  echo "  Step 7: From lspci, print the Ethernet device and show its driver section."
  echo "          (Hint: lspci -nnk | grep -A2 -i ethernet)"
  read -p "  lab@lpic-lab112:~$ " cmd7
  echo
  if [[ "$cmd7" != "lspci -nnk | grep -A2 -i ethernet" && "$cmd7" != "sudo lspci -nnk | grep -A2 -i ethernet" ]]; then
    print_error "Incorrect. Use: lspci -nnk | grep -A2 -i ethernet"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  00:03.0 Ethernet controller [0200]: Intel Corporation 82540EM Gigabit Ethernet [8086:100e]"
  echo "          Subsystem: Intel Corporation PRO/1000 MT Desktop Adapter"
  echo "          Kernel driver in use: e1000"
  echo

  # STEP 8: Verify the module for that driver is loaded
  echo "  Step 8: Confirm that the e1000 kernel module is currently loaded."
  echo "          (Hint: lsmod | grep ^e1000)"
  read -p "  lab@lpic-lab112:~$ " cmd8
  echo
  if [[ "$cmd8" != "lsmod | grep -E '^e1000(\\s|$)'" && "$cmd8" != "lsmod | grep ^e1000" && "$cmd8" != "grep e1000 /proc/modules" ]]; then
    print_error "Incorrect. Example: lsmod | grep ^e1000"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  e1000               155648  0"
  echo

  print_success "Excellent!"
  print_info "You read /proc/interrupts (with live monitoring), located a device's IRQ,"
  print_info "summed interrupt counts, surveyed legacy I/O ports in /proc/ioports, inspected"
  print_info "physical memory regions in /proc/iomem, and correlated a PCI device to its driver/module."
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
