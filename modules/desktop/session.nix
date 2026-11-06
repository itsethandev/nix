{
  flake.modules.nixos.desktop = {lib, ...}: {
    programs = {
      dconf.enable = lib.mkDefault true;
      hyprland = {
        enable = lib.mkDefault true;
        withUWSM = lib.mkDefault true;
        xwayland.enable = lib.mkDefault true;
      };
      noctalia = {
        enable = lib.mkDefault true;
        recommendedServices.enable = lib.mkDefault true;
      };
    };
  };
  flake.modules.homeManager.desktop.xdg.userDirs = {
    enable = true;
    setSessionVariables = false;
  };
}
