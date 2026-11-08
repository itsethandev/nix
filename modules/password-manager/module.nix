{
  flake.modules.nixos.password-manager.programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };
  flake.modules.homeManager.password-manager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs._1password-gui];
    wayland.windowManager.hyprland.settings.bind = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      {_args = ["SUPER + SHIFT + slash" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.getExe pkgs._1password-gui)})")];}
    ]);
  };
}
