#!/bin/bash
read -p "Enter your age: " age
if (( age >= 18 )); then
  echo "You are an adult."
else
  echo "You are a minor."
fi
