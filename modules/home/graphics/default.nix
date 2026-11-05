{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.graphics;
  ipc = "noctalia msg";
  bind = chord: dispatcher: {
    _args = [chord (lib.generators.mkLuaInline dispatcher)];
  };
  exec = chord: command: bind chord "hl.dsp.exec_cmd(${lib.generators.toLua {} command})";
  pasteShortcut = pkgs.writeShellScript "paste-shortcut" ''
    if ${lib.getExe' pkgs.wl-clipboard "wl-paste"} --list-types |
      ${lib.getExe pkgs.gnugrep} -q '^image/'; then
      ${lib.getExe' pkgs.hyprland "hyprctl"} dispatch sendshortcut CTRL,V,activewindow
    else
      ${lib.getExe' pkgs.hyprland "hyprctl"} dispatch sendshortcut SHIFT,Insert,activewindow
    fi
  '';
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.my.graphics.enable = lib.mkEnableOption "opinionated Hyprland and Noctalia graphical environment";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "my.graphics.enable requires Linux.";
      }
      {
        assertion = config.stylix.enable;
        message = "my.graphics.enable requires Stylix.";
      }
    ];

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
        shell = {
          font_family = lib.mkDefault config.stylix.fonts.sansSerif.name;
          launcher.categories = lib.mkDefault false;
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = lib.mkDefault true;
      configType = lib.mkDefault "lua";
      settings = {
        config = {
          binds.scroll_event_delay = lib.mkDefault 0;
          cursor.inactive_timeout = lib.mkDefault 3;
          decoration.blur.enabled = lib.mkDefault true;
          decoration.blur.passes = lib.mkDefault 2;
          decoration.blur.size = lib.mkDefault 3;
          decoration.blur.vibrancy = lib.mkDefault 0.1696;
          decoration.rounding = lib.mkDefault 20;
          decoration.rounding_power = lib.mkDefault 2;
          decoration.shadow.color = lib.mkDefault "rgba(1a1a1aee)";
          decoration.shadow.enabled = lib.mkDefault true;
          decoration.shadow.range = lib.mkDefault 4;
          decoration.shadow.render_power = lib.mkDefault 3;
          general.border_size = lib.mkDefault 2;
          general.gaps_in = lib.mkDefault 5;
          general.gaps_out = lib.mkDefault 10;
          misc.disable_hyprland_logo = lib.mkDefault true;
          misc.disable_splash_rendering = lib.mkDefault true;
          misc.focus_on_activate = lib.mkDefault true;
          misc.middle_click_paste = lib.mkDefault false;
        };

        on = [
          {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''function() hl.exec_cmd("noctalia") end'')
            ];
          }
        ];

        bind =
          [
            (bind "SUPER + C" ''hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" })'')
            (exec "SUPER + V" "${pasteShortcut}")
            (bind "SUPER + X" ''hl.dsp.send_shortcut({ mods = "CTRL", key = "X" })'')
            (bind "SUPER + A" ''hl.dsp.send_shortcut({ mods = "CTRL", key = "A" })'')
            (bind "SUPER + Z" ''hl.dsp.send_shortcut({ mods = "CTRL", key = "Z" })'')
            (bind "SUPER + SHIFT + Z" ''hl.dsp.send_shortcut({ mods = "CTRL + SHIFT", key = "Z" })'')
            (bind "SUPER + W" "hl.dsp.window.close()")
            (bind "SUPER + CTRL + W" "hl.dsp.window.kill()")
            (bind "SUPER + F" ''hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" })'')
            (bind "SUPER + T" ''hl.dsp.window.float({ action = "toggle" })'')
            (bind "SUPER + H" ''hl.dsp.focus({ direction = "left" })'')
            (bind "SUPER + J" ''hl.dsp.focus({ direction = "down" })'')
            (bind "SUPER + K" ''hl.dsp.focus({ direction = "up" })'')
            (bind "SUPER + L" ''hl.dsp.focus({ direction = "right" })'')
            (bind "SUPER + SHIFT + H" ''hl.dsp.window.move({ direction = "left" })'')
            (bind "SUPER + SHIFT + J" ''hl.dsp.window.move({ direction = "down" })'')
            (bind "SUPER + SHIFT + K" ''hl.dsp.window.move({ direction = "up" })'')
            (bind "SUPER + SHIFT + L" ''hl.dsp.window.move({ direction = "right" })'')
            (bind "SUPER + Tab" ''hl.dsp.focus({ monitor = "+1" })'')
            (bind "SUPER + SHIFT + Tab" ''hl.dsp.window.move({ monitor = "+1", follow = false })'')
            (exec "SUPER + space" "${ipc} panel-toggle launcher")
            (exec "SUPER + CTRL + V" "${ipc} panel-toggle clipboard")
            (exec "SUPER + CTRL + space" "${ipc} panel-toggle control-center")
            (exec "SUPER + P" "${ipc} screenshot-fullscreen")
            (exec "SUPER + SHIFT + P" "${ipc} screenshot-region")
            (exec "SUPER + M" "${ipc} mic-mute")
            (exec "XF86AudioRaiseVolume" "${ipc} volume-up")
            (exec "XF86AudioLowerVolume" "${ipc} volume-down")
            (exec "XF86AudioMute" "${ipc} volume-mute")
            (exec "XF86MonBrightnessUp" "${ipc} brightness-up")
            (exec "XF86MonBrightnessDown" "${ipc} brightness-down")
            {_args = ["SUPER + mouse:272" (lib.generators.mkLuaInline "hl.dsp.window.drag()") {mouse = true;}];}
            {_args = ["SUPER + mouse:273" (lib.generators.mkLuaInline "hl.dsp.window.resize()") {mouse = true;}];}
          ]
          ++ lib.concatMap (number: let
            workspace = toString number;
            key = toString (lib.mod number 10);
          in [
            (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${workspace} })")
            (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${workspace}, follow = false })")
          ]) (lib.range 1 10);
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
  };
}
