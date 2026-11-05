{
  flake.modules.nixos.password-manager.programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };
}
