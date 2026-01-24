#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: delta command is available
check "delta command is available" delta --version

# Test 2: Shell integration file exists
check "delta-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/delta-feature.sh"

# Test 3: delta can process diff input
check "delta can process diff input" bash -c 'echo -e "--- a/test\n+++ b/test\n@@ -1 +1 @@\n-old\n+new" | delta >/dev/null 2>&1'

# Report results
reportResults
