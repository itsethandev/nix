{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  inherit (lib) mkOption types;
  root = ../.;
  roots = [../modules ../hosts ../shells];
  # Git does not track empty directories; they are not consumable folders.
  folders = directory:
    builtins.filter (path: lib.filesystem.listFilesRecursive path != [])
    (map (name: directory + "/${name}")
      (builtins.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir directory))));
  features = folders ../modules;
  hosts = folders ../hosts;
  shells = folders ../shells;
  label = path: lib.removePrefix "${toString root}/" (toString path);
  require = condition: message:
    if condition
    then true
    else throw "Architecture check: ${message}";
  all = lib.all (result: result);
  forceValues = attrs: lib.all (value: builtins.seq value true) (builtins.attrValues attrs);
  attrsOption = type:
    mkOption {
      type = types.lazyAttrsOf type;
      default = {};
    };

  # Use the same deferred-module declarations as the deployment plumbing.
  deploymentOptions = (import ./configurations.nix {inherit inputs lib;}).options;
  perSystemOption = mkOption {
    type = types.deferredModule;
    default = {};
  };
  featureOptions = {
    flake = mkOption {
      default = {};
      type = types.submodule {
        options = {
          modules = attrsOption (types.lazyAttrsOf types.deferredModule);
          overlays = attrsOption (types.functionTo (types.functionTo (types.lazyAttrsOf types.unspecified)));
        };
      };
    };
    perSystem = perSystemOption;
  };
  hostOptions =
    deploymentOptions
    // {
      flake = mkOption {
        default = {};
        type = types.submodule {
          options = {
            nixosConfigurations = attrsOption types.raw;
            darwinConfigurations = attrsOption types.raw;
          };
        };
      };
    };
  shellOptions.perSystem = perSystemOption;

  evaluate = options: path: let
    evaluated =
      (lib.evalModules {
        class = "flake";
        specialArgs = {
          inherit inputs withSystem;
          self = inputs.self;
        };
        modules = [
          {inherit options;}
          (inputs.import-tree path)
        ];
      }).config;
  in
    assert require (lib.all (name: builtins.hasAttr name options) (builtins.attrNames evaluated))
    "${label path} declares an output outside its allowed namespaces"; evaluated;
  evaluateSystem = namespace: module: system: let
    evaluated =
      (lib.evalModules {
        class = "perSystem";
        specialArgs = {
          inherit system;
          pkgs = withSystem system ({pkgs, ...}: pkgs);
        };
        modules = [
          {options.${namespace} = attrsOption types.package;}
          module
        ];
      }).config;
  in
    assert require (builtins.attrNames evaluated == [namespace])
    "perSystem.${system} declares an output outside ${namespace}";
      evaluated.${namespace};
  forceDerivations = attrs:
    lib.all (value: builtins.isString value.drvPath) (builtins.attrValues attrs);

  checkFeature = path: let
    evaluated = evaluate featureOptions path;
    exports = evaluated.flake.modules;
    classes = builtins.attrNames exports;
    packages = map (evaluateSystem "packages" evaluated.perSystem) config.systems;
  in
    builtins.addErrorContext "while checking feature ${label path}" (all [
      (require (lib.all (name: builtins.elem name ["modules" "overlays"]) (builtins.attrNames evaluated.flake))
        "${label path} declares a flake output outside modules and overlays")
      (require (lib.all (class: builtins.elem class ["nixos" "darwin" "homeManager"]) classes)
        "${label path} exports an unsupported module class")
      (require (lib.any (modules: modules != {}) (builtins.attrValues exports))
        "${label path} must export at least one flake.modules.<class>.<name> module")
      (lib.all forceValues (builtins.attrValues exports))
      (forceValues evaluated.flake.overlays)
      (lib.all forceDerivations packages)
    ]);
  checkHost = path: let
    evaluated = evaluate hostOptions path;
    nixos = builtins.attrNames evaluated.flake.nixosConfigurations;
    darwin = builtins.attrNames evaluated.flake.darwinConfigurations;
    deployments = nixos ++ darwin;
    sameNames = left: right: lib.sort builtins.lessThan left == lib.sort builtins.lessThan right;
    isDeployment = value: builtins.isAttrs value && value ? config && value ? options;
  in
    builtins.addErrorContext "while checking host ${label path}" (all [
      (require (lib.all (name: builtins.elem name ["nixosConfigurations" "darwinConfigurations"]) (builtins.attrNames evaluated.flake))
        "${label path} declares a flake output outside deployment configurations")
      (require (deployments != []) "${label path} must export a NixOS or Darwin deployment")
      (require (sameNames nixos (builtins.attrNames evaluated.nixos))
        "${label path} must pair its nixos fragments with its NixOS deployments")
      (require (sameNames darwin (builtins.attrNames evaluated.darwin))
        "${label path} must pair its darwin fragments with its Darwin deployments")
      (require (lib.all (name: builtins.elem name deployments) (builtins.attrNames evaluated.home))
        "${label path} has a home fragment without a deployment in this folder")
      (require (lib.all isDeployment (builtins.attrValues evaluated.flake.nixosConfigurations ++ builtins.attrValues evaluated.flake.darwinConfigurations))
        "${label path} deployment outputs must be evaluated system module results")
      (lib.all forceValues [evaluated.nixos evaluated.darwin evaluated.home])
    ]);
  checkShell = path: let
    evaluated = evaluate shellOptions path;
    outputs = map (evaluateSystem "devShells" evaluated.perSystem) config.systems;
  in
    builtins.addErrorContext "while checking shell ${label path}" (all [
      (require (lib.any (shells: shells != {}) outputs)
        "${label path} must define at least one perSystem.devShells output")
      (lib.all forceDerivations outputs)
    ]);

  nixFiles =
    [../flake.nix]
    ++ lib.concatMap
    (directory: builtins.filter (path: lib.hasSuffix ".nix" (toString path)) (lib.filesystem.listFilesRecursive directory))
    roots;
  importedFiles = lib.concatMap (directory: inputs.import-tree.leaves directory) roots;
  configurationNames = lib.unique (lib.concatMap
    (lib.splitString "/")
    (map (path: lib.removeSuffix ".nix" (label path)) nixFiles ++ map label (features ++ hosts ++ shells)));
  checkLayout = all (
    map (path:
      require (builtins.pathExists (path + "/module.nix") && builtins.pathExists (path + "/README.md"))
      "${label path} needs module.nix and README.md") (features ++ shells)
    ++ map (path:
      require (builtins.pathExists (path + "/configuration.nix") && builtins.pathExists (path + "/README.md"))
      "${label path} needs configuration.nix and README.md")
    hosts
    ++ map (name:
      require (builtins.match "[a-z0-9]+(-[a-z0-9]+)*" name != null)
      "configuration path component '${name}' must use lowercase kebab-case")
    configurationNames
    ++ map (path:
      require (path == ../flake.nix || builtins.elem path importedFiles)
      "${label path} is not automatically imported")
    nixFiles
  );
  formattingSource = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.unions nixFiles;
  };
in {
  perSystem = {pkgs, ...}: let
    check = name: result:
      assert result;
        pkgs.runCommand name {} ''
          touch "$out"
        '';
  in {
    checks = {
      architecture-features = check "architecture-features" (lib.all checkFeature features);
      architecture-hosts = check "architecture-hosts" (lib.all checkHost hosts);
      architecture-shells = check "architecture-shells" (lib.all checkShell shells);
      architecture-layout = check "architecture-layout" checkLayout;
      formatting = pkgs.runCommand "nix-formatting" {nativeBuildInputs = [pkgs.alejandra];} ''
        alejandra --check ${formattingSource}
        touch "$out"
      '';
    };
  };
}
