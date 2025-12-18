#!/bin/bash
# Challenge 43: Simulate a dice roll and print the result (1-6)

roll=$(( RANDOM % 6 + 1 ))
echo "You rolled a $roll"
