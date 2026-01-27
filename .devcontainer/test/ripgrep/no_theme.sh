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

# Test 2: No color settings in config when theme is none
check "no color settings in config" bash -c "! grep -q '^--colors=' \"\$HOME/.config/ripgrep/config\""

# Test 3: Theme is set to none in shell integration
check "CURRENT_RG_THEME is none" grep -q 'CURRENT_RG_THEME="none"' "$HOME/.shellrc.d/ripgrep-feature.sh"

# Report results
reportResults
