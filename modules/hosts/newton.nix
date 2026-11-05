{
  config,
  inputs,
  ...
}: {
  flake.darwinConfigurations.newton = inputs.nix-darwin.lib.darwinSystem {
    modules = [config.darwin.newton];
  };

  darwin.newton = {
    imports = [inputs.home-manager.darwinModules.home-manager];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.ethan = config.home.newton;
    };

    networking = {
      computerName = "newton";
      hostName = "newton";
      localHostName = "newton";
    };

    nixpkgs = {
      config.allowUnfree = true;
      hostPlatform = "aarch64-darwin";
    };

    security.pam.services.sudo_local = {
      touchIdAuth = true;
      watchIdAuth = true;
    };

    users.users.ethan.home = "/Users/ethan";

    system = {
      defaults = {
        ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;
        NSGlobalDomain = {
          AppleInterfaceStyleSwitchesAutomatically = true;
          AppleShowAllExtensions = true;
          AppleICUForce24HourTime = true;
          AppleMeasurementUnits = "Centimeters";
          AppleTemperatureUnit = "Celsius";
          AppleMetricUnits = 1;
        };
        WindowManager = {
          EnableTilingByEdgeDrag = false;
          EnableTilingOptionAccelerator = false;
          EnableTopTilingByEdgeDrag = false;
        };
        controlcenter.BatteryShowPercentage = false;
        dock = {
          autohide = true;
          orientation = "right";
        };
        finder = {
          AppleShowAllExtensions = true;
          FXPreferredViewStyle = "Nlsv";
          FXRemoveOldTrashItems = true;
          ShowPathbar = true;
        };
      };

      primaryUser = "ethan";
      stateVersion = 5;
    };
  };
  home.newton = {
    home = {
      stateVersion = "24.05";
      username = "ethan";
      homeDirectory = "/Users/ethan";
    };
    programs.home-manager.enable = true;
  };
}
