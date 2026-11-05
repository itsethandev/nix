{
  inputs,
  lib,
  ...
}: {
  disabledModules = map (name: inputs.flake-parts + "/modules/${name}.nix") [
    "apps"
    "checks"
    "formatter"
    "legacyPackages"
    "nixosModules"
  ];
  options = lib.genAttrs ["nixos" "darwin" "home"] (_:
    lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = {};
      description = "Configuration fragments merged by deployment name.";
    });
}
