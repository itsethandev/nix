# Desktop

Linux desktop modules, selected separately:

- `modules.nixos.desktop` enables Hyprland with UWSM and XWayland, Noctalia and its login greeter, and PipeWire audio with ALSA, PulseAudio, and JACK support. Stylix applies Espresso colors, JetBrains Mono, Papirus icons, and a generated wallpaper.
- `modules.homeManager.desktop` enables Hyprland and Noctalia for the user, with a Banana cursor, blurred rounded windows, workspace and clipboard shortcuts, screenshots, and media controls. The idle lock timeout is ten minutes; automatic suspend is disabled.

The Home Manager module configures the standard XDG home directories without exporting their session variables and uses Stylix fonts when available. Automatic login is a caller setting, not part of either module.
