#!/bin/bash
# Challenge 63: Show all running services (systemd)

systemctl list-units --type=service --state=running
