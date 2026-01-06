This feature installs the `gemini-cli` for interacting with Google's Gemini API and the official Google Gemini VS Code extension.

### Installation & Configuration
*   It relies on the `devbox` feature to manage the installation.
*   The specified version of `gemini-cli` is installed as a global `devbox` package.
*   It installs the `google.geminicodeassist` VS Code extension.
*   To ensure Gemini's configuration and history are persisted across container sessions, the feature creates a symlink from the user's home directory (`~/.gemini`) to a mounted Docker volume.