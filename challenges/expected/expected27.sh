#!/bin/bash
# Challenge 27: Create a backup copy of a file with a timestamp

cp "$1" "$1_$(date +%Y%m%d%H%M%S).bak"
