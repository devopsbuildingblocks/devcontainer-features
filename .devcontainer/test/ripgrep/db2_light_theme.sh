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

# Test 2: db2-light theme colors are in config
check "db2-light theme colors are configured" grep -q "#2B5A7D" "$HOME/.config/ripgrep/config"

# Test 3: Theme is set to db2-light in shell integration
check "CURRENT_RG_THEME is db2-light" grep -q 'CURRENT_RG_THEME="db2-light"' "$HOME/.shellrc.d/ripgrep-feature.sh"

# Report results
reportResults
