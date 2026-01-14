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

# Test that custom FZF_DEFAULT_OPTS are set
check "Custom preview option is configured" grep -q "preview 'cat {}'" "$HOME/.shellrc.d/fzf-feature.sh"

# Test that height 50% is set (custom value, not default 40%)
check "Custom height option is configured" grep -q "height 50%" "$HOME/.shellrc.d/fzf-feature.sh"

# Report results
reportResults
