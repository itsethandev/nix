{
  flake.modules.nixos.linux-app-compatibility = {
    config,
    lib,
    pkgs,
    ...
  }: {
    services.flatpak.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = lib.mkIf (!config.programs.hyprland.enable) [pkgs.xdg-desktop-portal-gtk];
    };
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [icu stdenv.cc.cc.lib fontconfig libx11 libice libsm];
    };
  };
}
