#!/bin/bash

# Enhanced troubleshooting script for boot failure after adding a second SATA disk
# Includes auto-detection of root partition, EFI support, fstab/GRUB checks, and optional GRUB reinstall

echo "🔍 Starting boot issue diagnostics..."
echo

# Step 0: Check if system uses UEFI
# UEFI systems have /sys/firmware/efi
if [ -d /sys/firmware/efi ]; then
    echo "🧭 Detected UEFI system."
    UEFI=1
else
    echo "🧭 Detected BIOS/Legacy boot system."
    UEFI=0
fi

# Step 1: Show current disks and partition layout
# This helps you see device names (e.g., /dev/sda vs /dev/sdb)
echo
echo "📦 Step 1: Listing block devices with details..."
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL,UUID
echo

# Step 2: Show UUIDs of all partitions
# UUIDs are important for reliable mounting in fstab and grub.cfg
echo "🔗 Step 2: Displaying partition UUIDs..."
blkid
echo

# Step 3: Attempt to auto-detect Linux root partition (ext4 or btrfs)
# This looks for a partition that is likely the root filesystem
echo "🔍 Step 3: Attempting to auto-detect root partition..."
ROOT_PART=$(lsblk -lno NAME,FSTYPE | grep -E 'ext4|btrfs' | awk '{print $1}' | head -n 1)
ROOT_PART="/dev/$ROOT_PART"

if [ -z "$ROOT_PART" ]; then
    echo "⚠️ Could not auto-detect root partition. Please enter manually."
    read -p "Enter the root partition (e.g., /dev/sda1): " ROOT_PART
else
    echo "✅ Auto-detected likely root partition: $ROOT_PART"
    read -p "Press Enter to use this or type a different one: " manual_root
    [ -n "$manual_root" ] && ROOT_PART="$manual_root"
fi

# Step 4: Mount the root partition
MOUNT_DIR="/mnt/bootfix"
echo "🗂️ Step 4: Mounting $ROOT_PART to $MOUNT_DIR..."
sudo mkdir -p "$MOUNT_DIR"
sudo mount "$ROOT_PART" "$MOUNT_DIR" || { echo "❌ Failed to mount root partition."; exit 1; }

# Step 5: Check /etc/fstab for device name issues
echo
echo "📁 Step 5: Checking /etc/fstab for use of device names instead of UUIDs..."
if [ -f "$MOUNT_DIR/etc/fstab" ]; then
    cat "$MOUNT_DIR/etc/fstab"
    echo
    if grep -q '/dev/sd' "$MOUNT_DIR/etc/fstab"; then
        echo "⚠️ Warning: fstab contains direct device names (e.g., /dev/sda). This can break after disk changes."
        echo "➡️  It's recommended to use UUID=... or LABEL=... instead."
    else
        echo "✅ fstab appears to use UUIDs or labels properly."
    fi
else
    echo "❌ Could not find /etc/fstab in mounted root."
fi

# Step 6: Check GRUB configuration for boot references
echo
echo "🧰 Step 6: Checking GRUB config in /boot..."
if [ -f "$MOUNT_DIR/boot/grub/grub.cfg" ]; then
    grep "linux" "$MOUNT_DIR/boot/grub/grub.cfg" | grep -v "^#" || echo "No linux boot lines found in grub.cfg"
else
    echo "⚠️ grub.cfg not found in /boot."
fi

# Step 7: Mount EFI partition if UEFI system
if [ "$UEFI" -eq 1 ]; then
    echo
    echo "📦 Step 7: Attempting to mount EFI system partition..."

    EFI_PART=$(lsblk -lo NAME,FSTYPE,MOUNTPOINT | grep -i "vfat" | awk '{print $1}' | head -n 1)
    if [ -n "$EFI_PART" ]; then
        echo "✅ Found EFI partition: /dev/$EFI_PART"
        sudo mkdir -p "$MOUNT_DIR/boot/efi"
        sudo mount "/dev/$EFI_PART" "$MOUNT_DIR/boot/efi" || echo "⚠️ Failed to mount EFI partition"
    else
        echo "❌ Could not find EFI partition."
    fi
fi

# Step 8: Offer to chroot and reinstall GRUB
echo
read -p "🛠️  Do you want to chroot into the system and reinstall GRUB? (y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "🔗 Binding virtual filesystems..."
    sudo mount --bind /dev "$MOUNT_DIR/dev"
    sudo mount --bind /proc "$MOUNT_DIR/proc"
    sudo mount --bind /sys "$MOUNT_DIR/sys"

    echo
    echo "🚪 Entering chroot. Run the following inside chroot:"
    echo "    grub-install /dev/sdX       # Replace sdX with the correct boot disk"
    echo "    update-grub                 # Regenerates grub.cfg"
    echo "    exit                        # Exit chroot when done"
    echo
    sudo chroot "$MOUNT_DIR" /bin/bash
fi

echo
echo "✅ Boot issue diagnostic complete. Reboot and test the system after fixing GRUB or fstab."
