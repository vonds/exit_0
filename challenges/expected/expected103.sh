#!/bin/bash
# Challenge 103: System Installation & LVM

sudo pvcreate /dev/sdb1 && sudo vgcreate vg_data /dev/sdb1
