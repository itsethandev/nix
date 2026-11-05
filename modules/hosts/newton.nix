{
  config,
  inputs,
  ...
}: {
  flake.darwinConfigurations.newton = inputs.nix-darwin.lib.darwinSystem {
    modules = [config.darwin.newton];
  };

  darwin.newton = {
    imports =
      [inputs.home-manager.darwinModules.home-manager]
      ++ (with config.flake.modules.darwin; [
        appearance
        ghostty
        nix
        terminal
        window-management
      ]);
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
      overlays = [config.flake.overlays.default];
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
    imports = with config.flake.modules.homeManager; [
      bun
      desktop-apps
      development-tools
      diff-review
      git
      neovim
      opencode
      pi
      terminal
    ];
    home = {
      stateVersion = "24.05";
      username = "ethan";
      homeDirectory = "/Users/ethan";
    };
    programs.home-manager.enable = true;
    programs.git.settings.user = {
      email = "newton@itsEthan.dev";
      name = "Ethan Brady";
    };
  };
}
