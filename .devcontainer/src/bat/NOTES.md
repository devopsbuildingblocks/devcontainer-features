This feature installs `bat`, a modern replacement for `cat` with syntax highlighting and Git integration.

### Installation & Configuration
*   Relies on the `devbox` feature to install the specified version of `bat`.
*   The selected color theme is applied by setting the `BAT_THEME` environment variable.
*   It configures the system's `man` command to use `bat` as its pager, resulting in colorized `man` pages.

### Shell Integration
The feature adds the following capabilities and commands to the user's shell environment:
*   **`cat` Alias:** If enabled, the `cat` command is aliased to `bat`. This provides syntax highlighting by default, while preserving the standard, non-paginated behavior of `cat`.
*   **Aliases:** Provides convenient aliases:
    *   `batn`: Displays files with line numbers.
    *   `batf`: Displays files with full `bat` decorations (grid, file header, etc.).
*   `bat-themes`: A command to list all of `bat`'s available built-in themes.
*   `bat-theme <theme-name>`: A command to dynamically switch the active theme by updating the `BAT_THEME` environment variable.