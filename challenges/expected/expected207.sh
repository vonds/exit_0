#!/bin/bash

# This script checks for the video card (GPU) connected to the PCI bus
# and displays detailed information as detected by the Linux kernel.

echo "🔍 Checking PCI-connected video card..."

# Step 1: Ensure lspci is available
# lspci is part of the pciutils package
if ! command -v lspci >/dev/null 2>&1; then
    echo "❌ Error: 'lspci' command not found. Please install 'pciutils' and try again."
    exit 1
fi

# Step 2: Display basic VGA/3D controller info
# This shows lines with VGA or 3D — typically GPU info
echo
echo "🎮 Step 1: Basic list of PCI video devices"
echo "-------------------------------------------"
lspci | grep -Ei 'vga|3d'
echo

# Step 3: Show verbose details about the GPU
# -v gives extended info including memory, IRQ, subsystem
# grep -i vga -A 12 includes extra lines after match to show full block
echo "🔎 Step 2: Detailed information about the detected VGA controller"
echo "------------------------------------------------------------------"
lspci -v | grep -Ei 'vga|3d' -A 12
echo

# Step 4: Show kernel driver and device/vendor IDs (optional but useful)
# This helps verify driver loaded and identifies exact hardware
echo "🧰 Step 3: Kernel module and hardware IDs"
echo "------------------------------------------"
lspci -nnk | grep -EiA3 'vga|3d'
echo

# Step 5: Suggest using lshw if available for even more detail
# lshw can show GPU clock speed, capabilities, etc.
if command -v lshw >/dev/null 2>&1; then
    echo "💡 Bonus: Using 'lshw -c video' for additional details (if supported)..."
    echo "--------------------------------------------------------------"
    sudo lshw -c video
else
    echo "ℹ️  Tip: Install 'lshw' for even more detailed GPU info: sudo apt install lshw"
fi

# Final tip
echo
echo "✅ Done! Use the above output to verify the GPU matches your expected model and manufacturer."
echo "   You can search the PCI ID online or compare against product specs."
