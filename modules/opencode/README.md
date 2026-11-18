# OpenCode

`modules.homeManager.opencode` installs OpenCode 2.3.2 (CLI and desktop app) on Linux and macOS, with the shared agent instructions, ItsSkills catalog, and `opencode-mobile-notifications` plugin. The version override is also exported as `overlays.opencode`. Web searches and page fetches are allowed without prompts for all agents by default. Shared instructions encourage proactive web research. The question tool is denied by default.

Herdr integration is added when Herdr is enabled. The CLI enables system notifications, shows large pastes as full text, and uses the Stylix theme when Stylix is enabled.

With Hyprland and Ghostty independently enabled, Super+Shift+A opens OpenCode in a plain Ghostty terminal.
