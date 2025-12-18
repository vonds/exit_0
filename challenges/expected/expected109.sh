#!/bin/bash
# Challenge 109: Network Configuration

sudo nmcli con mod eth0 ipv4.method manual ipv4.addresses 192.168.1.50/24 ipv4.gateway 192.168.1.1 ipv4.dns 8.8.8.8
