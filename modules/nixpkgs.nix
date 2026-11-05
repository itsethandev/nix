{
  config,
  inputs,
  lib,
  ...
}: {
  systems = ["aarch64-linux" "aarch64-darwin" "x86_64-linux"];

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-desktop";
      overlays = [config.flake.overlays.default];
    };
  };

  flake.overlays.default = lib.composeManyExtensions (builtins.attrValues (builtins.removeAttrs config.flake.overlays ["default"]));
}
