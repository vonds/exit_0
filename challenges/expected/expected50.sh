#!/bin/bash
# Challenge 50: Create a simple stopwatch that counts seconds until the user presses a key

echo "Press any key to stop the stopwatch..."
SECONDS=0
while :; do
    read -t 1 -n 1 && break
done
echo "Elapsed: $SECONDS seconds"
