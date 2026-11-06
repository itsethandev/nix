{
  flake.modules.nixos.networking = {
    networking = {
      firewall = {
        enable = true;
      };
      networkmanager.enable = true;
    };
  };
}
