{
  flake.modules.homeManager.discord = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.discord];
    wayland.windowManager.hyprland.settings.window_rule = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wayland.windowManager.hyprland.enable) (lib.mkOrder 1501 [
      {
        name = "discord-popout";
        match.initial_title = "^Discord Popout$";
        float = true;
        pin = true;
        size = "(monitor_w*0.25) (monitor_h*0.25)";
        move = "(monitor_w-window_w-48) (monitor_h-window_h-48)";
      }
    ]);
  };
}
