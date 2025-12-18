#!/bin/bash
# Challenge 93: Compare two directories and list files only in one

diff -rq dir1 dir2 | grep "Only in"
