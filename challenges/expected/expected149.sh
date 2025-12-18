#!/bin/bash
# Challenge 149: Log & Error Troubleshooting
sudo journalctl -u ssh.service --since "1 hour ago"