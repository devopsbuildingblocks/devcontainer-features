#!/bin/bash

set -e

source dev-container-features-test-lib

if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

check "terragrunt command is available" terragrunt --version
check "terragrunt-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/terragrunt-feature.sh"
check "shell integration contains complete -C" grep -q "complete -o nospace -C" "$HOME/.shellrc.d/terragrunt-feature.sh"

reportResults
