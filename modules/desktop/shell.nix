{
  flake.modules.homeManager.desktop = {lib, ...}: let
    exec = chord: command: {
      _args = [chord (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} "noctalia msg ${command}"})")];
    };
  in {
    programs.noctalia = {
      enable = lib.mkDefault true;
      settings = {
        idle.behavior = {
          lock = {
            action = lib.mkDefault "lock";
            enabled = lib.mkDefault true;
            timeout = lib.mkDefault 600;
          };
          lock-and-suspend = {
            action = lib.mkDefault "lock_and_suspend";
            enabled = lib.mkDefault false;
          };
          screen-off = {
            action = lib.mkDefault "screen_off";
            enabled = lib.mkDefault false;
            timeout = lib.mkDefault 660;
          };
        };
        keybinds = {
          down = lib.mkDefault ["Down" "Ctrl+n"];
          up = lib.mkDefault ["Up" "Ctrl+p"];
        };
        osd.kinds.keyboard_layout = lib.mkDefault false;
        shell.launcher.categories = lib.mkDefault false;
      };
    };
    wayland.windowManager.hyprland.settings = {
      bind = [
        (exec "SUPER + space" "panel-toggle launcher")
        (exec "SUPER + ALT + V" "panel-toggle clipboard")
        (exec "SUPER + CTRL + space" "panel-toggle control-center")
        (exec "SUPER + P" "screenshot-fullscreen")
        (exec "SUPER + SHIFT + P" "screenshot-region")
        (exec "SUPER + M" "mic-mute")
        (exec "XF86AudioRaiseVolume" "volume-up")
        (exec "XF86AudioLowerVolume" "volume-down")
        (exec "XF86AudioMute" "volume-mute")
        (exec "XF86MonBrightnessUp" "brightness-up")
        (exec "XF86MonBrightnessDown" "brightness-down")
      ];
      on = [
        {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''function() hl.exec_cmd("noctalia") end'')
          ];
        }
      ];
      layer_rule = {
        name = lib.mkDefault "noctalia";
        match.namespace = lib.mkDefault "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
        blur = lib.mkDefault true;
        blur_popups = lib.mkDefault true;
        ignore_alpha = lib.mkDefault 0.5;
        no_anim = lib.mkDefault true;
      };
      window_rule = [
        {
          name = "noctalia-settings";
          match.class = "^dev\\.noctalia\\.Noctalia$";
          float = true;
          size = "1080 920";
        }
      ];
    };
  };
}
