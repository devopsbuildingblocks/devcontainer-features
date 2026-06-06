#!/bin/bash

set -e

source dev-container-features-test-lib

if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

check "helm command is available" helm version
check "helm-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/helm-feature.sh"
check "shell integration contains completion" grep -q "helm completion" "$HOME/.shellrc.d/helm-feature.sh"

reportResults
