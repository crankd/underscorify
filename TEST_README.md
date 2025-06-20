# Underscorify Test Suite

This directory contains comprehensive test cases for the `underscorify` script.

## Overview

The `underscorify` script replaces non-alphanumeric characters with underscores while preserving file extensions. It can process:
- Strings (no file extension)
- Filenames (with extensions)
- Stdin input
- File renaming (when files exist)

## Test Files

- `test_underscorify.sh` - Main test suite with 30 comprehensive test cases
- `run_tests.sh` - Simple test runner script

## Running Tests

From the bin directory:

```bash
# Make scripts executable
chmod +x underscorify
chmod +x run_tests.sh
chmod +x test_underscorify.sh

# Run the test suite
bash run_tests.sh
```

Or run the test suite directly:

```bash
bash test_underscorify.sh
```

## Test Categories

### 1. String Processing (No Extension)
- Basic strings with spaces
- Strings with special characters
- Multiple consecutive special characters
- Strings with underscores
- Mixed case strings
- Empty strings
- Strings with only special characters
- Strings with numbers

### 2. Filename Processing (With Extension)
- Basic filenames with extensions
- Filenames with special characters
- Filenames with multiple dots
- Filenames with consecutive special characters
- Filenames with underscores
- Mixed case filenames
- Filenames with only extension
- Filenames starting/ending with special characters
- Complex filenames with multiple special characters
- Unicode characters
- Very long filenames
- Filenames with only numbers/letters
- Leading/trailing spaces
- Multiple consecutive underscores
- Windows-style backslashes

### 3. File Operations
- File renaming when file exists
- File renaming when file doesn't exist
- No renaming when filename is already clean

### 4. Stdin Processing
- Basic stdin input
- Stdin with special characters

## Test Results

The test suite provides colored output:
- 🟢 **GREEN**: Test passed
- 🔴 **RED**: Test failed (with expected vs actual output)

At the end, it displays a summary:
- Total tests run
- Tests passed
- Tests failed
- Overall result

## Expected Behavior

The `underscorify` script should:

1. **Replace non-alphanumeric characters** with underscores
2. **Preserve file extensions** (everything after the last dot)
3. **Collapse multiple consecutive underscores** into single underscores
4. **Preserve alphanumeric characters** (a-z, A-Z, 0-9)
5. **Handle file renaming** when the input is a filename that exists
6. **Process stdin** when no arguments are provided
7. **Show appropriate messages** for file operations
8. **Preserve the leading dot for hidden files** when using the `--hidden` flag (e.g., `.hidden.txt` remains `.hidden.txt`, not `_hidden.txt`)

## Example Transformations

| Input | Output |
|-------|--------|
| `"hello world"` | `"hello_world"` |
| `"my file.txt"` | `"my_file.txt"` |
| `"file@name#123.pdf"` | `"file_name_123.pdf"` |
| `"hello---world"` | `"hello_world"` |
| `"café résumé.pdf"` | `"café_résumé.pdf"` |
| `.hidden.txt` (with `--hidden`) | `.hidden.txt` |

## Troubleshooting

If tests fail:

1. Ensure the `underscorify` script is executable: `chmod +x underscorify`
2. Check that the script path in tests is correct (`./underscorify`)
3. Verify the script has proper shebang (`#!/usr/local/bin/bash`)
   - **Note**: The script uses `/usr/local/bin/bash` (Homebrew bash) instead of `/bin/bash` (system bash) because it requires Bash 4.x+ for associative arrays used in conflict detection
   - **See README.md "Bash Version Requirements" section** for detailed information about bash version requirements and troubleshooting
4. Run tests from the correct directory (`~/bin`)
5. If you are testing hidden files with the `--hidden` flag, remember that the script will preserve the leading dot (e.g., `.hidden.txt` stays `.hidden.txt`). The test suite expects this behavior. 