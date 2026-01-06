This is a critical, foundational feature that sets up the user, shell, and configuration persistence for the entire dev container. It builds upon the official `ghcr.io/devcontainers/features/common-utils` feature.

### User and Shell Setup
*   Uses the official `common-utils` feature to create a non-root user named `vscode`.
*   Sets `zsh` as the default shell for the container.

### Configuration Persistence
*   To ensure that caches, local application data, and shell history are not lost when the container is rebuilt, this feature creates and mounts Docker volumes for:
    *   `~/.cache`
    *   `~/.local`
    *   `~/.shell_history`
*   It then symlinks the corresponding directories in the user's home directory to these mounted volumes.
*   It configures both `bash` and `zsh` to use a shared, persistent history file located in the mounted `~/.shell_history` directory.

### Shell Integration Framework
*   This feature's most important role is creating a shell integration framework located at `~/.shellrc.d`.
*   It adds a loader to `~/.bashrc` and `~/.zshrc` that sources all `.sh` files within this directory.
*   All other features that provide shell integration (like aliases or functions for `bat`, `fzf`, `eza`, etc.) add their own scripts into this directory, allowing for a clean, modular, and extensible shell environment.