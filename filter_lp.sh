#!/bin/bash

# Check if input file is provided as an argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Input file from the first argument
input_file="$1"

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' does not exist."
    exit 1
fi

# Echo coherent ASCII data to the terminal
strings "$input_file" | grep -E '^[\x20-\x7E]+$'
