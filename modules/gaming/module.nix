{inputs, ...}: {
  flake.modules.nixos.gaming = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = [
      pkgs.gamescope
      pkgs.usbutils
    ];

    hardware = {
      steam-hardware.enable = lib.mkDefault true;
      uinput.enable = lib.mkDefault true;
      xone.enable = lib.mkDefault true;
    };

    programs = {
      gamemode.enable = lib.mkDefault true;
      steam = {
        dedicatedServer.openFirewall = lib.mkDefault true;
        enable = lib.mkDefault true;
        extest.enable = lib.mkDefault false;
        extraPackages = [pkgs.hidapi];
        localNetworkGameTransfers.openFirewall = lib.mkDefault true;
        # The upstream extest option preloads the 32-bit library, but SteamRT3 is 64-bit.
        package = lib.mkDefault (pkgs.steam.override {
          extraEnv.LD_PRELOAD = "${pkgs.extest}/lib/libextest.so";
        });
        remotePlay.openFirewall = lib.mkDefault true;
      };
    };

    services = {
      joycond.enable = lib.mkDefault true;
      udev.packages = [pkgs.game-devices-udev-rules];
    };
  };
  flake.modules.homeManager.gaming = {
    config,
    lib,
    osConfig,
    pkgs,
    ...
  }: let
    steam =
      if osConfig.programs.steam.enable or false
      then osConfig.programs.steam.package
      else pkgs.steam;
    gamingWindowPatterns = [
      "^steam_app_.*$"
      "^(com\\.libretro\\.RetroArch|retroarch)$"
      "^Hollow Knight Silksong$"
      "^Hytale$"
      "^deadcells$"
      "^Minecraft.*$"
      "^MinaTheHollower$"
      "^UltimateChickenHorse.*$"
    ];
    gamingWindowRules = lib.concatMap (pattern:
      map (field: {
        name = "gaming-${field}-${pattern}";
        match.${field} = pattern;
        workspace = "5";
        fullscreen = true;
      }) ["initial_class" "initial_title"])
    gamingWindowPatterns;
  in {
    wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
      bind = lib.mkAfter [{_args = ["SUPER + SHIFT + S" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.getExe steam)})")];}];
      window_rule = lib.mkMerge [
        (lib.mkOrder 1502 [
          {
            name = "steam-workspace";
            match = {
              initial_class = "^steam$";
              initial_title = "negative:^Steam Input On-screen Keyboard$";
            };
            workspace = "5 silent";
          }
          {
            name = "steam-keyboard";
            match = {
              initial_class = "^steam$";
              initial_title = "^Steam Input On-screen Keyboard$";
            };
            workspace = "unset";
            float = true;
            no_focus = true;
            pin = true;
            move = "((monitor_w-window_w)/2) (monitor_h-window_h)";
          }
        ])
        (lib.mkOrder 1504 gamingWindowRules)
      ];
    };
    home.packages = [steam pkgs.archipelago inputs.barnyard.packages.${pkgs.stdenv.hostPlatform.system}.barnyard];
    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
      settings = {
        display_server = true;
        fan = true;
        frametime = true;
        gamemode = true;
        gpu_fan = true;
        gpu_temp = true;
        no_display = true;
        ram = true;
        toggle_hud = "Super_L+Control_L+H";
        vram = true;
        wine = true;
      };
    };
  };
}
