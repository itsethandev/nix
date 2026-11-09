{inputs, ...}: {
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    imports = [inputs.noctalia.homeModules.default];
    programs.noctalia.package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  flake.modules.nixos.desktop = {pkgs, ...}: {
    imports = [
      inputs.noctalia.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
    programs.noctalia.package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
