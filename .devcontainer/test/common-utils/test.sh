#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test 1: shellrc.d directory exists
check "shellrc.d directory exists" test -d "$HOME/.shellrc.d"

# Test 2: main.sh loader exists
check "main.sh loader exists" test -f "$HOME/.shellrc.d/main.sh"

# Test 3: common-utils feature config exists
check "common-utils-feature.sh exists" test -f "$HOME/.shellrc.d/common-utils-feature.sh"

# Test 4: zsh is available
check "zsh is installed" command -v zsh

# Test 5: .bashrc sources shellrc.d/main.sh
check ".bashrc sources shellrc.d/main.sh" grep -q "shellrc.d/main.sh" "$HOME/.bashrc"

# Test 6: .zshrc sources shellrc.d/main.sh
check ".zshrc sources shellrc.d/main.sh" grep -q "shellrc.d/main.sh" "$HOME/.zshrc"

# Test 7: postCreateCommand script exists
check "common-utils-postCreateCommand.sh exists and is executable" test -x "/usr/local/bin/common-utils-postCreateCommand.sh"

# Report results
reportResults
