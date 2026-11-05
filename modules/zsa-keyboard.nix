{inputs, ...}: {
  flake.modules.nixos.zsa-keyboard = {lib, ...}: {
    imports = [
      inputs.zapp.nixosModules.default
    ];

    hardware.keyboard.zsa.enable = lib.mkDefault true;
    programs.zapp.enable = lib.mkDefault true;
  };
}
