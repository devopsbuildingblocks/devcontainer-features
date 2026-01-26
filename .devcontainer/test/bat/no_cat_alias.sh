#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test definitions
check "bat command is available" bat --version
check "bat-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/bat-feature.sh"
check "cat alias is NOT configured" bash -c "! grep -q 'alias cat=' $HOME/.shellrc.d/bat-feature.sh"

# Report results
reportResults
