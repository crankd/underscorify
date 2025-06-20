#!/usr/local/bin/bash

# update_release_notes.sh - Automatically update release notes from git commits
# Usage: ./update_release_notes.sh [version] [commit_message]

set -e

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to extract version from commit message
extract_version() {
    local commit_msg="$1"
    if [[ "$commit_msg" =~ v([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Function to generate release notes from git commits
generate_release_notes() {
    local version="$1"
    local last_tag="$2"
    
    echo "### v$version ($(date +%Y-%m-%d))"
    
    if [[ -n "$last_tag" ]]; then
        # Get commits since last tag
        git log --oneline --no-merges "${last_tag}..HEAD" | while read -r commit; do
            local hash=$(echo "$commit" | cut -d' ' -f1)
            local message=$(echo "$commit" | cut -d' ' -f2-)
            
            # Skip version bump commits
            if [[ "$message" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
                continue
            fi
            
            # Convert commit message to bullet point
            echo "- **$(echo "$message" | sed 's/^./\U&/')**"
        done
    else
        echo "- **Initial release**"
    fi
}

# Function to update README with new release notes
update_readme() {
    local version="$1"
    local release_notes="$2"
    local readme_file="README.md"
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Find the Release Notes section and add new version
    local in_release_notes=false
    local added_new_version=false
    
    while IFS= read -r line; do
        echo "$line" >> "$temp_file"
        
        # Check if we're entering Release Notes section
        if [[ "$line" == "## Release Notes" ]]; then
            in_release_notes=true
            continue
        fi
        
        # If we're in Release Notes and find the first version, add our new version before it
        if [[ "$in_release_notes" == true && "$line" =~ ^###\ v[0-9]+\.[0-9]+\.[0-9]+ && "$added_new_version" == false ]]; then
            echo "" >> "$temp_file"
            echo "$release_notes" >> "$temp_file"
            echo "" >> "$temp_file"
            added_new_version=true
        fi
    done < "$readme_file"
    
    # If we didn't add the version (no existing versions), add it at the end of Release Notes
    if [[ "$added_new_version" == false && "$in_release_notes" == true ]]; then
        echo "" >> "$temp_file"
        echo "$release_notes" >> "$temp_file"
    fi
    
    # Replace original file
    mv "$temp_file" "$readme_file"
}

# Function to update Version History
update_version_history() {
    local version="$1"
    local description="$2"
    local readme_file="README.md"
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    local in_version_history=false
    local added_new_version=false
    
    while IFS= read -r line; do
        echo "$line" >> "$temp_file"
        
        # Check if we're entering Version History section
        if [[ "$line" == "## Version History" ]]; then
            in_version_history=true
            continue
        fi
        
        # If we're in Version History and find the first version, add our new version before it
        if [[ "$in_version_history" == true && "$line" =~ ^-\ \*\*v[0-9]+\.[0-9]+\.[0-9]+\*\* && "$added_new_version" == false ]]; then
            echo "- **v$version**: $description" >> "$temp_file"
            added_new_version=true
        fi
    done < "$readme_file"
    
    # If we didn't add the version (no existing versions), add it at the end of Version History
    if [[ "$added_new_version" == false && "$in_version_history" == true ]]; then
        echo "- **v$version**: $description" >> "$temp_file"
    fi
    
    # Replace original file
    mv "$temp_file" "$readme_file"
}

# Main script logic
main() {
    local version="$1"
    local commit_message="$2"
    
    if [[ -z "$version" ]]; then
        echo -e "${RED}Error: Version number required${NC}"
        echo "Usage: $0 <version> [commit_message]"
        exit 1
    fi
    
    # Validate version format
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid version format. Use x.y.z${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}Updating release notes for v$version...${NC}"
    
    # Get last tag
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    # Generate release notes
    local release_notes=$(generate_release_notes "$version" "$last_tag")
    
    # Update README
    update_readme "$version" "$release_notes"
    
    # Update Version History with description from commit message
    local description="${commit_message:-"Release v$version"}"
    update_version_history "$version" "$description"
    
    echo -e "${GREEN}Release notes updated for v$version${NC}"
    echo -e "${YELLOW}Don't forget to commit and push your changes!${NC}"
}

# Run main function with arguments
main "$@" 