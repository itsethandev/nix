{
  flake.modules.homeManager.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: let
    noctalia = config.programs.noctalia.package;
    exec = chord: command: {
      _args = [chord (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} "${lib.getExe noctalia} msg ${command}"})")];
    };
    captureMenu = pkgs.writeShellApplication {
      name = "capture-menu";
      runtimeInputs = [noctalia];
      text = ''
        choice=$(printf 'Monitor\nApplication\nRegion\n' | noctalia dmenu -p "Capture") || exit 0
        case "$choice" in
          Monitor) exec noctalia msg screenshot-fullscreen pick ;;
          Application) exec noctalia msg screenshot-window ;;
          Region) exec noctalia msg screenshot-region ;;
        esac
      '';
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
        (exec "SUPER + CTRL + Escape" "panel-open session")
        (exec "SUPER + CTRL + A" "panel-open control-center audio")
        (exec "SUPER + CTRL + B" "panel-open control-center bluetooth")
        (exec "SUPER + CTRL + N" "panel-open control-center network")
        (exec "SUPER + CTRL + ALT + space" "bar-toggle")
        (exec "SUPER + CTRL + P" "screenshot-fullscreen --no-annotate")
        {_args = ["SUPER + CTRL + ALT + P" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.getExe captureMenu)})")];}
        (exec "SUPER + CTRL + M" "volume-mute")
        (exec "SUPER + CTRL + ALT + M" "mic-mute")
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
            (lib.generators.mkLuaInline ''function() hl.exec_cmd(${lib.generators.toLua {} (lib.getExe noctalia)}) end'')
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
