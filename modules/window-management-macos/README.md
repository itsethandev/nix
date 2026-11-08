# macOS window management

`modules.darwin.window-management` enables AeroSpace with automatic tiling and eight-pixel gaps.

Bindings approximate the [system hotkeys](../../docs/hotkeys.md), using Cmd for Super. Cmd+H/J/K/L changes focus; adding Shift swaps windows within the workspace, and adding Shift+Alt moves windows between monitors with focus following. Cmd+1–9/0 selects workspaces 1–10; adding Shift moves windows and follows, while Shift+Alt moves without following. Cmd+Tab cycles monitor focus; adding Shift moves the window and follows it. Alt reverses either cycle. Cmd+Y and Cmd+Alt+Y toggle between AeroSpace's tiles and accordion layouts rather than Linux's three layouts. Cmd+F toggles fullscreen and Cmd+T toggles floating layout. macOS-hidden applications are automatically unhidden.

This module supplies window management, not Linux shell panels, dictation, color picking, screenshots, or app launchers. Native macOS editing and launcher shortcuts remain available; app features may add their own system bindings.
