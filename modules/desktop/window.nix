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
    cycleLayout = step: ''
      function()
        local layouts = { "dwindle", "scrolling", "master" }
        local current = hl.get_config("general.layout")
        for index, layout in ipairs(layouts) do
          if layout == current then
            hl.config({ general = { layout = layouts[(index - 1 + ${toString step}) % #layouts + 1] } })
            return
          end
        end
        hl.config({ general = { layout = "dwindle" } })
      end
    '';
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
            (bind "SUPER + O" ''hl.dsp.window.pin({ action = "toggle" })'')
            (bind "SUPER + Y" (cycleLayout 1))
            (bind "SUPER + ALT + Y" (cycleLayout (-1)))
            (bind "SUPER + H" ''hl.dsp.focus({ direction = "left" })'')
            (bind "SUPER + J" ''hl.dsp.focus({ direction = "down" })'')
            (bind "SUPER + K" ''hl.dsp.focus({ direction = "up" })'')
            (bind "SUPER + L" ''hl.dsp.focus({ direction = "right" })'')
            (bind "SUPER + SHIFT + H" ''hl.dsp.window.swap({ direction = "left" })'')
            (bind "SUPER + SHIFT + J" ''hl.dsp.window.swap({ direction = "down" })'')
            (bind "SUPER + SHIFT + K" ''hl.dsp.window.swap({ direction = "up" })'')
            (bind "SUPER + SHIFT + L" ''hl.dsp.window.swap({ direction = "right" })'')
            (bind "SUPER + SHIFT + ALT + H" ''hl.dsp.window.move({ monitor = "left", follow = true })'')
            (bind "SUPER + SHIFT + ALT + J" ''hl.dsp.window.move({ monitor = "down", follow = true })'')
            (bind "SUPER + SHIFT + ALT + K" ''hl.dsp.window.move({ monitor = "up", follow = true })'')
            (bind "SUPER + SHIFT + ALT + L" ''hl.dsp.window.move({ monitor = "right", follow = true })'')
            (bind "SUPER + Tab" ''hl.dsp.focus({ monitor = "+1" })'')
            (bind "SUPER + ALT + Tab" ''hl.dsp.focus({ monitor = "-1" })'')
            (bind "SUPER + SHIFT + Tab" ''hl.dsp.window.move({ monitor = "+1", follow = true })'')
            (bind "SUPER + SHIFT + ALT + Tab" ''hl.dsp.window.move({ monitor = "-1", follow = true })'')
            {_args = ["SUPER + mouse:272" (lib.generators.mkLuaInline "hl.dsp.window.drag()") {mouse = true;}];}
            {_args = ["SUPER + mouse:273" (lib.generators.mkLuaInline "hl.dsp.window.resize()") {mouse = true;}];}
          ]
          ++ lib.concatMap (number: let
            workspace = toString number;
            key = toString (lib.mod number 10);
          in [
            (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${workspace} })")
            (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${workspace}, follow = true })")
            (bind "SUPER + SHIFT + ALT + ${key}" "hl.dsp.window.move({ workspace = ${workspace}, follow = false })")
          ]) (lib.range 1 10);
      };
    };
  };
}
