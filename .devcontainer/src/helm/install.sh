#!/usr/bin/env bash
#
# helm Feature Installation Script
# Installs Helm via devbox global and configures shell completion
#

set -e

# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

VERSION="${VERSION:-latest}"

#######################################
# Install helm via devbox global
#######################################
install_helm() {
    log_info "Installing helm (version: $VERSION)"

    local package_spec="kubernetes-helm"
    if [ "$VERSION" != "latest" ]; then
        package_spec="kubernetes-helm@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    if ! command_exists helm; then
        log_error "helm installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(helm version --short)
    log_success "helm installed: $installed_version"
}

#######################################
# Setup shell integration with completion
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# helm shell integration
if command -v helm &>/dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        source <(helm completion zsh)
    elif [ -n "$BASH_VERSION" ]; then
        source <(helm completion bash)
    fi
fi
EOF
)

    write_shellrc_feature "helm" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting helm installation"

    install_helm
    setup_shell_integration

    log_success "helm feature installation complete"
}

main "$@"
