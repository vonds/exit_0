#!/bin/bash
# Challenge 26: Check if a file exists and print a message

[ -f "$1" ] && echo "File exists" || echo "File not found"
