{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.turing = inputs.nixpkgs.lib.nixosSystem {
    modules = [config.nixos.turing];
  };

  nixos.turing = {
    lib,
    pkgs,
    ...
  }: {
    imports =
      [inputs.home-manager.nixosModules.home-manager]
      ++ (with config.flake.modules.nixos; [
        backups
        containers
        desktop
        file-sharing
        gaming
        linux-app-compatibility
        networking
        nix
        password-manager
        phone-camera
        recording
        ssh
        steam-frame
        zsa-keyboard
      ]);
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
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [config.flake.overlays.default];
    };
    fileSharing.user = "ethan";
    steamFrame = {
      countryCode = "US";
      adapterMacAddress = "9C:04:B6:88:D5:B9";
    };
    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [22 3000 5173 5520 6419 8521 25565 38281 445];
      allowedUDPPorts = [22 3000 5173 5520 6419 25565 38281];
    };
    services.greetd.settings.initial_session = {
      user = "ethan";
      command = "${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop";
    };
    services.restic.backups.r2 = {
      repository = "s3:https://7be572932f308ef922603015d775fdd2.r2.cloudflarestorage.com/backup/turing";
      environmentFile = "/etc/restic/r2.env";
      passwordFile = "/etc/restic/password";
      paths = ["/home/ethan/Pictures/Screenshots" "/home/ethan/Documents"];
      exclude = [];
      extraOptions = ["s3.bucket-lookup=path"];
    };
    programs.zsh.enable = true;
    security.sudo.wheelNeedsPassword = false;
    system.stateVersion = "25.11";
    time.timeZone = "America/Denver";
    users.users.ethan = {
      isNormalUser = true;
      extraGroups = ["networkmanager" "gamemode" "docker" "wheel" "input"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = let
        directory = ../../../static/ssh;
        entries = builtins.readDir directory;
      in
        map (file: "${directory}/${file}") (builtins.filter
          (file: entries.${file} == "regular" && lib.hasSuffix ".pub" file)
          (builtins.attrNames entries));
    };
  };

  home.turing = {
    imports = with config.flake.modules.homeManager; [
      browser
      bun
      claude-desktop
      cursor-zoom
      desktop-apps
      desktop-files
      desktop
      development-tools
      dictation
      diff-review
      gaming
      ghostty
      git
      music
      neovim
      opencode
      pi
      recording
      terminal
      transcription
      vite-plus
    ];
    home = {
      username = "ethan";
      homeDirectory = "/home/ethan";
      stateVersion = "25.11";
    };
    programs.home-manager.enable = true;
    programs.git.settings.user = {
      email = "turing@itsEthan.dev";
      name = "Ethan Brady";
    };
    programs.fish = {
      shellAliases.pi = "nix develop ~/.config/nix#pi --command pi";
      shellAbbrs.pic = "pi -e npm:@agent-sh/computer-use-linux";
    };
  };
}
