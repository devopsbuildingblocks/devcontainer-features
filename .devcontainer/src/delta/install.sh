#!/usr/bin/env bash
#
# Delta Feature Installation Script
# Installs delta via devbox global and optionally configures git
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
CONFIGUREGIT="${CONFIGUREGIT:-true}"
THEME="${THEME:-auto}"
FEATURES="${FEATURES:-default}"

#######################################
# Install delta via devbox global
#######################################
install_delta() {
    log_info "Installing delta (version: $VERSION)"

    local package_spec="delta"
    if [ "$VERSION" != "latest" ]; then
        package_spec="delta@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists delta; then
        log_error "delta installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(delta --version | head -n1)
    log_success "delta installed: $installed_version"
}

#######################################
# Create postCreateCommand script for git configuration
# This runs after container creation when host gitconfig is mounted
#######################################
create_postCreateCommand() {
    log_info "Creating postCreateCommand script for git configuration"

    local script_path="/usr/local/bin/delta-postCreateCommand.sh"

    # Build the git config commands based on options
    local theme_cmd=""
    if [ "$THEME" != "auto" ]; then
        theme_cmd="git config --global delta.syntax-theme \"$THEME\""
    fi

    local feature_cmds=""
    case "$FEATURES" in
        side-by-side)
            feature_cmds='git config --global delta.side-by-side "true"
git config --global delta.line-numbers "true"'
            ;;
        line-numbers)
            feature_cmds='git config --global delta.line-numbers "true"'
            ;;
        decorations)
            feature_cmds='git config --global delta.line-numbers "true"
git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
git config --global delta.decorations.file-decoration-style "none"
git config --global delta.decorations.file-style "bold yellow ul"'
            ;;
    esac

    cat > "$script_path" <<'EOF'
#!/usr/bin/env bash
#
# Delta postCreateCommand script
# Configures git to use delta as the pager
# This runs after container creation when host gitconfig is mounted
#

echo "[delta] Configuring git to use delta..."

# Core delta configuration
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate "true"
git config --global delta.light "false"

# Merge and diff settings
git config --global merge.conflictstyle "diff3"
git config --global diff.colorMoved "default"

EOF

    # Add theme config if specified
    if [ -n "$theme_cmd" ]; then
        echo "# Theme configuration" >> "$script_path"
        echo "$theme_cmd" >> "$script_path"
        echo "" >> "$script_path"
    fi

    # Add feature-specific config if specified
    if [ -n "$feature_cmds" ]; then
        echo "# Feature-specific configuration" >> "$script_path"
        echo "$feature_cmds" >> "$script_path"
        echo "" >> "$script_path"
    fi

    # Add completion message
    echo 'echo "[delta] Git configured to use delta"' >> "$script_path"

    chmod +x "$script_path"
    log_success "Created $script_path"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting delta installation"

    install_delta

    setup_shell_integration

    # Create postCreateCommand script for git config (runs after mounts are applied)
    if [ "$CONFIGUREGIT" = "true" ]; then
        create_postCreateCommand
    fi

    log_success "Delta feature installation complete"
}

#######################################
# Set up shell integration for delta
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    # Create shell configuration that sources devbox environment
    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# Delta shell integration
# This file is sourced by ~/.shellrc.d/main.sh
# Delta is installed via devbox global, which is loaded by devbox-feature.sh

# Useful delta aliases
alias diff='delta'

# Function to preview delta themes
delta-theme() {
    git config --global delta.syntax-theme "$1"
    echo "Delta theme set to: $1"
    echo "Test with: git diff or git log -p"
}

# Function to show available delta themes
delta-themes() {
    echo "Available delta themes:"
    echo "  - Dracula"
    echo "  - GitHub"
    echo "  - gruvbox-dark"
    echo "  - gruvbox-light"
    echo "  - Monokai Extended"
    echo "  - Nord"
    echo "  - OneHalfDark"
    echo "  - Solarized (dark)"
    echo "  - Solarized (light)"
    echo "  - TwoDark"
    echo ""
    echo "Usage: delta-theme <theme-name>"
}
EOF
)

    write_shellrc_feature "delta" "$shellrc_content"
}

# Execute main function
main "$@"
