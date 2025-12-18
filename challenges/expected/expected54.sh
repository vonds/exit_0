#!/bin/bash
# Challenge 54: Write a script that pings google.com 5 times and logs the result

ping -c 5 google.com > pinglog.txt
echo "Ping result saved to pinglog.txt"
