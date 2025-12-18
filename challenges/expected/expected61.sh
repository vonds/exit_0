#!/bin/bash
# Challenge 61: List all users on the system with /bin/bash as their shell

awk -F: '$7 == "/bin/bash" { print $1 }' /etc/passwd
