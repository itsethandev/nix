# Turing

`nixosConfigurations.turing` configures an x86_64 Linux desktop with integrated Home Manager for `ethan` at `/home/ethan`.

Includes Hyprland and Noctalia, Omasnap screenshots, PipeWire audio, Steam and Steam Frame, OBS and DroidCam, Docker, 1Password, development tools, dictation, Ovis for Herdr, an [agent browser](../../modules/agent-browser) with Chromium and OpenCode integration, and media applications. Uses Limine, the latest kernel, declared filesystem UUIDs, and a fixed dual-monitor layout.

Installs [shared agent CLI tools](../../modules/agent-tools) into the user environment for Pi and OpenCode, the `playwright` CLI with Nix-managed browsers for web testing, and [Obsidian](../../modules/obsidian) for notes without managing vaults or application settings.

Adds `Hyper + F13` to hold dictation and Discord push-to-mute together, leaving their individual bindings unchanged. See [Hotkeys](../../docs/hotkeys.md#keyboard-macro-hotkeys).

Declares Tailscale Serve at `turing.tailnet.ethanbrady.xyz`: HTTPS port 443 proxies `/` to Ovis on `127.0.0.1:7317`, and HTTPS ports 8443 and 8444 proxy `/` to local HTTP development servers on `127.0.0.1:3000` and `127.0.0.1:5173`, respectively. Separate HTTPS ports leave development ports available for servers that bind to all interfaces. The declaration replaces all existing Serve and Funnel settings; no other routes are retained.

Automatically logs into the graphical session and permits passwordless sudo for wheel members. SSH and Samba access use Tailscale interface rules; LocalSend and Steam also open firewall ports.

Restic backs up Documents, screenshots, and RetroArch's `~/Games/saves` and `~/Games/states` directories to R2. Credentials must exist at `/etc/restic/r2.env` and `/etc/restic/password`; the declared Steam Frame adapter and SSH public keys are host-specific.
