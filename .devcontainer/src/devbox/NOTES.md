### Dependencies

> **Required:** This feature requires the `common-utils` feature (and its dependencies) and the `ghcr.io/devcontainers/features/nix` feature to be installed first.
>
> To simplify setup, use a prebuilt base image that includes all dependencies:
> - `ghcr.io/devopsbuildingblocks/devcontainer-images/ubuntu-base` (includes `lib` and `common-utils`)

This is a foundational feature that installs `devbox`, a command-line tool for creating isolated, reproducible development environments powered by Nix. Many other features in this repository depend on it for package management.

### Installation & Configuration
*   Depends on the official `nix` devcontainer feature.
*   Downloads and installs the specified version of the `devbox` binary directly from its GitHub releases.
*   Installs the official `jetpack-io.devbox` VS Code extension.
*   **Default Shell:** It configures the VS Code integrated terminal to use the `devbox shell` by default. This ensures that all terminal sessions are automatically within the isolated `devbox` environment.

### Lifecycle & Shell Integration
*   **Automatic `devbox install`:** After the container is created, a script runs which checks for a `devbox.json` file. If found, it automatically runs `devbox install` to set up the environment. If not, it runs `devbox init` to create a new one.
*   **Global Package Management:** It configures the shell to automatically make any globally installed `devbox` packages (like `eza`, `bat`, `fzf`, etc.) available on the `PATH`.