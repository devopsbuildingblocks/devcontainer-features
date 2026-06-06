#!/usr/bin/env bash
#
# awscli2 Feature Installation Script
# Installs AWS CLI v2 via devbox global and configures shell completion
#

set -e

# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

VERSION="${VERSION:-latest}"

#######################################
# Install awscli2 via devbox global
#######################################
install_awscli2() {
    log_info "Installing awscli2 (version: $VERSION)"

    local package_spec="awscli2"
    if [ "$VERSION" != "latest" ]; then
        package_spec="awscli2@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    if ! command_exists aws; then
        log_error "awscli2 installation failed - aws command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(aws --version)
    log_success "awscli2 installed: $installed_version"
}

#######################################
# Setup shell integration with completion
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# AWS CLI v2 shell integration
if command -v aws_completer &>/dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        autoload bashcompinit && bashcompinit
        complete -C aws_completer aws
    elif [ -n "$BASH_VERSION" ]; then
        complete -C aws_completer aws
    fi
fi
EOF
)

    write_shellrc_feature "awscli2" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting awscli2 installation"

    install_awscli2
    setup_shell_integration

    log_success "awscli2 feature installation complete"
}

main "$@"
