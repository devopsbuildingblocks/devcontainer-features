This feature installs `lazygit`, a popular terminal-based UI for Git, and provides significant shell integration for a rich user experience.

### Installation & Configuration
*   Relies on the `devbox` feature to install the specified version of `lazygit`.
*   Creates a configuration file at `~/.config/lazygit/config.yml` with sensible defaults.
*   Installs a collection of custom themes and applies the one selected during setup.
*   If the `enableGitDiffPager` option is set, it configures `lazygit` to use `delta` for viewing diffs, providing a side-by-side view.

### Shell Integration
The feature adds the following commands to the user's shell environment:
*   `lzg`: A convenient alias for the `lazygit` command.
*   `lzg-themes`: A command to list all available color themes for `lazygit`.
*   `lzg-theme <theme-name>`: A powerful command to dynamically switch the active `lazygit` theme. This command regenerates the configuration file to apply the new theme instantly.