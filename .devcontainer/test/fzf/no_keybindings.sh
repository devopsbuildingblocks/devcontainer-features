#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test that fzf was installed
check "fzf command is available" fzf --version

# Test that shell integration file exists
check "fzf-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/fzf-feature.sh"

# Test that key bindings are NOT in the full integration call
# When keybindings are disabled, it should not use full integration mode
check "Full integration not used (key bindings disabled)" bash -c "! grep -q 'eval \"\$(fzf --zsh)\"' $HOME/.shellrc.d/fzf-feature.sh"

# Report results
reportResults
