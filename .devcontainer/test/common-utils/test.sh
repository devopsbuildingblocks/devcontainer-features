#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test 1: shellrc.d directory exists
check "shellrc.d directory exists" test -d "$HOME/.shellrc.d"

# Test 2: main.sh loader exists
check "main.sh loader exists" test -f "$HOME/.shellrc.d/main.sh"

# Test 3: zsh is available
check "zsh is installed" command -v zsh

# Test 4: .bashrc sources shellrc.d/main.sh
check ".bashrc sources shellrc.d/main.sh" grep -q "shellrc.d/main.sh" "$HOME/.bashrc"

# Test 5: .zshrc sources shellrc.d/main.sh
check ".zshrc sources shellrc.d/main.sh" grep -q "shellrc.d/main.sh" "$HOME/.zshrc"

# Test 6: postCreateCommand script exists
check "common-utils-postCreateCommand.sh exists and is executable" test -x "/usr/local/bin/common-utils-postCreateCommand.sh"

# Report results
reportResults
