{
  flake.modules.nixos.nix.nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
      randomizedDelaySec = "45min";
    };
    optimise.automatic = true;
    settings.experimental-features = ["flakes" "nix-command"];
  };
  flake.modules.darwin.nix.nix.settings.experimental-features = ["nix-command" "flakes"];
}
