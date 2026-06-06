#!/usr/bin/env bash
#
# kubectl Feature Installation Script
# Installs kubectl via devbox global and configures shell completion
#

set -e

# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

VERSION="${VERSION:-latest}"

#######################################
# Install kubectl via devbox global
#######################################
install_kubectl() {
    log_info "Installing kubectl (version: $VERSION)"

    local package_spec="kubectl"
    if [ "$VERSION" != "latest" ]; then
        package_spec="kubectl@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    if ! command_exists kubectl; then
        log_error "kubectl installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(kubectl version --client 2>&1 | head -n1)
    log_success "kubectl installed: $installed_version"
}

#######################################
# Setup shell integration with completion
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# kubectl shell integration
if command -v kubectl &>/dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        source <(kubectl completion zsh)
    elif [ -n "$BASH_VERSION" ]; then
        source <(kubectl completion bash)
    fi
fi
EOF
)

    write_shellrc_feature "kubectl" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting kubectl installation"

    install_kubectl
    setup_shell_integration

    log_success "kubectl feature installation complete"
}

main "$@"
