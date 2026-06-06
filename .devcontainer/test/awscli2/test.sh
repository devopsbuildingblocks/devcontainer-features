#!/bin/bash

set -e

source dev-container-features-test-lib

if [ -f "$HOME/.shellrc.d/devbox-feature.sh" ]; then
    source "$HOME/.shellrc.d/devbox-feature.sh"
fi

check "aws command is available" aws --version
check "aws_completer is available" command -v aws_completer
check "awscli2-feature.sh exists in shellrc.d" test -f "$HOME/.shellrc.d/awscli2-feature.sh"
check "shell integration contains aws_completer" grep -q "aws_completer" "$HOME/.shellrc.d/awscli2-feature.sh"

reportResults
