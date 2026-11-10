# Desktop

Linux desktop modules, selected separately:

- `modules.nixos.desktop` enables Hyprland with UWSM and XWayland, Noctalia and its login greeter, and PipeWire audio with ALSA, PulseAudio, and JACK support. Stylix applies Espresso colors, JetBrains Mono, Papirus icons, and a generated wallpaper.
- `modules.homeManager.desktop` enables Hyprland and Noctalia for the user, with a Banana cursor, blurred rounded windows, workspace and clipboard shortcuts, and media controls. Idle locking and automatic suspend are disabled; locking before suspend retains the upstream default.

The Home Manager module configures the standard XDG home directories without exporting their session variables and uses Stylix fonts when available. Automatic login is a caller setting, not part of either module.

Desktop bindings follow the [system hotkeys](../../docs/hotkeys.md), including H/J/K/L focus and swaps across monitors, focus-following window moves, and forward/reverse cycling through dwindle, scrolling, and master layouts. Screenshots, app launchers, color picking, dictation, and zoom controls belong to their respective features.
