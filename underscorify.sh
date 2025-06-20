#!/bin/bash

# Ensure running with Bash
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# underscorify - Replace non-alphanumeric characters with underscore, preserving file extensions
# Usage: underscorify "filename.ext" or underscorify "string"
# Usage: underscorify --hidden "filename.ext" (allow renaming hidden files)
# Rules:
# 1. accept file name or file path as argument
# 2. Replace all non-alphanumeric characters in the base name of the file with underscores (alphanumeric_basename)
# 3. Replace multiple underscores in clean name with single underscore (clean_basename)
# 4. rename file (mv) base name as clean_basename
# 5. By default, hidden files (starting with .) are NOT renamed. Use --hidden to allow renaming hidden files.

# Color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
RENAME_HIDDEN=false
INPUT_ARG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --hidden)
            RENAME_HIDDEN=true
            shift
            ;;
        *)
            INPUT_ARG="$1"
            shift
            ;;
    esac
done

underscorify() {
    local input="$1"
    # Trim leading/trailing spaces using perl for Unicode support
    input=$(echo "$input" | perl -CSDA -pe 's/^\s+|\s+$//g')
    
    # Check if input has a file extension
    if [[ "$input" == *.* ]]; then
        local basename="${input%.*}"
        local extension="${input##*.}"
        # Trim spaces from basename as well using perl
        basename=$(echo "$basename" | perl -CSDA -pe 's/^\s+|\s+$//g')
        # Use perl for Unicode support - preserve Unicode letters and numbers
        local alphanumeric_basename=$(echo "$basename" | perl -CSDA -pe 's/[^\p{L}\p{N}]/_/g')
        local clean_basename=$(echo "$alphanumeric_basename" | perl -CSDA -pe 's/_+/_/g')
        # Remove trailing underscore before extension
        clean_basename=$(echo "$clean_basename" | perl -CSDA -pe 's/_+$//')
        echo "${clean_basename}.${extension}"
    else
        # Use perl for Unicode support - preserve Unicode letters and numbers
        echo "$input" | perl -CSDA -pe 's/[^\p{L}\p{N}]/_/g' | perl -CSDA -pe 's/_+/_/g' | perl -CSDA -pe 's/_+$//'
    fi
}

# Handle input from argument or stdin
if [ -z "$INPUT_ARG" ]; then
    # For stdin processing, we need to track potential conflicts
    declare -A processed_names
    declare -A original_to_cleaned
    
    while IFS= read -r line; do
        # By default, skip hidden files unless --hidden is set
        if [[ "$RENAME_HIDDEN" != true ]] && [[ "$line" == .* ]]; then
            echo -e "${YELLOW}skipped hidden file: $line${NC}"
        else
            cleaned=$(underscorify "$line")
            
            # Check for naming conflicts
            if [[ -n "$cleaned" ]] && [[ "$cleaned" != "$line" ]]; then
                if [[ -n "${processed_names[$cleaned]}" ]]; then
                    echo -e "${RED}CONFLICT: '$line' and '${original_to_cleaned[$cleaned]}' would both become '$cleaned'${NC}"
                else
                    processed_names[$cleaned]=1
                    original_to_cleaned[$cleaned]="$line"
                    echo "$cleaned"
                fi
            else
                echo "$cleaned"
            fi
        fi
    done
else
    # Use the trimmed input for messages
    original_trimmed=$(echo "$INPUT_ARG" | perl -CSDA -pe 's/^\s+|\s+$//g')
    cleaned=$(underscorify "$original_trimmed")
    
    # By default, skip hidden files unless --hidden is set
    if [[ "$RENAME_HIDDEN" != true ]] && [[ "$original_trimmed" == .* ]]; then
        echo -e "${YELLOW}skipped hidden file: $original_trimmed${NC}"
    # If it's a file operation (contains extension), rename the file
    elif [[ "$original_trimmed" == *.* ]] && [[ "$original_trimmed" != "$cleaned" ]] && [[ -f "$original_trimmed" ]]; then
        # Check if target file already exists
        if [[ -f "$cleaned" ]]; then
            echo -e "${RED}CONFLICT: Cannot rename '$original_trimmed' to '$cleaned' - file already exists${NC}"
        else
            mv "$original_trimmed" "$cleaned"
            echo -e "renamed \033[0;36m$original_trimmed\033[0m to \033[0;32m$cleaned\033[0m"
        fi
    elif [[ "$original_trimmed" == *.* ]] && [[ "$original_trimmed" != "$cleaned" ]]; then
        echo -e "would rename \033[0;36m$original_trimmed\033[0m to \033[0;32m$cleaned\033[0m"
    else
        echo "$cleaned"
    fi
fi