#!/bin/bash
# Challenge 73: Check if a package is installed (Debian-based)

dpkg -l | grep <package_name>
