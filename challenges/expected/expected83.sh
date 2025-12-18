#!/bin/bash
# Challenge 83: Show the number of failed SSH login attempts

grep -i "failed password" /var/log/auth.log | wc -l
