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

# Test 3: fd can search for files
check "fd can search for files" fd --help

# Test 4: Aliases are defined (default is enabled)
check "fdi alias is defined" grep -q "alias fdi=" "$HOME/.shellrc.d/fd-feature.sh"

# Test 5: fdh alias is defined
check "fdh alias is defined" grep -q "alias fdh=" "$HOME/.shellrc.d/fd-feature.sh"

# Test 6: fda alias is defined
check "fda alias is defined" grep -q "alias fda=" "$HOME/.shellrc.d/fd-feature.sh"

# Test 7: fde alias is defined
check "fde alias is defined" grep -q "alias fde=" "$HOME/.shellrc.d/fd-feature.sh"

# Report results
reportResults
