#!/bin/bash

set -e

source dev-container-features-test-lib

if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

check "kubectl command is available" kubectl version --client
check "kubectl-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/kubectl-feature.sh"
check "shell integration contains completion" grep -q "kubectl completion" "$HOME/.shellrc.d/kubectl-feature.sh"

reportResults
