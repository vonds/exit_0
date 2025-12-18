#!/bin/bash
# Challenge 30: List all executable files in the current directory

find . -maxdepth 1 -type f -executable
