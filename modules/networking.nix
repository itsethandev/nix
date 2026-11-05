{
  nixos.turing = {lib, ...}: {
    networking = {
      firewall = {
        enable = true;
        interfaces.tailscale0 = {
          allowedTCPPorts = [22 3000 5173 5520 6419 8521 25565 38281];
          allowedUDPPorts = [22 3000 5173 5520 6419 25565 38281];
        };
      };
      networkmanager.enable = true;
    };
    users.users.ethan.extraGroups = lib.mkBefore ["networkmanager"];
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
    services.tailscale.enable = true;
  };
}
