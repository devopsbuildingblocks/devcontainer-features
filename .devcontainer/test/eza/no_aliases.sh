#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test that eza was installed
check "eza command is available" eza --version

# Test that shell integration file exists
check "eza-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/eza-feature.sh"

# Test that ls alias is NOT configured
check "ls alias is NOT configured" bash -c "! grep -q 'alias ls=' $HOME/.shellrc.d/eza-feature.sh"
check "ll alias is NOT configured" bash -c "! grep -q 'alias ll=' $HOME/.shellrc.d/eza-feature.sh"
check "la alias is NOT configured" bash -c "! grep -q 'alias la=' $HOME/.shellrc.d/eza-feature.sh"

# Report results
reportResults
