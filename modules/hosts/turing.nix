{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.turing = inputs.nixpkgs.lib.nixosSystem {
    modules = [config.nixos.turing];
  };

  nixos.turing = {pkgs, ...}: {
    imports = [inputs.home-manager.nixosModules.home-manager];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.ethan = config.home.turing;
    };

    boot = {
      consoleLogLevel = 3;
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams = ["quiet" "rd.udev.log_level=3" "rd.systemd.show_status=auto"];
      loader = {
        efi.canTouchEfiVariables = true;
        limine = {
          enable = true;
          maxGenerations = 20;
        };
        timeout = 0;
      };
      plymouth.enable = true;
    };
    hardware.bluetooth.enable = true;
    i18n.defaultLocale = "en_US.UTF-8";
    networking.hostName = "turing";
    nixpkgs.config.allowUnfree = true;
    programs.zsh.enable = true;
    security.sudo.wheelNeedsPassword = false;
    system.stateVersion = "25.11";
    time.timeZone = "America/Denver";
    users.users.ethan = {
      isNormalUser = true;
      extraGroups = ["wheel" "input"];
      shell = pkgs.zsh;
    };
  };

  home.turing = {
    home = {
      username = "ethan";
      homeDirectory = "/home/ethan";
      stateVersion = "25.11";
    };
    programs.home-manager.enable = true;
  };
}
