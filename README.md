# Underscorify

A command-line utility that replaces non-alphanumeric characters with underscores while preserving file extensions. Perfect for cleaning up filenames and making them filesystem-friendly.

**Now with full UTF-8 (Unicode) support!**
- Unicode letters and numbers are preserved in cleaned filenames (e.g., `café résumé.pdf` → `café_résumé.pdf`).

## Features

- **Smart filename processing**: Preserves file extensions while cleaning base names
- **MANY underscore handling**: Collapses consecutive underscores into single ones
- **Space trimming**: Automatically removes leading and trailing spaces
- **Colored output**: Visual feedback with cyan for original and green for cleaned names
- **File renaming**: Actually renames files when they exist
- **Stdin support**: Process input from pipes and redirects
- **UTF-8/Unicode support**: Unicode letters and numbers are preserved
- **Comprehensive testing**: Full test suite with 30+ test cases
- **Conflict detection**: Prevents naming conflicts when processing multiple files
- **Hidden file protection**: Safely handles hidden files with configurable behavior
- **Test mode**: Special mode for testing the underscorify function without file operations

## Installation

### Prerequisites
- **Bash 4.x or higher** (required for associative arrays used in conflict detection)
- `sed`, `tr`, and `perl` utilities (usually pre-installed)

**Important**: The script uses `#!/usr/local/bin/bash` in its shebang line, which means it expects Bash 4.x+ to be installed in `/usr/local/bin/bash`. This is typically the case when using Homebrew on macOS, but may not be true on all systems.

### Setup

1. **Clone or download** the underscorify project to your desired location
2. **Make the script executable**:
   ```bash
   chmod +x underscorify.sh
   ```
3. **Add to your PATH** (optional):
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/underscorify-project"
   
   # Or create a symlink in ~/bin
   ln -s /path/to/underscorify-project/underscorify.sh ~/bin/underscorify
   ```

### Bash Version Requirements

The script requires Bash 4.x or higher for associative array support. If you encounter this error:

```
Error: This script requires Bash 4.x or higher (current version: 3.2.57(1)-release)
Associative arrays are required for conflict detection.
```

**Solutions:**

1. **Install/Update Bash via Homebrew** (macOS):
   ```bash
   brew install bash
   # or if already installed:
   brew upgrade bash
   ```

2. **Update the shebang line** if your Bash 4.x+ is installed elsewhere:
   ```bash
   # Find your bash location
   which bash
   
   # Edit the script to use your bash location
   sed -i 's|#!/usr/local/bin/bash|#!/path/to/your/bash|' underscorify.sh
   ```

3. **Use a different shebang** for better portability:
   ```bash
   # Replace the first line with:
   #!/usr/bin/env bash
   ```

4. **Run with explicit bash** (temporary solution):
   ```bash
   bash underscorify.sh "filename.txt"
   ```

**Note**: The script is configured to use `/usr/local/bin/bash` by default, which is the standard location for Homebrew-installed bash on macOS. If you're on a different system or have bash installed elsewhere, you may need to adjust the shebang line.

## Usage

**Note**: Examples assume you have installed the script in your PATH.

### Basic Usage 

```bash
# Process a single filename
underscorify "my file name.txt"

# Process a string (no file extension)
underscorify "hello world"

# Process from stdin
echo "file with spaces.pdf" | underscorify
```

### File Operations

```bash
# Rename an existing file
underscorify "My Document (2024).pdf"
# Output: renamed My Document (2024).pdf to My_Document_2024.pdf

# Show what would be renamed (file doesn't exist)
underscorify "nonexistent file.txt"
# Output: would rename nonexistent file.txt to nonexistent_file.txt
```

### Advanced Usage

```bash
# Process MANY files
for file in *.pdf; do
    underscorify "$file"
done

# Process from a list
cat filelist.txt | underscorify

# Use in scripts
cleaned_name=$(underscorify "original name.txt")
echo "Cleaned: $cleaned_name"
```

### Command Line Options

```bash
# Basic usage - process a single file or string
underscorify "filename with spaces.txt"
underscorify "string with special@chars#123"

# Process multiple files from stdin
ls *.txt | underscorify

# Allow renaming of hidden files (use with caution)
underscorify --hidden ".hidden file.txt"
ls -a | underscorify --hidden

# Process directory contents safely (hidden files ignored by default)
ls -a | underscorify  # Hidden files will be skipped

# Test mode - only process the string without file operations
underscorify --test "test string with spaces"
```

## Examples

### Input → Output

| Input | Output | Notes |
|-------|--------|-------|
| `"hello world"` | `"hello_world"` | No file extension |
| `"my file.txt"` | `"my_file.txt"` | Retains file extension |
| `file@name#123.pdf` | `file_name_123.pdf` | Removes symbols, punctuation, spaces, and control characters |
| `hello---world` | `hello_world` | Dashes replaced with underscores |
| `"  spaced file.txt  "` | `"spaced_file.txt"` | Leading and trailing spaces removed |
| `"café résumé.pdf"` | `"café_résumé.pdf"` | Unicode letters and numbers preserved |
| `"HAS___MANY_____UNDERSCORES.pdf"` | `"HAS_MANY_UNDERSCORES.pdf"` | Many consecutive underscores collapsed |
| `".hidden file.txt"` | `"skipped hidden file: .hidden file.txt"` | Hidden files skipped by default |
| `".hidden file.txt"` | `".hidden_file.txt"` | Hidden files processed with `--hidden` flag |

### Real-world Example

```bash
# Before
ls
HAS___MANY_____UNDERSCORES.pdf

# Run underscorify
underscorify HAS___MANY_____UNDERSCORES.pdf

# After
ls
HAS_MANY_UNDERSCORES.pdf
```

### Conflict Detection Example

```bash
# Create files that would conflict
touch "file@name.txt"
touch "file#name.txt"

# Process both - conflict detected
echo -e "file@name.txt\nfile#name.txt" | underscorify
# Output: 
# file_name.txt
# CONFLICT: 'file#name.txt' and 'file@name.txt' would both become 'file_name.txt'
```

## Rules

The script follows these processing rules:

1. **Accept file name or file path as argument**
2. **Replace all non-alphanumeric characters** in the base name with underscores
3. **Replace multiple consecutive underscores** with single underscores
4. **Rename file** using the cleaned base name (when file exists)
5. **Preserve file extensions** (everything after the last dot)
6. **Trim leading/trailing spaces** from input
7. **Skip hidden files by default** (files starting with `.`) - use `--hidden` to allow renaming
8. **Detect naming conflicts** when processing multiple files from stdin
9. **Require Bash 4.x or higher** for associative array support

## Command Line Options

- `--hidden`: Allow renaming of hidden files (files starting with `.`)
  - **Warning**: Use with caution as hidden files often contain important system configuration
  - By default, hidden files are skipped to prevent accidental damage
- `--test`: Test mode - only process the string without performing file operations
  - Useful for testing the underscorify function in isolation
  - Outputs only the cleaned string, no file operations or colored output

## Conflict Detection

When processing multiple files from stdin, the script detects potential naming conflicts:

- **Conflict detection**: If multiple input files would result in the same cleaned filename, a conflict warning is displayed
- **Associative arrays**: Uses Bash 4.x associative arrays to track processed names efficiently
- **Conflict resolution**: The first file with a given cleaned name is processed, subsequent conflicts are reported

Example:
```bash
echo -e "file@name.txt\nfile#name.txt\nfile\$name.txt" | underscorify
# Output:
# file_name.txt
# CONFLICT: 'file#name.txt' and 'file@name.txt' would both become 'file_name.txt'
# CONFLICT: 'file$name.txt' and 'file@name.txt' would both become 'file_name.txt'
```

## How the Script Determines What to Keep vs. Replace

The script uses Unicode property classes to intelligently distinguish between characters to preserve and characters to replace:

### **Unicode Property Classes Used:**
- `\p{L}` = **Unicode Letter** (includes all letters from all scripts: Latin, Cyrillic, Arabic, Chinese, etc.)
- `\p{N}` = **Unicode Number** (includes all numeric characters from all scripts)

### **What Gets Kept:**
- **Letters**: `a-z`, `A-Z`, `é`, `ñ`, `α`, `β`, `中`, `日`, `ア`, `א`, etc.
- **Numbers**: `0-9`, `١`, `٢`, `٣`, `一`, `二`, `三`, etc.

### **What Gets Replaced with Underscores:**
- **Symbols**: `@`, `#`, `$`, `%`, `^`, `&`, `*`, `(`, `)`, `-`, `+`, `=`, etc.
- **Punctuation**: `.`, `,`, `!`, `?`, `;`, `:`, etc.
- **Whitespace**: spaces, tabs, newlines
- **Control characters**: non-printable characters

### **Examples:**
```bash
"café@resume#2024.pdf" → "café_resume_2024.pdf"
# é (letter) kept, @ and # (symbols) replaced

"file@name.txt" → "file_name.txt"  
# @ (symbol) replaced

"résumé.pdf" → "résumé.pdf"
# é (letter) kept, no changes needed

"document_2024.pdf" → "document_2024.pdf"
# All characters are letters/numbers, no changes needed
```

## Testing

### Run the Test Suite

```bash
# From the project directory
bash run_tests.sh

# Or run tests directly
bash test_underscorify.sh
```

### Test Coverage

The test suite includes 30+ test cases covering:

- **String processing** (no file extension)
- **File processing** (with extensions)
- **Stdin processing** (pipes and redirects)
- **Hidden file handling** (with and without `--hidden` flag)
- **Conflict detection** (multiple files with same cleaned name)
- **Unicode support** (international characters)
- **Edge cases** (empty strings, special characters only)
- **Test mode** (`--test` flag functionality)

### Debug Mode

The script includes debug logging for troubleshooting:

```bash
# Debug output is written to debug.log when processing stdin
echo "test input" | underscorify 2> debug.log
```

## Requirements

- **Bash 4.x or higher**: Required for associative arrays used in conflict detection
- **Perl**: Used for Unicode-aware string processing
- **Standard Unix utilities**: `sed`, `tr`, `mv`

## Troubleshooting

### Common Issues

1. **"Error: This script requires Bash 4.x or higher"**
   - **Most Common Cause**: The script is trying to use the old system bash instead of a newer version
   - **Solution**: Install/update bash via Homebrew: `brew install bash` or `brew upgrade bash`
   - **Alternative**: Update the shebang line to point to your bash 4.x+ location
   - **Check your bash version**: `bash --version`
   - **See "Bash Version Requirements" section above for detailed solutions**

2. **Hidden files not being processed**
   - Solution: Use the `--hidden` flag to allow processing of hidden files
   - Example: `underscorify --hidden ".hidden file.txt"`

3. **Naming conflicts when processing multiple files**
   - The script will detect and report conflicts
   - Manually resolve conflicts by renaming files before processing

4. **Unicode characters not preserved**
   - Ensure your terminal supports UTF-8
   - The script uses Perl with Unicode support for proper character handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run the test suite
5. Submit a pull request

## License

This utility is provided as-is for personal and commercial use.

## Version History

- **v1.0**: Initial release with core functionality
- **v1.1**: Added color output and space trimming
- **v1.2**: Improved test suite and documentation
- **v1.2.1**: Clarified hidden file handling with --hidden flag, updated tests and documentation
- **v1.2.2**: Updated license information to MIT

## Release Notes

### v1.2.2 (2024-06-20)
- **License updated**: Project now uses MIT License
- **Hidden file handling clarified:** When using the `--hidden` flag, hidden files (e.g., `.hidden.txt`) will preserve the leading dot and not convert it to an underscore. This is now the expected and tested behavior.
- **Test suite and documentation updated:** The test suite and all documentation now reflect this correct behavior for hidden files.

---

**Author**: David McDonald  
**License**: MIT License  
**Last Updated**: June 2025 