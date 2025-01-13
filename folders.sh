#!/bin/bash

# Function to check a file for UUIDs in raw two-column HEX format
extract_raw_hex_uuids_and_create_folders() {
    local file_path="$1"
    local output_dir="extracted"

    # Check if the file exists
    if [[ ! -f "$file_path" ]]; then
        echo "File '$file_path' not found."
        return 1
    fi

    # Create the 'extracted' folder if it doesn't exist
    mkdir -p "$output_dir"

    # Scan the file for two-column raw HEX UUIDs
    echo "Scanning '$file_path' for raw HEX UUIDs..."
    uuids=$(awk '{print $1 $2}' "$file_path" | grep -Eo '[0-9a-fA-F]{32}' | sort -u)

    if [[ -z "$uuids" ]]; then
        echo "No raw HEX UUIDs found in '$file_path'."
        return 0
    fi

    # Format the raw HEX into standard UUID format and create folders
    echo "Creating folders for detected UUIDs..."
    while IFS= read -r raw_uuid; do
        formatted_uuid=$(echo "$raw_uuid" | sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/')
        uuid_dir="$output_dir/$formatted_uuid"
        mkdir -p "$uuid_dir"
        echo "Created folder: $uuid_dir"
    done <<< "$uuids"
}
