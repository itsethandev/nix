{
  flake.modules.homeManager.browser = {
    config,
    lib,
    ...
  }: let
    launch = chord: args: {
      _args = [chord (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.escapeShellArgs ([(lib.getExe config.programs.zen-browser.package)] ++ args))})")];
    };
  in {
    wayland.windowManager.hyprland.settings.bind = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      (launch "SUPER + SHIFT + B" ["--new-window"])
      (launch "SUPER + SHIFT + ALT + B" ["--private-window"])
    ]);
  };
}
