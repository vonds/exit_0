#!/bin/bash
# Challenge 79: Create a swap file of 1GB and enable it

sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
