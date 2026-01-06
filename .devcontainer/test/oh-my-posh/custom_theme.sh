#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test that oh-my-posh was installed
check "oh-my-posh command is available" oh-my-posh version

# Test that shell integration file exists
check "oh-my-posh-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/oh-my-posh-feature.sh"

# Test that agnoster theme is configured
check "agnoster theme is configured" grep -q "agnoster" "$HOME/.shellrc.d/oh-my-posh-feature.sh"

# Test CURRENT_OMP_THEME is set to agnoster
check "CURRENT_OMP_THEME is set to agnoster" grep -q 'CURRENT_OMP_THEME="agnoster"' "$HOME/.shellrc.d/oh-my-posh-feature.sh"

# Report results
reportResults
