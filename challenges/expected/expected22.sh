#!/bin/bash
# Challenge 22: Use a while loop to sum numbers from 1 to 100

sum=0; i=1; while [ $i -le 100 ]; do sum=$((sum + i)); i=$((i + 1)); done; echo $sum
