
# ripgrep (ripgrep)

Installs ripgrep (rg), a fast line-oriented search tool, via devbox global

## Example Usage

```json
"features": {
    "ghcr.io/devopsbuildingblocks/devcontainer-features/ripgrep:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of ripgrep to install | string | latest |
| theme | Color theme for ripgrep output | string | db2 |
| smartCase | Enable smart case searching (case-insensitive unless uppercase used) | boolean | true |
| enableAliases | Enable useful rg aliases (rgi, rgf, rgh) | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
