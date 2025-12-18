#!/bin/bash
# Challenge 64: Create a new user 'testuser' and set password (requires root)

useradd testuser && echo "testuser:password" | chpasswd
