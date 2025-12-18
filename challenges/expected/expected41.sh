#!/bin/bash
# Challenge 41: Check if a number is prime

read -p "Enter a number: " num
is_prime=1
for ((i = 2; i*i <= num; i++)); do
    if (( num % i == 0 )); then
        is_prime=0
        break
    fi
done
if (( num < 2 )); then
    is_prime=0
fi
[ $is_prime -eq 1 ] && echo "Prime" || echo "Not prime"
