#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test 1: Library file exists
check "Library file exists" test -f "/usr/local/lib/devcontainer-features/common.sh"

# Test 2: Library is readable
check "Library is readable" test -r "/usr/local/lib/devcontainer-features/common.sh"

# Source the library to test its functions
source /usr/local/lib/devcontainer-features/common.sh

# Test 3-8: Check that expected functions are defined
check "log_info function is defined" command -v "log_info"
check "log_success function is defined" command -v "log_success"
check "log_warning function is defined" command -v "log_warning"
check "log_error function is defined" command -v "log_error"
check "get_remote_user function is defined" command -v "get_remote_user"
check "get_remote_user_home function is defined" command -v "get_remote_user_home"
check "command_exists function is defined" command -v "command_exists"
check "ensure_directory function is defined" command -v "ensure_directory"

# Test 9: Test command_exists function
check "command_exists correctly finds 'bash'" command_exists "bash"

# Test 10: Test command_exists correctly returns false
check "command_exists correctly returns false for nonexistent command" bash -c "! command_exists 'nonexistent_command_12345'"

# Report results
reportResults
