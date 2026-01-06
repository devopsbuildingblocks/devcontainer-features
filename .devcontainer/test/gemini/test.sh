#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test 1: gemini command is available
check "gemini command is available" bash -c "command -v gemini"

# Test 2: gemini command responds
check "gemini command responds" bash -c "gemini --version 2>/dev/null || gemini --help &>/dev/null"

# Test 3: postCreateCommand script exists
check "gemini-postCreateCommand.sh exists and is executable" test -x "/usr/local/bin/gemini-postCreateCommand.sh"

# Test 4: postCreateCommand script handles .gemini directory
check ".gemini directory is handled" grep -q ".gemini" /usr/local/bin/gemini-postCreateCommand.sh

# Report results
reportResults
