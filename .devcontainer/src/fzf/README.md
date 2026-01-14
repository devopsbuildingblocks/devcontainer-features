
# fzf (fzf)

Installs fzf, a general-purpose command-line fuzzy finder, via devbox global

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/fzf:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of fzf to install | string | latest |
| enableKeyBindings | Enable shell key bindings (CTRL-T, CTRL-R, ALT-C) | boolean | true |
| enableCompletion | Enable fuzzy auto-completion for bash/zsh | boolean | true |
| theme | Color theme for fzf interface | string | db2-dark |
| defaultOptions | Default fzf options (FZF_DEFAULT_OPTS) | string | --height 40% --layout=reverse --border |

### Dependencies

> **Required:** This feature requires the `devbox` feature (and its dependencies) to be installed first.
>
> To simplify setup, use a prebuilt base image that includes all dependencies:
> - `ghcr.io/devopsbuildingblocks/devcontainer-images/ubuntu-devbox` (includes `lib`, `common-utils`, `nix`, and `devbox`)

This feature installs `fzf`, a powerful command-line fuzzy finder, and provides deep shell integration for an enhanced user experience.

### Installation & Configuration
*   Relies on the `devbox` feature to install the specified version of `fzf`.
*   Configures `fzf` by setting the `FZF_DEFAULT_OPTS` environment variable, which combines the layout options and color theme selected during setup.
*   If the `bat` feature is also installed, `fzf`'s file finder (`CTRL-T`) is automatically configured to use `bat` for syntax-highlighted file previews.

### Shell Integration
The feature adds the following capabilities to the user's shell environment:
*   **Key Bindings:** If enabled, provides the standard `fzf` key bindings: `CTRL-T` (find file), `CTRL-R` (reverse history search), and `ALT-C` (change directory).
*   **Fuzzy Completion:** If enabled, provides fuzzy completion for common commands (e.g., `cd **<TAB>`).
*   `fzf-themes`: A command to list all available color themes for the `fzf` interface.
*   `fzf-theme <theme-name>`: A command to dynamically switch the active `fzf` theme by updating the `FZF_DEFAULT_OPTS` environment variable.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
