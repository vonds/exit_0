#!/bin/bash
# Challenge 121: Advanced systemd & journalctl

sudo journalctl -u sshd --since "10 minutes ago"
