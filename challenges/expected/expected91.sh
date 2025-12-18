#!/bin/bash
# Challenge 91: Create a loop that restarts Apache if it crashes (simulate once)

if ! pgrep apache2 &>/dev/null; then
    echo "Apache not running. Restarting..."
    sudo systemctl restart apache2
fi
