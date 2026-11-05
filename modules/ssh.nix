{
  flake.modules.nixos.ssh = {lib, ...}: {
    services.openssh = {
      enable = lib.mkDefault true;
      openFirewall = false;
      settings.KbdInteractiveAuthentication = lib.mkDefault false;
      settings.PasswordAuthentication = lib.mkDefault false;
    };
  };
}
