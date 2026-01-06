#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test 1: claude command is available
check "claude command is available" bash -c "command -v claude"

# Test 2: claude command responds
check "claude command responds" bash -c "claude --version 2>/dev/null || claude --help &>/dev/null"

# Test 3: postCreateCommand script exists
check "claude-postCreateCommand.sh exists and is executable" test -x "/usr/local/bin/claude-postCreateCommand.sh"

# Test 4: postCreateCommand script handles .claude directory
check ".claude directory is handled" grep -q ".claude" /usr/local/bin/claude-postCreateCommand.sh

# Test 5: postCreateCommand script handles .claude.json file
check ".claude.json file is handled" grep -q ".claude.json" /usr/local/bin/claude-postCreateCommand.sh

# Report results
reportResults
