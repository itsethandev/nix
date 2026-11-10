# Turing

`nixosConfigurations.turing` configures an x86_64 Linux desktop with integrated Home Manager for `ethan` at `/home/ethan`.

Includes Hyprland and Noctalia, Omasnap screenshots, PipeWire audio, Steam and Steam Frame, OBS and DroidCam, Docker, 1Password, development tools, dictation, Ovis for Herdr, an [agent browser](../../modules/agent-browser) with Chromium and OpenCode integration, and media applications. Uses Limine, the latest kernel, declared filesystem UUIDs, and a fixed dual-monitor layout.

Installs [shared agent CLI tools](../../modules/agent-tools) into the user environment for Pi and OpenCode.

Automatically logs into the graphical session and permits passwordless sudo for wheel members. SSH and Samba access use Tailscale interface rules; LocalSend and Steam also open firewall ports.

Restic backs up Documents, screenshots, and RetroArch's `~/Games/saves` and `~/Games/states` directories to R2. Credentials must exist at `/etc/restic/r2.env` and `/etc/restic/password`; the declared Steam Frame adapter and SSH public keys are host-specific.
