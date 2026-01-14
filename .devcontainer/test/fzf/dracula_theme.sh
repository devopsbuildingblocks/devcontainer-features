#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test that fzf was installed
check "fzf command is available" fzf --version

# Test that shell integration file exists
check "fzf-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/fzf-feature.sh"

# Test that dracula theme colors are applied
check "Dracula theme colors are configured" grep -q "#bd93f9" "$HOME/.shellrc.d/fzf-feature.sh"

# Test that db2-dark colors are NOT present (different theme)
check "db2-dark theme colors not present" bash -c "! grep -q '#E8C468' $HOME/.shellrc.d/fzf-feature.sh"

# Report results
reportResults
