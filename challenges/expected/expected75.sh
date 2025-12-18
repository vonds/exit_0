#!/bin/bash
# Challenge 75: Add a line to /etc/hosts mapping 127.0.0.1 to custom.local

echo "127.0.0.1 custom.local" | sudo tee -a /etc/hosts
