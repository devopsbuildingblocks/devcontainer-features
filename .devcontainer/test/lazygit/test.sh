#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: lazygit command is available
check "lazygit command is available" lazygit --version

# Test 2: Shell integration file exists
check "lazygit-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/lazygit-feature.sh"

# Test 3: Config directory exists
check "lazygit config directory exists" test -d "$HOME/.config/lazygit"

# Test 4: Config file exists
check "config.yml exists" test -f "$HOME/.config/lazygit/config.yml"

# Test 5: Shell config contains lzg alias
check "lzg alias is defined" grep -q "alias lzg=" "$HOME/.shellrc.d/lazygit-feature.sh"

# Test 6: Shell config contains lzg-theme function
check "lzg-theme function is defined" grep -q "lzg-theme" "$HOME/.shellrc.d/lazygit-feature.sh"

# Test 7: Shell config contains lzg-themes function
check "lzg-themes function is defined" grep -q "lzg-themes" "$HOME/.shellrc.d/lazygit-feature.sh"

# Test 8: Themes directory exists
check "themes directory exists" test -d "/usr/local/share/devcontainer-features/lazygit/themes"

# Report results
reportResults
