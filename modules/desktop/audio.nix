{
  flake.modules.nixos.desktop = {lib, ...}: {
    security.rtkit.enable = lib.mkDefault true;
    services = {
      pipewire = {
        enable = lib.mkDefault true;
        alsa = {
          enable = lib.mkDefault true;
          support32Bit = lib.mkDefault true;
        };
        jack.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
        wireplumber.extraConfig."default-app-volume"."wireplumber.settings"."node.stream.default-playback-volume" = lib.mkDefault 0.125;
      };
      pulseaudio.enable = lib.mkDefault false;
    };
  };
}
