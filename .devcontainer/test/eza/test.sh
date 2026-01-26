#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: eza command is available
check "eza command is available" eza --version

# Test 2: Shell integration file exists
check "eza-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/eza-feature.sh"

# Test 3: Default ls alias is configured
check "ls alias is configured" grep -q "alias ls=" "$HOME/.shellrc.d/eza-feature.sh"

# Test 4: ll alias is configured
check "ll alias is configured" grep -q "alias ll=" "$HOME/.shellrc.d/eza-feature.sh"

# Test 5: eza can list files
check "eza can list files" eza /

# Test 6: eza-themes function is defined
check "eza-themes function is defined" grep -q "eza-themes()" "$HOME/.shellrc.d/eza-feature.sh"

# Test 7: eza-theme function is defined
check "eza-theme function is defined" grep -q "eza-theme()" "$HOME/.shellrc.d/eza-feature.sh"

# Test 8: EZA_CONFIG_DIR is configured
check "EZA_CONFIG_DIR is configured" grep -q 'EZA_CONFIG_DIR=' "$HOME/.shellrc.d/eza-feature.sh"

# Test 9: Theme files are installed
check "theme files are installed" test -f "/usr/local/share/devcontainer-features/eza/themes/db2-dark.yml"

# Test 10: Config directory exists with theme symlink
check "theme symlink exists" test -L "$HOME/.config/eza/theme.yml"

# Test 11: eza tree mode works
check "eza tree mode works" eza --tree -L 1 /

# Report results
reportResults
