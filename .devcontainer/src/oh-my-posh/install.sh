#!/usr/bin/env bash
#
# Oh My Posh Feature Installation Script
# Installs oh-my-posh via devbox global and configures shell integration
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"
THEME="${THEME:-robbyrussell}"

#######################################
# Install oh-my-posh via devbox global
#######################################
install_oh_my_posh() {
    log_info "Installing oh-my-posh (version: $VERSION)"

    local package_spec="oh-my-posh"
    if [ "$VERSION" != "latest" ]; then
        package_spec="oh-my-posh@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    # Verify installation
    if ! command_exists oh-my-posh; then
        log_error "oh-my-posh installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(oh-my-posh version)
    log_success "oh-my-posh installed: $installed_version"
}

#######################################
# Setup oh-my-posh themes directory
#######################################
setup_themes() {
    log_info "Setting up oh-my-posh themes"

    local user_home
    user_home=$(get_remote_user_home)
    local themes_dir="${user_home}/.local/share/oh-my-posh/themes"

    # Create themes directory
    ensure_directory "${user_home}/.local/share/oh-my-posh"

    # Copy bundled themes to user directory
    if [ -d "themes" ]; then
        cp -r themes "$themes_dir"

        local user
        user=$(get_remote_user)
        if [ "$user" != "root" ]; then
            chown -R "$user:$user" "${user_home}/.local/share/oh-my-posh"
        fi

        log_success "Themes installed to $themes_dir"
    else
        log_warning "No bundled themes directory found, will use oh-my-posh built-in themes"
    fi
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting oh-my-posh installation"

    install_oh_my_posh
    setup_themes
    setup_shell_integration

    log_success "Oh My Posh feature installation complete"
}

#######################################
# Get theme path for selected theme
# Returns:
#   Full path to the theme file (local) or URL (built-in)
#######################################
get_theme_path() {
    local user_home
    user_home=$(get_remote_user_home)
    local local_theme_path="${user_home}/.local/share/oh-my-posh/themes/${THEME}.omp.json"

    # Check if theme exists locally (custom theme)
    if [ -f "$local_theme_path" ]; then
        echo "$local_theme_path"
    else
        # Use built-in theme from oh-my-posh GitHub repository
        local omp_version
        omp_version=$(oh-my-posh version)
        echo "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/tags/v${omp_version}/themes/${THEME}.omp.json"
    fi
}

#######################################
# Set up shell integration for oh-my-posh
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local theme_path
    theme_path=$(get_theme_path)

    # Create shell configuration
    local shellrc_content
    shellrc_content=$(cat <<EOF
# Oh My Posh shell integration
# This file is sourced by ~/.shellrc.d/main.sh
# Oh My Posh is installed via devbox global, which is loaded by devbox-feature.sh

# Set locale for proper character rendering
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Track current theme
export CURRENT_OHMYPOSH_THEME="$THEME"

# Initialize oh-my-posh for the current shell
if command -v oh-my-posh >/dev/null 2>&1; then
    if [ -n "\${BASH_VERSION:-}" ]; then
        eval "\$(oh-my-posh init bash --config "$theme_path")"
    elif [ -n "\${ZSH_VERSION:-}" ]; then
        eval "\$(oh-my-posh init zsh --config "$theme_path")"
    elif [ -n "\${FISH_VERSION:-}" ]; then
        oh-my-posh init fish --config "$theme_path" | source
    fi
fi

# Helper function to switch oh-my-posh themes
omp-theme() {
    if [ -z "\$1" ]; then
        echo "Error: No theme specified"
        echo ""
        omp-themes
        return 1
    fi

    local theme_name="\$1"
    local local_theme_path=~/.local/share/oh-my-posh/themes/\${theme_name}.omp.json
    local theme_path

    # Check if it's a custom local theme
    if [ -f "\$local_theme_path" ]; then
        theme_path="\$local_theme_path"
    else
        # Use built-in theme from oh-my-posh GitHub repository
        local omp_version
        omp_version=\$(oh-my-posh version)
        theme_path="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/tags/v\${omp_version}/themes/\${theme_name}.omp.json"
    fi

    # Reinitialize oh-my-posh with new theme
    if [ -n "\${BASH_VERSION:-}" ]; then
        eval "\$(oh-my-posh init bash --config "\$theme_path")"
    elif [ -n "\${ZSH_VERSION:-}" ]; then
        eval "\$(oh-my-posh init zsh --config "\$theme_path")"
    fi

    # Update environment variable to track current theme
    export CURRENT_OHMYPOSH_THEME="\$theme_name"

    echo "Oh My Posh theme switched to: \$theme_name"
}

# Helper function to list available oh-my-posh themes
omp-themes() {
    echo "Available oh-my-posh themes:"
    echo ""
    echo "Custom themes:"
    if ls ~/.local/share/oh-my-posh/themes/*.omp.json >/dev/null 2>&1; then
        ls -1 ~/.local/share/oh-my-posh/themes/*.omp.json 2>/dev/null | xargs -n1 basename | sed 's/.omp.json//' | sed 's/^/  /'
    else
        echo "  (none installed)"
    fi
    echo ""
    echo "Built-in themes: https://ohmyposh.dev/docs/themes"
    echo "  Popular: robbyrussell, agnoster, paradox, powerlevel10k_rainbow"
    echo ""
    echo "Current theme: \${CURRENT_OHMYPOSH_THEME:-unknown}"
    echo ""
    echo "Usage: omp-theme <theme-name>"
}
EOF
)

    write_shellrc_feature "oh-my-posh" "$shellrc_content"
}

# Execute main function
main "$@"
