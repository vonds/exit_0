#!/bin/bash
# Challenge 36: Prompt the user for a username and check if that user exists on the system

read -p "Enter username: " user
if id "$user" &>/dev/null; then
    echo "User exists"
else
    echo "User does not exist"
fi
