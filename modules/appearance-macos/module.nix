{inputs, ...}: {
  flake.modules.darwin.appearance = {pkgs, ...}: {
    imports = [inputs.stylix.darwinModules.stylix];
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-soft.yaml";
      fonts.sizes.terminal = 16;
    };
  };
}
