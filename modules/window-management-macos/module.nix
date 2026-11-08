{
  flake.modules.darwin.window-management = {lib, ...}: {
    services.aerospace = {
      enable = lib.mkDefault true;
      settings = {
        automatically-unhide-macos-hidden-apps = lib.mkDefault true;
        default-root-container-layout = lib.mkDefault "tiles";
        default-root-container-orientation = lib.mkDefault "auto";
        gaps = {
          inner = {
            horizontal = lib.mkDefault 8;
            vertical = lib.mkDefault 8;
          };
          outer = {
            top = lib.mkDefault 8;
            bottom = lib.mkDefault 8;
            left = lib.mkDefault 8;
            right = lib.mkDefault 8;
          };
        };
        mode.main.binding = {
          "cmd-f" = lib.mkDefault "fullscreen";
          "cmd-t" = lib.mkDefault "layout floating tiling";
          "cmd-y" = lib.mkDefault "layout tiles accordion";
          "cmd-alt-y" = lib.mkDefault "layout accordion tiles";

          "cmd-h" = lib.mkDefault "focus left --boundaries all-monitors-outer-frame";
          "cmd-j" = lib.mkDefault "focus down --boundaries all-monitors-outer-frame";
          "cmd-k" = lib.mkDefault "focus up --boundaries all-monitors-outer-frame";
          "cmd-l" = lib.mkDefault "focus right --boundaries all-monitors-outer-frame";

          "cmd-shift-h" = lib.mkDefault "swap left";
          "cmd-shift-j" = lib.mkDefault "swap down";
          "cmd-shift-k" = lib.mkDefault "swap up";
          "cmd-shift-l" = lib.mkDefault "swap right";

          "cmd-shift-alt-h" = lib.mkDefault "move-node-to-monitor --focus-follows-window left";
          "cmd-shift-alt-j" = lib.mkDefault "move-node-to-monitor --focus-follows-window down";
          "cmd-shift-alt-k" = lib.mkDefault "move-node-to-monitor --focus-follows-window up";
          "cmd-shift-alt-l" = lib.mkDefault "move-node-to-monitor --focus-follows-window right";

          "cmd-1" = lib.mkDefault "workspace 1";
          "cmd-2" = lib.mkDefault "workspace 2";
          "cmd-3" = lib.mkDefault "workspace 3";
          "cmd-4" = lib.mkDefault "workspace 4";
          "cmd-5" = lib.mkDefault "workspace 5";
          "cmd-6" = lib.mkDefault "workspace 6";
          "cmd-7" = lib.mkDefault "workspace 7";
          "cmd-8" = lib.mkDefault "workspace 8";
          "cmd-9" = lib.mkDefault "workspace 9";
          "cmd-0" = lib.mkDefault "workspace 10";

          "cmd-shift-1" = lib.mkDefault "move-node-to-workspace --focus-follows-window 1";
          "cmd-shift-2" = lib.mkDefault "move-node-to-workspace --focus-follows-window 2";
          "cmd-shift-3" = lib.mkDefault "move-node-to-workspace --focus-follows-window 3";
          "cmd-shift-4" = lib.mkDefault "move-node-to-workspace --focus-follows-window 4";
          "cmd-shift-5" = lib.mkDefault "move-node-to-workspace --focus-follows-window 5";
          "cmd-shift-6" = lib.mkDefault "move-node-to-workspace --focus-follows-window 6";
          "cmd-shift-7" = lib.mkDefault "move-node-to-workspace --focus-follows-window 7";
          "cmd-shift-8" = lib.mkDefault "move-node-to-workspace --focus-follows-window 8";
          "cmd-shift-9" = lib.mkDefault "move-node-to-workspace --focus-follows-window 9";
          "cmd-shift-0" = lib.mkDefault "move-node-to-workspace --focus-follows-window 10";

          "cmd-shift-alt-1" = lib.mkDefault "move-node-to-workspace 1";
          "cmd-shift-alt-2" = lib.mkDefault "move-node-to-workspace 2";
          "cmd-shift-alt-3" = lib.mkDefault "move-node-to-workspace 3";
          "cmd-shift-alt-4" = lib.mkDefault "move-node-to-workspace 4";
          "cmd-shift-alt-5" = lib.mkDefault "move-node-to-workspace 5";
          "cmd-shift-alt-6" = lib.mkDefault "move-node-to-workspace 6";
          "cmd-shift-alt-7" = lib.mkDefault "move-node-to-workspace 7";
          "cmd-shift-alt-8" = lib.mkDefault "move-node-to-workspace 8";
          "cmd-shift-alt-9" = lib.mkDefault "move-node-to-workspace 9";
          "cmd-shift-alt-0" = lib.mkDefault "move-node-to-workspace 10";

          "cmd-tab" = lib.mkDefault "focus-monitor --wrap-around next";
          "cmd-alt-tab" = lib.mkDefault "focus-monitor --wrap-around prev";
          "cmd-shift-tab" = lib.mkDefault "move-node-to-monitor --wrap-around --focus-follows-window next";
          "cmd-shift-alt-tab" = lib.mkDefault "move-node-to-monitor --wrap-around --focus-follows-window prev";
        };
      };
    };
  };
}
