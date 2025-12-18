#!/bin/bash
# Challenge 28: Write to a log file with the current date and message

echo "$(date): $1" >> mylog.txt
