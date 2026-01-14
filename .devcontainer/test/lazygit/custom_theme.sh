#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test that lazygit was installed
check "lazygit command is available" lazygit --version

# Test that shell integration file exists
check "lazygit-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/lazygit-feature.sh"

# Test that config.yml contains dracula theme
check "config.yml references dracula theme" grep -q "dracula" "$HOME/.config/lazygit/config.yml"

# Test CURRENT_LAZYGIT_THEME is set to dracula
check "CURRENT_LAZYGIT_THEME is set to dracula" grep -q 'CURRENT_LAZYGIT_THEME="dracula"' "$HOME/.shellrc.d/lazygit-feature.sh"

# Report results
reportResults
