{
  flake.modules.nixos.networking = {
    networking = {
      firewall = {
        enable = true;
      };
      networkmanager.enable = true;
    };
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
    services.tailscale.enable = true;
  };
}
