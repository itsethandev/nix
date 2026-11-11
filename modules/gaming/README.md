# Gaming

Linux gaming modules, selected separately:

- `modules.nixos.gaming` enables Steam, GameMode, Gamescope, and Xbox/Switch controller support. It opens Steam Remote Play, dedicated-server, and local game-transfer firewall ports.
- `modules.homeManager.gaming` installs Steam, Archipelago, and Barnyard, the Ultimate Chicken Horse mod manager. It enables session-wide MangoHud, initially hidden and toggled with Super+Ctrl+H. With Hyprland enabled, Super+Shift+S opens Steam. Steam uses workspace 5; recognized games and RetroArch use workspace 5 fullscreen. RetroArch rules match Wayland and X11 windows but do not install RetroArch.

User group membership is supplied by the caller.

The Home Manager module uses the NixOS Steam package when enabled, preserving its graphics libraries, runtime dependencies, and controller integration. Otherwise it installs the standard Steam package.
