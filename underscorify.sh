#!/bin/bash

# underscorify - Replace non-alphanumeric characters with underscore, preserving file extensions
# Usage: underscorify "filename.ext" or underscorify "string"
# Rules:
# 1. accept file name or file path as argument
# 2. Replace all non-alphanumeric characters in the base name of the file with underscores (alphanumeric_basename)
# 3. Replace multiple underscores in clean name with single underscore (clean_basename)
# 4. rename file (mv) base name as clean_basename

# Color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

underscorify() {
    local input="$1"
    # Trim leading/trailing spaces
    input=$(echo "$input" | sed 's/^ *//;s/ *$//')
    
    # Check if input has a file extension
    if [[ "$input" == *.* ]]; then
        local basename="${input%.*}"
        local extension="${input##*.}"
        # Trim spaces from basename as well
        basename=$(echo "$basename" | sed 's/^ *//;s/ *$//')
        local alphanumeric_basename=$(echo "$basename" | sed 's/[^a-zA-Z0-9]/_/g')
        local clean_basename=$(echo "$alphanumeric_basename" | sed 's/__*/_/g')
        echo "${clean_basename}.${extension}"
    else
        echo "$input" | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/__*/_/g'
    fi
}

# Handle input from argument or stdin
if [ $# -eq 0 ]; then
    while IFS= read -r line; do
        underscorify "$line"
    done
else
    # Use the trimmed input for messages
    original_trimmed=$(echo "$1" | sed 's/^ *//;s/ *$//')
    cleaned=$(underscorify "$original_trimmed")
    
    # If it's a file operation (contains extension), rename the file
    if [[ "$original_trimmed" == *.* ]] && [[ "$original_trimmed" != "$cleaned" ]] && [[ -f "$original_trimmed" ]]; then
        mv "$original_trimmed" "$cleaned"
        echo -e "renamed \033[0;36m$original_trimmed\033[0m to \033[0;32m$cleaned\033[0m"
    elif [[ "$original_trimmed" == *.* ]] && [[ "$original_trimmed" != "$cleaned" ]]; then
        echo -e "would rename \033[0;36m$original_trimmed\033[0m to \033[0;32m$cleaned\033[0m"
    else
        echo "$cleaned"
    fi
fi