#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test definitions
check "bat command is available" bat --version
check "bat-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/bat-feature.sh"
check "BAT_THEME is set to Dracula" grep -q 'BAT_THEME="Dracula"' "$HOME/.shellrc.d/bat-feature.sh"
check "CURRENT_BAT_THEME is set to Dracula" grep -q 'CURRENT_BAT_THEME="Dracula"' "$HOME/.shellrc.d/bat-feature.sh"

# Report results
reportResults
