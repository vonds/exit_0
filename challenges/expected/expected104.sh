#!/bin/bash
# Challenge 104: System Installation & LVM

sudo lvcreate -n lv_storage -L 1G vg_data
