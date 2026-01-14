#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: oh-my-posh command is available
check "oh-my-posh command is available" oh-my-posh version

# Test 2: Shell integration file exists
check "oh-my-posh-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/oh-my-posh-feature.sh"

# Test 3: Shell config contains omp-theme function
check "omp-theme function is defined" grep -q "omp-theme" "$HOME/.shellrc.d/oh-my-posh-feature.sh"

# Test 4: Shell config contains omp-themes function
check "omp-themes function is defined" grep -q "omp-themes" "$HOME/.shellrc.d/oh-my-posh-feature.sh"

# Test 5: oh-my-posh can generate bash init script
check "oh-my-posh bash init works" oh-my-posh init bash

# Report results
reportResults
