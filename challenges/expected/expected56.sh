#!/bin/bash
# Challenge 56: Check if the script is run as root

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
else
    echo "You are root"
fi
