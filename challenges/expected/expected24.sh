#!/bin/bash
# Challenge 24: Write a function that returns the square of a number

square() { echo $(( $1 * $1 )); }; square $1
