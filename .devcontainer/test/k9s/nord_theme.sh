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

# Test 3: Config has nord theme set
check "config has nord theme" grep -q "skin: nord" "$HOME/.config/k9s/config.yaml"

# Test 4: Nord theme file exists
check "nord theme exists" test -f "/usr/local/share/devcontainer-features/k9s/themes/nord.yaml"

# Test 5: Current theme environment variable is set to nord
check "CURRENT_K9S_THEME is set" grep -q 'CURRENT_K9S_THEME="nord"' "$HOME/.shellrc.d/k9s-feature.sh"

# Report results
reportResults
