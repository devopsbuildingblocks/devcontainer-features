#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: rg command is available
check "rg command is available" rg --version

# Test 2: Shell integration file exists
check "ripgrep-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/ripgrep-feature.sh"

# Test 3: Config file exists
check "ripgrep config file exists" test -f "$HOME/.config/ripgrep/config"

# Test 4: RIPGREP_CONFIG_PATH is configured in shell integration
check "RIPGREP_CONFIG_PATH is configured" grep -q "RIPGREP_CONFIG_PATH" "$HOME/.shellrc.d/ripgrep-feature.sh"

# Test 5: db2 theme colors are in config (default theme)
check "db2 theme colors are configured" grep -q "path:fg:blue" "$HOME/.config/ripgrep/config"

# Test 6: Smart case is enabled by default
check "smart-case is enabled" grep -q "smart-case" "$HOME/.config/ripgrep/config"

# Test 7: rg can search for a pattern
check "rg can search for a pattern" rg --help

# Test 8: Theme files are installed
check "theme files are installed" test -f "/usr/local/share/devcontainer-features/ripgrep/themes/db2.theme"

# Test 9: rg-themes function is defined
check "rg-themes function is defined" grep -q "rg-themes()" "$HOME/.shellrc.d/ripgrep-feature.sh"

# Test 10: rg-theme function is defined
check "rg-theme function is defined" grep -q "rg-theme()" "$HOME/.shellrc.d/ripgrep-feature.sh"

# Report results
reportResults
