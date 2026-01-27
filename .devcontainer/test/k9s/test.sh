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

# Test 2: Shell integration file exists
check "k9s-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/k9s-feature.sh"

# Test 3: Config directory exists
check "k9s config directory exists" test -d "$HOME/.config/k9s"

# Test 4: Config file exists
check "config.yaml exists" test -f "$HOME/.config/k9s/config.yaml"

# Test 5: Skins directory exists
check "skins directory exists" test -d "$HOME/.config/k9s/skins"

# Test 6: Shell config contains k9 alias
check "k9 alias is defined" grep -q "alias k9=" "$HOME/.shellrc.d/k9s-feature.sh"

# Test 7: Shell config contains k9s-theme function
check "k9s-theme function is defined" grep -q "k9s-theme" "$HOME/.shellrc.d/k9s-feature.sh"

# Test 8: Shell config contains k9s-themes function
check "k9s-themes function is defined" grep -q "k9s-themes" "$HOME/.shellrc.d/k9s-feature.sh"

# Test 9: Themes directory exists in system location
check "themes directory exists" test -d "/usr/local/share/devcontainer-features/k9s/themes"

# Test 10: Default theme (db2-dark) exists
check "db2-dark theme exists" test -f "/usr/local/share/devcontainer-features/k9s/themes/db2-dark.yaml"

# Test 11: Config has skin setting
check "config has skin setting" grep -q "skin:" "$HOME/.config/k9s/config.yaml"

# Report results
reportResults
