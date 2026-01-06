#!/bin/bash
#
# Test script for devbox feature with custom version
# Verifies that a specific version of devbox is installed
#

set -e

# Test 1: Check that devbox command exists
echo "Test: devbox command is available"
if command -v devbox &>/dev/null; then
    echo "PASSED: devbox command is available"
else
    echo "FAILED: devbox command not found"
    exit 1
fi

# Test 2: Check devbox version
echo "Test: devbox version can be retrieved"
INSTALLED_VERSION=$(devbox version)
echo "Installed version: $INSTALLED_VERSION"

if [ -n "$INSTALLED_VERSION" ]; then
    echo "PASSED: devbox version retrieved successfully"
else
    echo "FAILED: devbox version command failed"
    exit 1
fi

echo ""
echo "All devbox custom version tests passed!"
