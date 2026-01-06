#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test 1: fzf command is available
check "fzf command is available" fzf --version

# Test 2: Shell integration file exists
check "fzf-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/fzf-feature.sh"

# Test 3: FZF_DEFAULT_OPTS is configured
check "FZF_DEFAULT_OPTS is configured" grep -q "FZF_DEFAULT_OPTS" "$HOME/.shellrc.d/fzf-feature.sh"

# Test 4: db2-dark theme colors are configured (default theme)
check "db2-dark theme colors are configured" grep -q "#E8C468" "$HOME/.shellrc.d/fzf-feature.sh"

# Test 5: fzf can process input
check "fzf can process input" bash -c 'echo -e "option1\noption2\noption3" | fzf --filter="option1" >/dev/null 2>&1'

# Report results
reportResults
