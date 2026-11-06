{inputs, ...}: let
  noctaliaFor = pkgs:
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or []) ++ [../../static/noctalia-enter-to-unlock.patch];
    });
in {
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    imports = [inputs.noctalia.homeModules.default];
    programs.noctalia.package = noctaliaFor pkgs;
  };
  flake.modules.nixos.desktop = {pkgs, ...}: {
    imports = [
      inputs.noctalia.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
    nixpkgs.overlays = [
      (_final: _prev: {
        noctalia = noctaliaFor pkgs;
      })
    ];
    programs.noctalia.package = pkgs.noctalia;
  };
}
