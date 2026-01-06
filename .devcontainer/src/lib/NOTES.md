This feature is not a user-facing tool but rather an internal, shared library of shell functions that is a prerequisite for almost every other feature in this repository. Its purpose is to provide a consistent, reusable set of helper functions to standardize and simplify the installation scripts of other features.

### Functionality
*   **Installation:** During the container build, this feature's `install.sh` copies the `common.sh` script to a system-wide location (`/usr/local/lib/devcontainer-features/common.sh`).
*   **Usage:** Other features then `source` this file in their own installation scripts to get access to its functions.

### Key Helper Functions Provided
*   **Logging:** A set of `log_*` functions for standardized, color-coded output during installation.
*   **Shell Integration:** The `write_shellrc_feature` function, which provides a clean mechanism for other features to add their aliases, functions, and environment variables to the user's shell via the `~/.shellrc.d` framework.
*   **Devbox Wrapper:** The `devbox_global_add` function, a standardized wrapper for installing packages via `devbox`, which handles environment setup and permissions.
*   **Persistence Scripting:** The `create_volume_symlink_script` function, which auto-generates the necessary `postCreateCommand` scripts for creating persistent, volume-backed symlinks for configuration files and directories.