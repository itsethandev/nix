{
  flake.modules.nixos.phone-camera = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.droidcam.enable = lib.mkDefault true;
        services.usbmuxd.enable = lib.mkDefault true;
      }
      (lib.mkIf config.programs.obs-studio.enable {
        programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
          droidcam-obs
        ];
      })
    ];
  };
}
