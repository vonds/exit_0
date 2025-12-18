#!/bin/bash
# Challenge 81: Simulate a login system that asks for username and password

read -p "Username: " u
read -sp "Password: " p
echo
if [[ "$u" == "admin" && "$p" == "12345" ]]; then
    echo "Access granted"
else
    echo "Access denied"
fi
