#!/bin/bash
# Challenge 55: Implement a countdown timer from 10 seconds

for ((i = 10; i > 0; i--)); do
    echo "$i"
    sleep 1
done
echo "Time's up!"
