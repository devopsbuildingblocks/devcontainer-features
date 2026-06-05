#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Source devbox shell integration to get devbox global packages in PATH
if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

# Test 1: direnv command is available
check "direnv command is available" direnv version

# Test 2: Shell integration file exists
check "direnv-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/direnv-feature.sh"

# Test 3: Shell integration contains hook
check "direnv hook zsh is in shellrc" grep -q "direnv hook zsh" "$HOME/.shellrc.d/direnv-feature.sh"

# Test 4: Config file exists
check "direnv config.toml exists" test -f "$HOME/.config/direnv/config.toml"

# Test 5: Config whitelists /workspaces
check "/workspaces is whitelisted in config" grep -q '"/workspaces"' "$HOME/.config/direnv/config.toml"

# Report results
reportResults
