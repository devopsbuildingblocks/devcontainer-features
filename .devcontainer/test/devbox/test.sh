#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test 1: devbox command is available
check "devbox command is available" devbox version

# Test 2: devbox binary exists in /usr/local/bin
check "devbox binary exists at /usr/local/bin/devbox" test -x "/usr/local/bin/devbox"

# Test 3: postCreateCommand script exists
check "devbox-postCreateCommand.sh exists and is executable" test -x "/usr/local/bin/devbox-postCreateCommand.sh"

# Test 4: devbox-feature.sh exists in shellrc.d
check "devbox-feature.sh exists" test -f "$HOME/.shellrc.d/devbox-feature.sh"

# Test 5: XDG_DATA_HOME directory exists
check ".local/share directory exists" test -d "$HOME/.local/share"

# Test 6: devbox global list command works
check "devbox global list command works" devbox global list

# Report results
reportResults
