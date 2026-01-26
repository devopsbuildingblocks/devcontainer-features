#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# # Source devbox shell integration to get devbox global packages in PATH
# if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
#     source "$HOME/.shellrc.d/devbox-feature.sh"
# fi

# Test 1: bat command is available
check "bat command is available" bat --version

# # Test 2: Shell integration file exists
# check "bat-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/bat-feature.sh"

# # Test 3: Default cat alias is configured
# check "cat alias is configured" grep -q "alias cat=" "$HOME/.shellrc.d/bat-feature.sh"

# # Test 4: bat can display content
# check "bat can display a file" bash -c 'echo "Hello, World!" | bat --style=plain --paging=never'

# # Test 5: bat-themes function is defined
# check "bat-themes function is defined" grep -q "bat-themes()" "$HOME/.shellrc.d/bat-feature.sh"

# # Test 6: bat-theme function is defined
# check "bat-theme function is defined" grep -q "bat-theme()" "$HOME/.shellrc.d/bat-feature.sh"

# # Test 7: BAT_THEME is configured
# check "BAT_THEME is configured" grep -q 'BAT_THEME=' "$HOME/.shellrc.d/bat-feature.sh"

# # Test 8: CURRENT_BAT_THEME is configured
# check "CURRENT_BAT_THEME is configured" grep -q 'CURRENT_BAT_THEME=' "$HOME/.shellrc.d/bat-feature.sh"

# # Test 9: MANPAGER is configured for bat
# check "MANPAGER is configured" grep -q 'MANPAGER=' "$HOME/.shellrc.d/bat-feature.sh"

# # Test 10: Additional bat aliases are present
# check "bathelp alias is defined" grep -q "alias bathelp=" "$HOME/.shellrc.d/bat-feature.sh"
# check "batn alias is defined" grep -q "alias batn=" "$HOME/.shellrc.d/bat-feature.sh"
# check "batf alias is defined" grep -q "alias batf=" "$HOME/.shellrc.d/bat-feature.sh"

# # Test 11: bat can list themes
# check "bat list-themes works" bat --list-themes

# Report results
reportResults
