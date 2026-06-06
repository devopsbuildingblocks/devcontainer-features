#!/usr/bin/env bash
#
# terragrunt Feature Installation Script
# Installs Terragrunt via devbox global and configures shell completion
#

set -e

# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

VERSION="${VERSION:-latest}"

#######################################
# Install terragrunt via devbox global
#######################################
install_terragrunt() {
    log_info "Installing terragrunt (version: $VERSION)"

    local package_spec="terragrunt"
    if [ "$VERSION" != "latest" ]; then
        package_spec="terragrunt@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    if ! command_exists terragrunt; then
        log_error "terragrunt installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(terragrunt --version)
    log_success "terragrunt installed: $installed_version"
}

#######################################
# Setup shell integration with completion
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# terragrunt shell integration
if command -v terragrunt &>/dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        autoload -U +X bashcompinit && bashcompinit
        complete -o nospace -C "$(command -v terragrunt)" terragrunt
    elif [ -n "$BASH_VERSION" ]; then
        complete -o nospace -C "$(command -v terragrunt)" terragrunt
    fi
fi
EOF
)

    write_shellrc_feature "terragrunt" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting terragrunt installation"

    install_terragrunt
    setup_shell_integration

    log_success "terragrunt feature installation complete"
}

main "$@"
