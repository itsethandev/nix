# Agent browser

`modules.homeManager.agent-browser` installs a pinned [Browse](https://github.com/anomalyco/browse) CLI (`browse`) and enables Chromium on x86_64 and aarch64 Linux. It does not change the default browser or manage extensions, browser profiles, or pairing. Nix controls CLI updates; Browse's automatic updater is disabled.

When OpenCode is independently enabled, the module registers an `agent-browser` MCP server running `browse mcp`, disabled by default. Connect it manually through `/mcps` in OpenCode. It does not grant browser-access permissions.

After activation, install the Browse extension from the Chrome Web Store in Chromium. Run `browse pair`, open the extension's options, and enter the code under **Pair with a code**. Keep the selected browser open when using the MCP server. Do not run `browse install`; the module already manages the package and OpenCode configuration.

The CLI is also available as `packages.<system>.agent-browser` on supported Linux systems.
