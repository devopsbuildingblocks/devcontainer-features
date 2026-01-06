#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test that delta was installed
check "delta command is available" delta --version

# Test that shell integration file exists
check "delta-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/delta-feature.sh"

# Test that postCreateCommand script exists for git config
check "delta-postCreateCommand.sh exists and is executable" test -x "/usr/local/bin/delta-postCreateCommand.sh"

# Test postCreateCommand script content for theme
check "Dracula theme is configured" grep -q "Dracula" /usr/local/bin/delta-postCreateCommand.sh

# Report results
reportResults
