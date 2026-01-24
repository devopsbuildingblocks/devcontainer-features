#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test that eza was installed
check "eza command is available" eza --version

# Test that shell integration file exists
check "eza-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/eza-feature.sh"

# Test that CURRENT_EZA_THEME is set to db2-light
check "CURRENT_EZA_THEME is set to db2-light" grep -q 'CURRENT_EZA_THEME="db2-light"' "$HOME/.shellrc.d/eza-feature.sh"

# Test that theme symlink points to db2-light
check "theme symlink points to db2-light" test -L "$HOME/.config/eza/theme.yml"
check "theme file is db2-light.yml" bash -c 'readlink "$HOME/.config/eza/theme.yml" | grep -q "db2-light.yml"'

# Report results
reportResults
