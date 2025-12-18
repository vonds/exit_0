#!/bin/bash
# Challenge 82: Write a script that detects if the system is online

ping -c 1 8.8.8.8 &>/dev/null && echo "Online" || echo "Offline"
