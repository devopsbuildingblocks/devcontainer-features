#!/usr/bin/env bash
#
# Gemini Feature Installation Script
# Installs Gemini CLI via devbox global and sets up host config persistence
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"

#######################################
# Install gemini via devbox global
#######################################
install_gemini() {
    log_info "Installing gemini-cli (version: $VERSION)"

    local package_spec="gemini-cli"
    if [ "$VERSION" != "latest" ]; then
        package_spec="gemini-cli@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists gemini; then
        log_error "gemini installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(gemini --version 2>/dev/null || echo "unknown")
    log_success "gemini installed: $installed_version"
}

#######################################
# Setup volume mounts for persistence
#######################################
setup_volume_mounts() {
    create_volume_symlink_script "gemini" ".gemini"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting gemini installation"

    install_gemini
    setup_volume_mounts

    log_success "Gemini feature installation complete"
}

# Execute main function
main "$@"
