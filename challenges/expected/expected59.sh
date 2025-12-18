#!/bin/bash
# Challenge 59: Simulate flipping a coin 100 times and count heads/tails

heads=0
tails=0
for ((i=0; i<100; i++)); do
    flip=$(( RANDOM % 2 ))
    if [ $flip -eq 0 ]; then
        heads=$((heads + 1))
    else
        tails=$((tails + 1))
    fi
done
echo "Heads: $heads, Tails: $tails"
