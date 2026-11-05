{
  nixos.turing = {lib, ...}: {
    virtualisation.docker.enable = true;
    users.users.ethan.extraGroups = lib.mkBefore ["docker"];
  };
}
