#!/bin/bash
# Challenge 97: Create a bootable ISO image from a folder (simulation)

genisoimage -o boot.iso -b isolinux.bin -c boot.cat -no-emul-boot ./myiso
