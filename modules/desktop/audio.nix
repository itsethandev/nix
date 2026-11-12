{
  flake.modules.nixos.desktop = {
    config,
    lib,
    ...
  }: {
    environment.systemPackages = [config.services.pipewire.package.jack];
    security.rtkit.enable = lib.mkDefault true;
    services = {
      pipewire = {
        enable = lib.mkDefault true;
        alsa = {
          enable = lib.mkDefault true;
          support32Bit = lib.mkDefault true;
        };
        pulse.enable = lib.mkDefault true;
        wireplumber.extraConfig."default-app-volume"."wireplumber.settings"."node.stream.default-playback-volume" = lib.mkDefault 0.125;
      };
      pulseaudio.enable = lib.mkDefault false;
    };
  };
}
