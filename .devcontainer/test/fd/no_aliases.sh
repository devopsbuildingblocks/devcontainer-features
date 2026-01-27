#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: fd command is available
check "fd command is available" fd --version

# Test 2: Shell integration file exists
check "fd-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/fd-feature.sh"

# Test 3: Aliases are NOT defined when disabled
check "fdi alias is not defined" bash -c '! grep -q "alias fdi=" "$HOME/.shellrc.d/fd-feature.sh"'

# Report results
reportResults
