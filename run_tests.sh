#!/bin/bash

# Simple test runner for underscorify script
# Run from the bin directory: bash run_tests.sh

echo "Running underscorify test suite..."
echo "=================================="

# Make sure the underscorify script is executable
chmod +x underscorify.sh

# Run the test suite
bash test_underscorify.sh

echo ""
echo "Test run completed!" 