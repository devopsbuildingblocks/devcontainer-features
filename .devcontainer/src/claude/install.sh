#!/usr/bin/env bash
#
# Claude Code Feature Installation Script
# Installs Claude Code CLI via devbox global and sets up host config persistence
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"

#######################################
# Install claude-code via devbox global
#######################################
install_claude() {
    log_info "Installing claude-code (version: $VERSION)"

    local package_spec="claude-code"
    if [ "$VERSION" != "latest" ]; then
        package_spec="claude-code@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists claude; then
        log_error "claude-code installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(claude --version 2>/dev/null || echo "unknown")
    log_success "claude-code installed: $installed_version"
}

#######################################
# Setup volume mounts for persistence
#######################################
setup_volume_mounts() {
    create_volume_symlink_script "claude" ".claude" ".claude.json"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting claude-code installation"

    install_claude
    setup_volume_mounts

    log_success "Claude Code feature installation complete"
}

# Execute main function
main "$@"
