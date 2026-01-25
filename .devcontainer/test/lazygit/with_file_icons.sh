#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test that lazygit was installed
check "lazygit command is available" lazygit --version

# Test that shell integration file exists
check "lazygit-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/lazygit-feature.sh"

# Test that config.yml contains showFileIcons enabled
check "config.yml contains showFileIcons: true" grep -q "showFileIcons: true" "$HOME/.config/lazygit/config.yml"

# Report results
reportResults
