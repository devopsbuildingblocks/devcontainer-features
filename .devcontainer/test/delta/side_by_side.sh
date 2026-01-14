#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test that delta was installed
check "delta command is available" delta --version

# Test that shell integration file exists
check "delta-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/delta-feature.sh"

# Test that postCreateCommand script has side-by-side config
check "side-by-side mode is configured" grep -q "side-by-side" /usr/local/bin/delta-postCreateCommand.sh

# Report results
reportResults
