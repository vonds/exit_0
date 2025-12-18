#!/bin/bash
# Challenge 46: Monitor a directory and report any new files every 5 seconds (run once)

before=$(ls)
sleep 5
after=$(ls)
comm -13 <(echo "$before" | sort) <(echo "$after" | sort)
