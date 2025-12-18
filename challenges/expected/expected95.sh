#!/bin/bash
# Challenge 95: Simulate a basic firewall rule using iptables to block port 80

sudo iptables -A INPUT -p tcp --dport 80 -j DROP
