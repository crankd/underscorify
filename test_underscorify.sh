#!/bin/bash

# Test suite for underscorify script
# Run with: bash test_underscorify.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local input="$2"
    local expected_output="$3"
    local test_type="$4"  # "string", "file", "stdin"
    local additional_args="$5"
    
    echo -n "Testing: $test_name... "
    
    local actual_output=""
    
    case "$test_type" in
        "string")
            actual_output=$(bash ./underscorify.sh "$input" $additional_args)
            ;;
        "file")
            # Create a test file
            echo "test content" > "$input"
            actual_output=$(bash ./underscorify.sh "$input" $additional_args)
            # Clean up
            rm -f "$input" "$actual_output"
            ;;
        "stdin")
            actual_output=$(echo "$input" | bash ./underscorify.sh $additional_args)
            ;;
    esac
    
    # Remove any "renamed" or "would rename" messages for comparison
    # Also remove color codes - use perl for better ANSI escape sequence handling
    actual_output=$(echo "$actual_output" | perl -pe 's/\033\[[0-9;]*m//g' | sed 's/^renamed .* to //' | sed 's/^would rename .* to //')
    # Remove carriage returns, tabs, and trim whitespace
    actual_output=$(echo "$actual_output" | tr -d '\r\t' | sed 's/^ *//;s/ *$//')
    expected_output=$(echo "$expected_output" | tr -d '\r\t' | sed 's/^ *//;s/ *$//')
    
    # Byte-level comparison using hexdump for debugging
    if [ "$actual_output" = "$expected_output" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected: '$expected_output'"
        echo "  Got:      '$actual_output'"
        echo "  Expected (hex): $(echo -n "$expected_output" | hexdump -C | head -1)"
        echo "  Got (hex):      $(echo -n "$actual_output" | hexdump -C | head -1)"
        ((TESTS_FAILED++))
    fi
}

# Function to run a test with full output (including rename messages)
run_test_full() {
    local test_name="$1"
    local input="$2"
    local expected_output="$3"
    local test_type="$4"  # "string", "file", "stdin"
    local additional_args="$5"  # Additional arguments for the test
    
    echo -n "Testing: $test_name... "
    
    local actual_output=""
    
    case "$test_type" in
        "string")
            actual_output=$(bash ./underscorify.sh "$input" $additional_args)
            ;;
        "file")
            # Create a test file
            echo "test content" > "$input"
            actual_output=$(bash ./underscorify.sh "$input" $additional_args)
            # Clean up
            rm -f "$input" "$actual_output"
            ;;
        "stdin")
            # Handle multi-line input by checking for actual newlines
            if [[ "$input" == *$'\n'* ]]; then
                # Use printf with %b to interpret escape sequences
                actual_output=$(printf "%b" "$input" | bash ./underscorify.sh $additional_args)
            else
                # Single line input
                actual_output=$(printf "%s\n" "$input" | bash ./underscorify.sh $additional_args)
            fi
            ;;
    esac
    
    # Remove color codes for comparison - use perl for better ANSI escape sequence handling
    actual_output=$(echo "$actual_output" | perl -pe 's/\033\[[0-9;]*m//g')
    # Remove carriage returns, tabs, and trim whitespace
    actual_output=$(echo "$actual_output" | tr -d '\r\t' | sed 's/^ *//;s/ *$//')
    expected_output=$(echo "$expected_output" | tr -d '\r\t' | sed 's/^ *//;s/ *$//')
    
    # Byte-level comparison using hexdump for debugging
    if [ "$actual_output" = "$expected_output" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected: '$expected_output'"
        echo "  Got:      '$actual_output'"
        echo "  Expected (hex): $(echo -n "$expected_output" | hexdump -C | head -1)"
        echo "  Got (hex):      $(echo -n "$actual_output" | hexdump -C | head -1)"
        ((TESTS_FAILED++))
    fi
}

# Function to test file renaming behavior
test_file_rename() {
    local test_name="$1"
    local input="$2"
    local expected_output="$3"
    local should_rename="$4"  # "yes" or "no"
    
    echo -n "Testing: $test_name... "
    
    # Create a test file
    echo "test content" > "$input"
    
    local script_output=$(bash ./underscorify.sh "$input")
    
    # Check if file was renamed
    if [ "$should_rename" = "yes" ]; then
        if [ -f "$expected_output" ] && [ ! -f "$input" ]; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC}"
            echo "  Expected file to be renamed from '$input' to '$expected_output'"
            ((TESTS_FAILED++))
        fi
        # Clean up
        rm -f "$expected_output"
    else
        if [ -f "$input" ]; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC}"
            echo "  Expected file to remain as '$input'"
            ((TESTS_FAILED++))
        fi
        # Clean up
        rm -f "$input"
    fi
}

echo "Running underscorify test suite..."
echo "=================================="

# Test 1: Basic string processing (no extension)
run_test "Basic string with spaces" "hello world" "hello_world" "string"

# Test 2: String with special characters
run_test "String with special chars" "hello@world#123" "hello_world_123" "string"

# Test 3: String with multiple consecutive special characters
run_test "Multiple consecutive special chars" "hello---world" "hello_world" "string"

# Test 4: String with underscores (should be preserved)
run_test "String with underscores" "hello_world_test" "hello_world_test" "string"

# Test 5: String with mixed case
run_test "Mixed case string" "HelloWorld123" "HelloWorld123" "string"

# Test 6: Empty string
run_test "Empty string" "" "" "string" "--test"

# Test 7: String with only special characters
run_test "Only special characters" "!@#$%^&*()" "" "string"

# Test 8: String with numbers
run_test "String with numbers" "file123name" "file123name" "string"

# Test 9: Basic filename with extension
run_test "Basic filename with extension" "my file.txt" "my_file.txt" "string"

# Test 10: Filename with special characters
run_test "Filename with special chars" "my@file#123.pdf" "my_file_123.pdf" "string"

# Test 11: Filename with multiple dots
run_test "Filename with multiple dots" "my.file.name.txt" "my_file_name.txt" "string"

# Test 12: Filename with consecutive special characters
run_test "Filename with consecutive special chars" "my---file---name.txt" "my_file_name.txt" "string"

# Test 13: Filename with underscores
run_test "Filename with underscores" "my_file_name.txt" "my_file_name.txt" "string"

# Test 14: Filename with mixed case
run_test "Filename with mixed case" "MyFile123.TXT" "MyFile123.TXT" "string"

# Test 15: Filename with only extension
run_test "Filename with only extension" ".txt" "skipped hidden file: .txt" "string"

# Test 16: Filename starting with special characters
run_test "Filename starting with special chars" "!@#file.txt" "_file.txt" "string"

# Test 17: Filename ending with special characters
run_test "Filename ending with special chars" "file.txt!@#" "file.txt!@#" "string"

# Test 18: Stdin input processing
run_test "Stdin input" "hello world from stdin" "hello_world_from_stdin" "stdin"

# Test 19: Stdin with special characters
run_test "Stdin with special chars" "hello@world#from\$stdin" "hello_world_from_stdin" "stdin"

# Test 20: File renaming (when file exists)
test_file_rename "File renaming when file exists" "test file.txt" "test_file.txt" "yes"

# Test 21: File renaming (when file doesn't exist)
run_test_full "File renaming when file doesn't exist" "nonexistent file.txt" "would rename nonexistent file.txt to nonexistent_file.txt" "string"

# Test 22: No renaming when filename is already clean
test_file_rename "No renaming when filename is clean" "cleanfile.txt" "cleanfile.txt" "no"

# Test 23: Complex filename with multiple special characters
run_test "Complex filename" "My Company - Report (2024) v2.1.pdf" "My_Company_Report_2024_v2_1.pdf" "string"

# Test 24: Filename with unicode characters (should be preserved)
run_test "Filename with unicode chars" "café résumé.pdf" "café_résumé.pdf" "string"

# Test 25: Very long filename
run_test "Very long filename" "this_is_a_very_long_filename_with_many_characters_and_numbers_123456789.txt" "this_is_a_very_long_filename_with_many_characters_and_numbers_123456789.txt" "string"

# Test 26: Filename with only numbers
run_test "Filename with only numbers" "123456.txt" "123456.txt" "string"

# Test 27: Filename with only letters
run_test "Filename with only letters" "abcdef.txt" "abcdef.txt" "string"

# Test 28: Filename with spaces at beginning and end
run_test_full "Filename with leading/trailing spaces" "  spaced file.txt  " "would rename spaced file.txt to spaced_file.txt" "string"

# Test 29: Multiple consecutive underscores in input
run_test "Multiple consecutive underscores" "file___name.txt" "file_name.txt" "string"

# Test 30: Filename with backslashes (Windows path style)
run_test "Filename with backslashes" "folder\file.txt" "folder_file.txt" "string"

# Test: No trailing underscore before extension
run_test "No trailing underscore before extension" "foo_.txt" "foo.txt" "string"
run_test "No trailing underscore before extension (multiple)" "foo___.txt" "foo.txt" "string"
run_test "No trailing underscore before extension (complex)" "foo__bar__baz__.txt" "foo_bar_baz.txt" "string"

# Test: Hidden file with punctuation-only basename
run_test "Hidden file with punctuation-only basename" ".()$.txt" "skipped hidden file: .()$.txt" "string"

# Test: Non-hidden file with punctuation-only basename  
run_test "Non-hidden file with punctuation-only basename" "()$.txt" ".txt" "string"

# Test: Hidden files are ignored by default (argument mode)
run_test_full "Hidden file ignored by default (argument)" ".hidden file.txt" "skipped hidden file: .hidden file.txt" "string"

# Test: Hidden files are ignored by default (stdin mode)
run_test_full "Hidden file ignored by default (stdin)" ".hidden file.txt" "skipped hidden file: .hidden file.txt" "stdin"

# Test: --hidden parameter allows renaming hidden files
run_test_full "Hidden file with --hidden parameter" ".hidden file.txt" "would rename .hidden file.txt to .hidden_file.txt" "string" "--hidden"

# Test: --hidden parameter with stdin
run_test_full "Hidden file with --hidden parameter (stdin)" ".hidden file.txt" ".hidden_file.txt" "stdin" "--hidden"

# Test: Mixed files - hidden ignored by default
run_test_full "Mixed files - hidden ignored by default" ".hidden.txt
normal.txt" "skipped hidden file: .hidden.txt
normal.txt" "stdin"

# Test: Mixed files - all processed with --hidden
run_test_full "Mixed files - all processed with --hidden" ".hidden.txt
normal.txt" ".hidden_txt
normal.txt" "stdin" "--hidden"

echo ""
echo "=================================="
echo "Test Results:"
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi 