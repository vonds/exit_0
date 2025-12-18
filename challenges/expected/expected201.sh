#!/bin/bash
read -p "Enter network interface name (e.g., eth0): " iface
addr_file="/sys/class/net/$iface/address"

if [ -f "$addr_file" ]; then
  mac=$(cat "$addr_file")
  echo "The MAC address for $iface is: $mac"
else
  echo "That interface doesn't exist."
fi