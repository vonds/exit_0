#!/bin/bash

# 🎯 Purpose:
# Practice identifying the kernel module (driver) in use for a given PCI device.
# This is useful for debugging hardware issues or verifying compatibility.

echo "🔍 Welcome to the Kernel Module Lookup Practice Tool"
echo

# Step 1: Show a list of PCI devices with numbers
# lspci lists all detected PCI devices; this is your reference list
echo "📋 Step 1: PCI Devices on this system:"
echo "-----------------------------------------"
lspci
echo
echo "Look at the list above and find the device you're interested in (e.g., RAID, GPU, Ethernet)."
echo

# Step 2: Prompt user for a specific PCI device address
# The address looks like 03:00.0 and uniquely identifies the PCI device
read -p "🎯 Enter the PCI device address (e.g., 03:00.0): " PCI_ADDR

# Step 3: Use lspci -k -s <device> to show the kernel module info
# -k shows kernel driver info; -s filters to a single device
echo
echo "🧰 Step 2: Checking kernel module for PCI device $PCI_ADDR..."
echo "-------------------------------------------------------------"

# Confirm that the user input looks valid (e.g., 00:1f.2 or 03:00.0)
if [[ "$PCI_ADDR" =~ ^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-9]$ ]]; then
    # Show the full lspci kernel module output for the selected device
    lspci -k -s "$PCI_ADDR"
else
    echo "❌ Invalid PCI address format. Please use format like 03:00.0"
    exit 1
fi

echo
echo "✅ Done. Review the output above to see:"
echo "   - 'Kernel driver in use': the driver currently loaded"
echo "   - 'Kernel modules': other drivers available (but not necessarily in use)"
echo
echo "💡 Tip: You can also run 'modinfo <module_name>' to learn more about the driver."
