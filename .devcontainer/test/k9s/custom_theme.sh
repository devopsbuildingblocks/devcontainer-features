#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: k9s command is available
check "k9s command is available" k9s version --short

# Test 2: Config file exists
check "config.yaml exists" test -f "$HOME/.config/k9s/config.yaml"

# Test 3: Config has dracula theme set
check "config has dracula theme" grep -q "skin: dracula" "$HOME/.config/k9s/config.yaml"

# Test 4: Dracula theme file exists
check "dracula theme exists" test -f "/usr/local/share/devcontainer-features/k9s/themes/dracula.yaml"

# Test 5: Current theme environment variable is set to dracula
check "CURRENT_K9S_THEME is set" grep -q 'CURRENT_K9S_THEME="dracula"' "$HOME/.shellrc.d/k9s-feature.sh"

# Report results
reportResults
