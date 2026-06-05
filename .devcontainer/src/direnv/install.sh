#!/usr/bin/env bash
#
# direnv Feature Installation Script
# Installs direnv via devbox global and configures /workspaces whitelist
#

set -e

# Source common utilities from system-wide installation
# The lib feature must be installed before this feature
# shellcheck source=/usr/local/lib/devcontainer-features/common.sh
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (passed as environment variables from devcontainer)
VERSION="${VERSION:-latest}"

#######################################
# Install direnv via devbox global
#######################################
install_direnv() {
    log_info "Installing direnv (version: $VERSION)"

    local package_spec="direnv"
    if [ "$VERSION" != "latest" ]; then
        package_spec="direnv@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    if ! command_exists direnv; then
        log_error "direnv installation failed - command not found"
        exit 1
    fi

    local installed_version
    installed_version=$(direnv version)
    log_success "direnv installed: $installed_version"
}

#######################################
# Setup direnv config for a specific user
# Arguments:
#   $1 - User name
#   $2 - User home directory
#######################################
setup_config_for_user() {
    local user="$1"
    local user_home="$2"
    local config_dir="${user_home}/.config/direnv"

    log_info "Setting up direnv configuration for user: $user"
    mkdir -p "$config_dir"

    local config_file="${config_dir}/config.toml"

    cat > "$config_file" <<'EOF'
[whitelist]
prefix = ["/workspaces"]
EOF

    if [ "$user" != "root" ]; then
        chown -R "$user:$user" "${user_home}/.config"
    fi

    log_success "Created direnv config at $config_file for $user"
}

#######################################
# Setup direnv configuration for all users
#######################################
setup_config() {
    setup_config_for_user "root" "/root"

    local remote_user
    remote_user=$(get_remote_user)
    if [ "$remote_user" != "root" ]; then
        local remote_user_home
        remote_user_home=$(get_remote_user_home)
        setup_config_for_user "$remote_user" "$remote_user_home"
    fi
}

#######################################
# Setup shell integration
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# direnv shell integration
# This file is sourced by ~/.shellrc.d/main.sh

eval "$(direnv hook zsh)"
EOF
)

    write_shellrc_feature "direnv" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting direnv installation"

    install_direnv
    setup_config
    setup_shell_integration

    log_success "direnv feature installation complete"
}

# Execute main function
main "$@"
