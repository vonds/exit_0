#!/bin/bash
# Challenge 99: Find and delete all empty directories under /tmp

find /tmp -type d -empty -delete
