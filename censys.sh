#!/bin/bash

# Tool name and version
APP_NAME="extract-ips-ports"
VERSION="1.9"

# Flags for verbosity levels
VERBOSE=false
EXTRA_VERBOSE=false
OUTPUT_FILE=""

# Print usage/help message
usage() {
  echo "Usage: $APP_NAME [-v | -vv] [-o <output_file>] <input_file>"
  echo ""
  echo "Options:"
  echo "  -h, --help           Show this help message and exit"
  echo "  -V, --version        Show version information and exit"
  echo "  -v, --verbose        Show detected IPs during processing"
  echo "  -vv, --extra-verbose Show full debug information during processing"
  echo "  -o, --output=<file>  Specify a file to save the final output"
  echo ""
  echo "Description:"
  echo "  This tool extracts IP addresses and associated ports from a file and outputs them in the format:"
  echo "    <IP> <PORTS>"
  echo ""
  echo "  Example:"
  echo "    $APP_NAME -o results.txt file.html"
}

# Print version information
version() {
  echo "$APP_NAME version $VERSION"
}

# Exit if no input is provided
if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

# Parse command-line arguments
while [[ "$1" ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -V|--version)
      version
      exit 0
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -vv|--extra-verbose)
      EXTRA_VERBOSE=true
      VERBOSE=true  # Extra-verbose implies verbose
      shift
      ;;
    -o|--output=*)
      if [[ "$1" == "-o" ]]; then
        OUTPUT_FILE="$2"
        shift 2
      else
        OUTPUT_FILE="${1#*=}"
        shift
      fi
      ;;
    -*)
      echo "Invalid option: $1"
      usage
      exit 1
      ;;
    *)
      input_file="$1"
      shift
      ;;
  esac
done

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
  echo "Error: File '$input_file' not found"
  exit 1
fi

# Declare an associative array to store IPs and their ports
declare -A ip_ports
ip_count=0  # Counter for detected IPs

# Start the timer
start_time=$(date +%s)

# Initial scanning message
echo "Scanning $input_file..."

# Process the file line by line
while IFS= read -r line; do
  # Extract the IP from the line
  ip=$(echo "$line" | grep -oP '\d{1,3}(\.\d{1,3}){3}')

  # Skip if the IP is 1.1.1.0
  if [[ "$ip" == "1.1.1.0" ]]; then
    $EXTRA_VERBOSE && echo "Skipping IP: $ip (blacklisted)"
    continue
  fi

  # If an IP address is found, extract the port
  if [[ -n "$ip" ]]; then
    # Increment the IP counter
    ((ip_count++))

    # Verbose logging for detected IP
    $VERBOSE && echo "Found IP: $ip"

    # Extract the port (remove # and everything after it)
    port=$(echo "$line" | grep -oP '#\d+' | sed 's/#//')

    # Extra-verbose logging
    $EXTRA_VERBOSE && {
      echo "Line: $line"
      echo "Extracted IP: $ip"
      echo "Extracted port: $port"
    }

    # Check if the IP has been encountered before
    if [[ -n "${ip_ports[$ip]}" ]]; then
      if [[ -n "$port" ]]; then
        # If the port is not already in the list for this IP, append it
        if ! [[ "${ip_ports[$ip]}" =~ $port ]]; then
          ip_ports["$ip"]="${ip_ports[$ip]} $port"
          $EXTRA_VERBOSE && echo "Appending port $port to IP $ip"
        else
          $EXTRA_VERBOSE && echo "Port $port already exists for IP $ip"
        fi
      fi
    else
      # If the IP is new, store it with the port
      ip_ports["$ip"]="$port"
      $EXTRA_VERBOSE && echo "Adding new IP $ip with port $port"
    fi
  fi
done < "$input_file"

# Stop the timer
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Prepare final output
final_output=""
for ip in "${!ip_ports[@]}"; do
  final_output+="$ip ${ip_ports[$ip]}\n"
done

# Print or save the final output
if [[ -n "$OUTPUT_FILE" ]]; then
  echo -e "$final_output" > "$OUTPUT_FILE"
  echo "Output saved to $OUTPUT_FILE"
else
  echo -e "$final_output"
fi

# Final summary message
echo "Scanned $ip_count IPs in $elapsed_time seconds."
