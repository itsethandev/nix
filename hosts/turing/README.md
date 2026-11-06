# Turing

`nixosConfigurations.turing` configures an x86_64 Linux desktop with integrated Home Manager for `ethan` at `/home/ethan`.

Includes Hyprland and Noctalia, PipeWire audio, Steam and Steam Frame, OBS and DroidCam, Docker, 1Password, development tools, dictation, Ovis for Herdr, and media applications. Uses Limine, the latest kernel, declared filesystem UUIDs, and a fixed dual-monitor layout.

Automatically logs into the graphical session and permits passwordless sudo for wheel members. SSH and Samba access use Tailscale interface rules; LocalSend and Steam also open firewall ports.

Restic backs up Documents and screenshots to R2. Credentials must exist at `/etc/restic/r2.env` and `/etc/restic/password`; the declared Steam Frame adapter and SSH public keys are host-specific.
