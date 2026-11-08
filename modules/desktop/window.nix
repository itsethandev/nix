{
  flake.modules.homeManager.desktop = {
    lib,
    pkgs,
    ...
  }: let
    bind = chord: dispatcher: {
      _args = [chord (lib.generators.mkLuaInline dispatcher)];
    };
    exec = chord: command: bind chord "hl.dsp.exec_cmd(${lib.generators.toLua {} command})";
    pasteShortcut = pkgs.writeShellScript "paste-shortcut" ''
      if ${lib.getExe' pkgs.wl-clipboard "wl-paste"} --list-types |
        ${lib.getExe pkgs.gnugrep} -q '^image/'; then
        ${lib.getExe' pkgs.hyprland "hyprctl"} dispatch 'hl.dsp.send_shortcut({ mods = "CTRL", key = "V" })'
      else
        ${lib.getExe' pkgs.hyprland "hyprctl"} dispatch 'hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" })'
      fi
    '';
  in {
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
        bind =
          [
            (bind "SUPER + C" ''hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" })'')
            (exec "SUPER + V" "${pasteShortcut}")
            (bind "SUPER + X" ''hl.dsp.send_shortcut({ mods = "CTRL", key = "X" })'')
            (bind "SUPER + A" ''hl.dsp.send_shortcut({ mods = "CTRL", key = "A" })'')
            (bind "SUPER + W" "hl.dsp.window.close()")
            (bind "SUPER + ALT + W" "hl.dsp.window.kill()")
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
            {_args = ["SUPER + mouse:272" (lib.generators.mkLuaInline "hl.dsp.window.drag()") {mouse = true;}];}
            {_args = ["SUPER + mouse:273" (lib.generators.mkLuaInline "hl.dsp.window.resize()") {mouse = true;}];}
          ]
          ++ lib.concatMap (number: let
            workspace = toString number;
            key = toString (lib.mod number 10);
          in [
            (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${workspace} })")
            (bind "SUPER + SHIFT + ALT + ${key}" "hl.dsp.window.move({ workspace = ${workspace}, follow = false })")
          ]) (lib.range 1 10);
      };
    };
  };
}
