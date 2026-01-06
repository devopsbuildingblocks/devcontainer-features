#!/usr/bin/env bash
#
# bat Feature Installation Script
# Installs bat via devbox global and sets up shell integration
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
ALIASASCAT="${ALIASASCAT:-true}"
THEME="${THEME:-Monokai Extended}"

#######################################
# Install bat via devbox global
#######################################
install_bat() {
    log_info "Installing bat (version: $VERSION)"

    local package_spec="bat"
    if [ "$VERSION" != "latest" ]; then
        package_spec="bat@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists bat; then
        log_error "bat installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(bat --version | head -n1)
    log_success "bat installed: $installed_version"
}

#######################################
# Generate shell integration content
#######################################
generate_shell_integration() {
    cat <<'EOF'
# bat shell integration
# This file is sourced by ~/.shellrc.d/main.sh
# bat is installed via devbox global, which is loaded by devbox-feature.sh

EOF

    # Set BAT_THEME if specified and not auto
    if [ "$THEME" != "auto" ]; then
        cat <<EOF
# bat theme
export BAT_THEME="$THEME"

EOF
    fi

    # Add cat alias if enabled
    if [ "$ALIASASCAT" = "true" ]; then
        cat <<'EOF'
# Alias cat to bat with plain style and no paging
# This provides syntax highlighting while maintaining cat-like behavior
alias cat='bat --style=plain --paging=never'

EOF
    fi

    # Add useful bat aliases and theme tracking
    cat <<'EOF'
# Useful bat aliases
alias bathelp='bat --plain --language=help'

# Use bat for man pages with color
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# bat with line numbers (like cat -n)
alias batn='bat --style=numbers'

# bat with full decorations
alias batf='bat --style=full'

EOF

    # Add current theme tracking
    cat <<EOF
# Track current bat theme
export CURRENT_BAT_THEME="${THEME}"
EOF

    # Add theme helper functions
    cat <<'EOF'

#######################################
# List available bat themes
# Shows bat's built-in themes
#######################################
bat-themes() {
    echo "Available bat themes (built-in):"
    echo ""
    bat --list-themes | sed 's/^/  /'
    echo ""
    echo "Current theme: ${CURRENT_BAT_THEME:-auto}"
    echo ""
    echo "Usage: bat-theme <theme-name>"
    echo "       bat-theme auto  (use terminal default)"
}

#######################################
# Switch bat theme
# Updates BAT_THEME environment variable
#######################################
bat-theme() {
    if [ -z "$1" ]; then
        echo "Error: No theme specified"
        echo ""
        bat-themes
        return 1
    fi

    local theme="$1"

    # Handle "auto" theme
    if [ "$theme" = "auto" ]; then
        unset BAT_THEME
        export CURRENT_BAT_THEME="auto"
        echo "bat theme set to auto (terminal default)"
        return 0
    fi

    # Validate theme exists by checking bat --list-themes
    if ! bat --list-themes 2>/dev/null | grep -qx "$theme"; then
        echo "Error: Theme '$theme' not found"
        echo ""
        echo "Available themes:"
        bat --list-themes | head -20 | sed 's/^/  /'
        echo "  ... (use bat-themes to see all)"
        return 1
    fi

    export BAT_THEME="$theme"
    export CURRENT_BAT_THEME="$theme"
    echo "Switched bat theme to: $theme"
}
EOF
}

#######################################
# Set up shell integration for bat
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(generate_shell_integration)

    write_shellrc_feature "bat" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting bat installation"

    install_bat
    setup_shell_integration

    log_success "bat feature installation complete"
}

# Execute main function
main "$@"
