#!/usr/bin/env bash
#
# fd Feature Installation Script
# Installs fd (a simple, fast and user-friendly alternative to find) via devbox global
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
ENABLEALIASES="${ENABLEALIASES:-true}"

#######################################
# Install fd via devbox global
#######################################
install_fd() {
    log_info "Installing fd (version: $VERSION)"

    local package_spec="fd"
    if [ "$VERSION" != "latest" ]; then
        package_spec="fd@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists fd; then
        log_error "fd installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(fd --version)
    log_success "fd installed: $installed_version"
}

#######################################
# Generate shell integration content
#######################################
generate_shell_integration() {
    cat <<'EOF'
# fd shell integration
# This file is sourced by ~/.shellrc.d/main.sh
# fd is installed via devbox global, which is loaded by devbox-feature.sh

EOF

    # Add aliases if enabled
    if [ "$ENABLEALIASES" = "true" ]; then
        cat <<'EOF'
# Useful fd aliases
alias fdi='fd --ignore-case'            # Case-insensitive search
alias fdh='fd --hidden'                 # Include hidden files
alias fda='fd --hidden --no-ignore'     # Search all files (hidden + ignored)
alias fde='fd --extension'              # Search by file extension
alias fdt='fd --type'                   # Search by type (f=file, d=directory, l=symlink)
alias fdx='fd --exec'                   # Execute command for each result
EOF
    fi
}

#######################################
# Set up shell integration for fd
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(generate_shell_integration)

    write_shellrc_feature "fd" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting fd installation"

    install_fd
    setup_shell_integration

    log_success "fd feature installation complete"
}

# Execute main function
main "$@"
