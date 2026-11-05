{
  lib,
  pkgs,
  ...
}: let
  bind = chord: command: {
    _args = [chord (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} command})")];
  };
  gamingWindowPatterns = [
    "^steam_app_.*$"
    "^Hollow Knight Silksong$"
    "^Hytale$"
    "^deadcells$"
    "^Minecraft.*$"
    "^MinaTheHollower$"
    "^UltimateChickenHorse.*$"
  ];
  gamingWindowRules = lib.concatMap (pattern:
    map (field: {
      name = "gaming-${field}-${pattern}";
      match.${field} = pattern;
      workspace = "5";
      fullscreen = true;
    }) ["initial_class" "initial_title"])
  gamingWindowPatterns;
in {
  wayland.windowManager.hyprland = {
    systemd.enable = false;
    settings = {
      config.misc.mouse_move_enables_dpms = true;
      on = lib.mkAfter [
        {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''function() hl.exec_cmd(${lib.generators.toLua {} "${lib.getExe pkgs.xrandr} --output DP-4 --primary"}) end'')
          ];
        }
      ];
      bind = lib.mkAfter [
        (bind "SUPER + Return" (lib.getExe pkgs.ghostty))
        (bind "SUPER + mouse_down" "${lib.getExe pkgs.hyprzoom} 0.8")
        (bind "SUPER + mouse_up" "${lib.getExe pkgs.hyprzoom} 1.25")
        (bind "SUPER + mouse:274" "${lib.getExe pkgs.hyprzoom} 0")
        {_args = ["SUPER + G" (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 5 })")];}
      ];
      monitor = [
        {
          output = "DP-4";
          mode = "2560x1440@164.80";
          position = "1920x-360";
          scale = 1;
        }
        {
          output = "HDMI-A-1";
          mode = "1920x1080@60.00";
          position = "0x0";
          scale = 1;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];
      window_rule = lib.mkAfter ([
          {
            name = "ghostty-opacity";
            match.class = "com.mitchellh.ghostty";
            opacity = 0.875;
          }
          {
            name = "discord-popout";
            match.initial_title = "^Discord Popout$";
            float = true;
            pin = true;
            size = "(monitor_w*0.25) (monitor_h*0.25)";
            move = "(monitor_w-window_w-48) (monitor_h-window_h-48)";
          }
          {
            name = "steam-workspace";
            match = {
              initial_class = "^steam$";
              initial_title = "negative:^Steam Input On-screen Keyboard$";
            };
            workspace = "5 silent";
          }
          {
            name = "steam-keyboard";
            match = {
              initial_class = "^steam$";
              initial_title = "^Steam Input On-screen Keyboard$";
            };
            workspace = "unset";
            float = true;
            no_focus = true;
            pin = true;
            move = "((monitor_w-window_w)/2) (monitor_h-window_h)";
          }
          {
            name = "obs-projector";
            match.initial_title = "^Projector.*$";
            workspace = "special:presentation silent";
            fullscreen = true;
          }
        ]
        ++ gamingWindowRules);
      workspace_rule = map (number: {
        workspace = toString number;
        monitor =
          if number <= 5
          then "DP-4"
          else "HDMI-A-1";
        persistent = true;
        default = number == 1 || number == 6;
      }) (lib.range 1 10);
    };
  };
}
