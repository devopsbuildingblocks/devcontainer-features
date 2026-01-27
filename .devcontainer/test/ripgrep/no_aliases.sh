#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: rg command is available
check "rg command is available" rg --version

# Test 2: No aliases in shell integration when disabled
check "no rgi alias when aliases disabled" bash -c "! grep -q 'alias rgi=' \"\$HOME/.shellrc.d/ripgrep-feature.sh\""

# Test 3: Theme functions are still present (they should be)
check "rg-themes function still exists" grep -q "rg-themes()" "$HOME/.shellrc.d/ripgrep-feature.sh"

# Report results
reportResults
