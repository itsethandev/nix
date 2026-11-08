# Ghostty

- `modules.darwin.ghostty` installs Ghostty through Homebrew. With AeroSpace, Cmd+Shift+Return opens it and its windows stay tiled. Requires an existing Homebrew installation.
- `modules.homeManager.ghostty` configures Ghostty on Linux with explicit copy/paste and font-size shortcuts. It defaults to Fish when Fish is independently enabled. With Hyprland, Super+Shift+Return opens a plain terminal and windows receive translucent backgrounds. When Herdr is independently enabled, Super+Shift+Alt+Return opens it in Ghostty instead. Other Ghostty launches do not start Herdr. Herdr's server lifecycle is configured separately.
