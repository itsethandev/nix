{
  flake.modules.homeManager.neovim = {
    config,
    lib,
    ...
  }: {
    wayland.windowManager.hyprland.settings.bind = lib.mkIf (config.wayland.windowManager.hyprland.enable && config.programs.ghostty.enable) (lib.mkAfter [
      {
        _args = ["SUPER + SHIFT + N" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.escapeShellArgs [(lib.getExe config.programs.ghostty.package) "-e" (lib.getExe config.programs.nixvim.build.package)])})")];
      }
    ]);
  };
}
