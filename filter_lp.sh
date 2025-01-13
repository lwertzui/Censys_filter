#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
output_file="output.txt"

# Step 1: Run awk to filter the 18th column and write to an output file
awk '$18 !~ /socket/ {print $18}' "$input_file" > "$output_file"

# Step 2: Run grep and capture the alphanumeric sequences of length 6 or more
grep -A 15 '{."ColorName":' "$output_file" | grep -oP '\w{6,}'
