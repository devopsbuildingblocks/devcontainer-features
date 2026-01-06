#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test that eza was installed
check "eza command is available" eza --version

# Test that shell integration file exists
check "eza-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/eza-feature.sh"

# Test that aliases include --icons flag
check "ls alias includes --icons" grep -q "alias ls='eza --icons'" "$HOME/.shellrc.d/eza-feature.sh"
check "ll alias includes --icons" grep -q "alias ll='eza -l --icons'" "$HOME/.shellrc.d/eza-feature.sh"
check "la alias includes --icons" grep -q "alias la='eza -a --icons'" "$HOME/.shellrc.d/eza-feature.sh"

# Report results
reportResults
