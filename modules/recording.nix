{
  nixos.turing.programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
  home.turing = {
    config,
    lib,
    ...
  }: {
    wayland.windowManager.hyprland.settings.window_rule = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkOrder 1503 [
      {
        name = "obs-projector";
        match.initial_title = "^Projector.*$";
        workspace = "special:presentation silent";
        fullscreen = true;
      }
    ]);
    xdg.desktopEntries.toggle-projector = lib.mkIf config.wayland.windowManager.hyprland.enable {
      name = "Show or Hide Projector";
      comment = "Toggle the projector special workspace";
      exec = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch \"hl.dsp.workspace.toggle_special('presentation')\"";
      terminal = false;
      startupNotify = false;
      categories = ["Utility"];
      settings.Keywords = "projector;presentation;OBS;workspace;";
    };
  };
}
