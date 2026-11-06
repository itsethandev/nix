# Ovis

`modules.homeManager.ovis` installs Ovis 0.4.22 and registers its Herdr plugin on Linux and Apple Silicon macOS. Requires `programs.herdr.enable` and a Herdr package. Herdr starts Ovis through its startup hook; Start, Stop, Status, and Phone setup remain available as plugin actions. The `ovis` command exposes the same lifecycle commands.

Nix builds the web UI and installs the release's Rust PTY sidecar. Ovis runs without its self-updating supervisor; version changes go through Nix.

Non-secret defaults live in `$XDG_CONFIG_HOME/herdr/plugins/config/devswha.ovis/env`: localhost port 7317 and state under `$XDG_CONFIG_HOME/ovis`. Override that file through `xdg.configFile`. Keep tokens and other private overrides in the adjacent writable `.env`, which takes precedence. Pairings, keys, preferences, and other runtime state remain writable and unmanaged.

Activation replaces the plugin registration without deleting the old installation or restarting a running Ovis process. When migrating, use the Stop Ovis action before activation and Start Ovis afterward, or restart Herdr after stopping Ovis.
