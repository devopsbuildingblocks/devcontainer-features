# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains [Dev Container Features](https://containers.dev/implementors/features/) for tools commonly used in development environments. Features are installed via devbox global and integrate with shell configurations.

## Common Commands

```sh
# Run all feature tests
task test

# Test a specific feature
task test -- <feature-name>

# Generate feature documentation (run from .devcontainer/src)
task docs

# Validate bash scripts
shellcheck -e SC1091 .devcontainer/src/*/install.sh

# Validate YAML files
yamllint .devcontainer/src/lazygit/themes/*.yml
```

## Architecture

### Feature Structure

Features live in `.devcontainer/src/<feature-name>/` with this structure:
- `devcontainer-feature.json` - Feature metadata, options, and dependencies
- `install.sh` - Installation script
- `README.md` - Auto-generated documentation

### Feature Tests

**Every feature MUST have tests** in `.devcontainer/test/<feature-name>/` with this structure:
- `scenarios.json` - Defines test scenarios with different feature configurations
- `test.sh` - Default test script (runs for the "default" scenario)
- `<scenario-name>.sh` - Additional test scripts matching scenario names

**scenarios.json format:**
```json
{
    "default": {
        "image": "mcr.microsoft.com/devcontainers/base:debian",
        "features": {
            "ghcr.io/devcontainers/features/nix:1": {},
            "lib": {},
            "common-utils": {},
            "devbox": {},
            "<feature-name>": {}
        }
    },
    "custom_scenario": {
        "image": "mcr.microsoft.com/devcontainers/base:debian",
        "features": {
            "ghcr.io/devcontainers/features/nix:1": {},
            "lib": {},
            "common-utils": {},
            "devbox": {},
            "<feature-name>": {
                "option1": "value1"
            }
        }
    }
}
```

**Test script pattern:**
```bash
#!/bin/bash
set -e

# Source devbox environment
USER_HOME="${HOME:-/home/vscode}"
if [ -f "${USER_HOME}/.shellrc.d/devbox-feature.sh" ]; then
    source "${USER_HOME}/.shellrc.d/devbox-feature.sh" 2>/dev/null || true
fi

# Test 1: Check command exists
echo "Test: <tool> command is available"
if command -v <tool> &>/dev/null; then
    echo "PASSED: <tool> command is available"
else
    echo "FAILED: <tool> command not found"
    exit 1
fi

# Additional tests...

echo "All <feature> tests passed!"
```

### Shared Library

`.devcontainer/src/lib/common.sh` provides reusable functions for all features:

**Logging:**
- `log_info`, `log_success`, `log_warning`, `log_error` - Colored output

**User Management:**
- `get_remote_user`, `get_remote_user_home` - User context helpers
- `run_as_user` - Execute commands as the remote user

**Package Management:**
- `devbox_global_add` - Install packages via devbox global

**Shell Integration:**
- `write_shellrc_feature` - Write shell config to `~/.shellrc.d/`

**Volume Mount Persistence:**
- `create_volume_symlink_script` - Generate postCreateCommand scripts for volume-backed symlinks

**Utilities:**
- `ensure_directory`, `command_exists` - Directory and command helpers

Install scripts source this library from `/usr/local/lib/devcontainer-features/common.sh`.

### Feature Dependencies

Features use `dependsOn` in their JSON to declare dependencies:
- `lib` - Provides the shared common.sh library
- `common-utils` - Base shell setup (zsh, user creation)
- `devbox` - Provides devbox for package installation

### Shell Integration

Features write shell configuration to `~/.shellrc.d/<feature>-feature.sh`. This directory is sourced by the shell on startup, enabling feature-specific environment setup.

### Theme Files

If a tool supports theme/color customization, themes MUST be stored in separate files:
- Location: `.devcontainer/src/<feature-name>/themes/`
- Installed to: `/usr/local/share/devcontainer-features/<feature-name>/themes/`
- Use `setup_themes()` function to copy themes during installation

**Theme file format examples:**
- YAML for complex configs (lazygit): `themes/<theme-name>.yml`
- Simple key-value for color strings (fzf): `themes/<theme-name>.theme`

**Theme file structure:**
```
# <Theme Name> theme for <tool>
# Brief description of the color palette

<theme content - one property per line for readability>
```

**Standard setup_themes() pattern:**
```bash
setup_themes() {
    local themes_src="themes"
    local themes_dest="/usr/local/share/devcontainer-features/<feature>/themes"

    if [ -d "$themes_src" ]; then
        log_info "Installing themes to $themes_dest"
        mkdir -p "$themes_dest"
        cp -r "$themes_src"/* "$themes_dest/"
    fi
}
```

**Theme switching functions:**

Features with themes MUST provide shell functions for runtime theme switching:
- `<prefix>-themes` - List all available themes and show current theme
- `<prefix>-theme <name>` - Switch to a different theme

Standard prefixes by feature:
- `bat-theme`, `bat-themes` - bat syntax highlighter
- `fzf-theme`, `fzf-themes` - fzf fuzzy finder
- `lzg-theme`, `lzg-themes` - lazygit
- `omp-theme`, `omp-themes` - oh-my-posh

These functions should:
1. Track the current theme in `CURRENT_<TOOL>_THEME` environment variable
2. Validate the theme name exists before switching
3. Print helpful error messages with available themes if invalid
4. Apply the theme immediately without requiring shell restart

### Volume Mount Persistence

Features can persist configuration across container rebuilds using volume mounts:
- Volume mount location: `/mnt/devcontainer-features/<feature-name>`
- Use `create_volume_symlink_script()` from common.sh to generate postCreateCommand scripts
- Scripts handle merging existing content and creating symlinks automatically
- Example: `create_volume_symlink_script "claude" ".claude" ".claude.json"`

## Coding Standards

### Function Naming Convention

All feature install scripts MUST follow these naming standards:

**Required Functions:**
- `main()` - Entry point, orchestrates installation (always defined last)

**Standard Functions (use when applicable):**
- `install_<toolname>()` - Install the primary tool via devbox global
- `setup_config()` - Setup configuration files (e.g., ~/.config/<toolname>/)
- `setup_shell_integration()` - Create shell integration via write_shellrc_feature()
- `setup_volume_mounts()` - Setup volume mount symlinks for persistence
- `setup_themes()` - Install theme files or resources

**Helper Functions:**
- `get_<something>()` - Getter functions that return computed values
- `generate_<something>()` - Generate content (configs, scripts, etc.)

**Naming Rules:**
- Use `snake_case` for all function names
- Use descriptive names that clearly indicate purpose
- Use consistent prefixes: `install_`, `setup_`, `get_`, `generate_`
- Avoid generic names like `config()` or `themes()`

### Standard main() Structure

```bash
main() {
    log_info "Starting <feature> installation"

    # Phase 1: Install the tool (if applicable)
    install_<toolname>

    # Phase 2: Setup resources (if applicable)
    setup_themes

    # Phase 3: Setup configuration (if applicable)
    setup_config

    # Phase 4: Setup shell integration (if applicable)
    setup_shell_integration

    # Phase 5: Setup volume mounts (if applicable)
    setup_volume_mounts

    log_success "<Feature> feature installation complete"
}

# Execute main function
main "$@"
```

### Code Quality

- **All scripts MUST pass shellcheck**: `shellcheck -e SC1091 install.sh`
- **All YAML files MUST pass yamllint**: `yamllint file.yml`
- Use proper quoting to prevent word splitting
- Use `find` instead of `ls` for file listings
- Prefer `sed`, `awk`, `grep` from dedicated tools over bash commands when available

### Feature Template

```bash
#!/usr/bin/env bash
#
# <Toolname> Feature Installation Script
# Installs <toolname> via devbox global and configures <purpose>
#

set -e

# Source common utilities
source /usr/local/lib/devcontainer-features/common.sh

# Feature options (from devcontainer-feature.json)
VERSION="${VERSION:-latest}"

#######################################
# Install <toolname> via devbox global
#######################################
install_<toolname>() {
    local package_spec="<toolname>"
    if [ "$VERSION" != "latest" ]; then
        package_spec="<toolname>@${VERSION}"
    fi

    devbox_global_add "$package_spec"

    if ! command_exists <toolname>; then
        log_error "<toolname> installation failed"
        exit 1
    fi

    log_success "<toolname> installed: $(<toolname> --version)"
}

#######################################
# Setup <toolname> configuration
#######################################
setup_config() {
    local user_home
    user_home=$(get_remote_user_home)
    local config_dir="${user_home}/.config/<toolname>"

    ensure_directory "$config_dir"

    # Create config...

    log_success "Created <toolname> config"
}

#######################################
# Setup shell integration
#######################################
setup_shell_integration() {
    log_info "Setting up shell integration"

    local shellrc_content
    shellrc_content=$(cat <<'EOF'
# <Toolname> shell integration
# Aliases, functions, environment variables...
EOF
)

    write_shellrc_feature "<toolname>" "$shellrc_content"
}

#######################################
# Main installation function
#######################################
main() {
    log_info "Starting <toolname> installation"

    install_<toolname>
    setup_config
    setup_shell_integration

    log_success "<Toolname> feature installation complete"
}

# Execute main function
main "$@"
```
