
# Oh My Posh (oh-my-posh)

Installs oh-my-posh, a prompt theme engine for any shell, via devbox global

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/oh-my-posh:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of oh-my-posh to install | string | latest |
| theme | Oh My Posh theme to use for prompt customization. You can specify any built-in oh-my-posh theme name here - they will be fetched from GitHub. | string | db2-dark.minimal |

This feature installs `Oh My Posh`, a powerful and highly customizable prompt theme engine for any shell.

### Installation & Configuration
*   Relies on the `devbox` feature to install the specified version of `oh-my-posh`.
*   Initializes the shell prompt using the theme specified in the feature options.
*   It supports both the custom themes bundled with this feature and any of `oh-my-posh`'s numerous built-in themes. For built-in themes, it dynamically constructs a URL to fetch the theme from the official `oh-my-posh` GitHub repository.

### Shell Integration
The feature adds the following commands to the user's shell environment:
*   `omp-themes`: A command that lists the locally installed custom themes and provides a link to the official documentation for all built-in themes.
*   `omp-theme <theme-name>`: A command to dynamically switch the prompt's appearance by applying a new theme (either local or built-in).

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
