{
  darwinModules,
  home-manager,
  homeManagerModules,
  inputs,
  nixosModules,
  nixpkgs,
  pkgs,
}: let
  inherit (nixpkgs) lib;

  mkNixos = modules:
    lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [nixosModules.default] ++ modules;
    };

  mkDarwin = modules:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs;};
      modules =
        [
          darwinModules.default
          {nixpkgs.hostPlatform = "aarch64-darwin";}
        ]
        ++ modules;
    };

  homeBase = {
    home = {
      username = "test";
      homeDirectory = "/home/test";
      stateVersion = "25.05";
    };
  };

  mkHome = modules:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs;};
      modules = [homeManagerModules.default homeBase] ++ modules;
    };

  disabledNixos = mkNixos [];
  invalidSsh = mkNixos [
    {
      my.remote.ssh = {
        enable = true;
        user = "test";
      };
    }
  ];
  overriddenGaming = mkNixos [
    {
      my.gaming.enable = true;
      programs.steam.enable = false;
    }
  ];

  disabledDarwin = mkDarwin [];
  overriddenAerospace = mkDarwin [
    {
      my.aerospace.enable = true;
      services.aerospace.settings.mode.main.binding."cmd-f" = "layout floating tiling";
    }
  ];

  disabledHome = mkHome [];
  enabledDictation = mkHome [
    {
      my.dictation.enable = true;
      wayland.windowManager.hyprland.enable = true;
    }
  ];
  invalidDictation = mkHome [
    {my.dictation.enable = true;}
  ];
  disabledDictationService = mkHome [
    {
      my.dictation.enable = true;
      wayland.windowManager.hyprland.enable = true;
      programs.hex.enable = false;
    }
  ];
  disabledDictationAutostart = mkHome [
    {
      my.dictation.enable = true;
      wayland.windowManager.hyprland.enable = true;
      programs.hex.autostart = false;
    }
  ];
  overriddenDictation = mkHome [
    {
      my.dictation.enable = true;
      wayland.windowManager.hyprland.enable = true;
      programs.hex.settings.paste_with_shift = false;
    }
  ];
  dictationSettings = enabledDictation.config.programs.hex;
  dictationCommand = lib.getExe dictationSettings.package;
  dictationBindings = enabledDictation.config.wayland.windowManager.hyprland.settings;
  dictationBinding = chord: action: flags: {
    _args = [
      chord
      (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} "${dictationCommand} dictation ${action}"})")
      flags
    ];
  };
  overriddenDevelopment = mkHome [
    {
      my.development = {
        enable = true;
        git = {
          email = "test@example.com";
          name = "Test User";
        };
      };
      programs.nixvim.opts.number = false;
    }
  ];
  overriddenTerminal = mkHome [
    {
      my.terminal.enable = true;
      programs.fish.enable = false;
    }
  ];

  findAssertion = message: assertions:
    lib.findFirst (candidate: candidate.message == message) null assertions;

  sshAssertion =
    findAssertion
    "my.remote.ssh.user and my.remote.ssh.keyDirectory must be set together."
    invalidSsh.config.assertions;
in
  assert !disabledNixos.config.services.openssh.enable;
  assert !disabledNixos.config.programs.steam.enable;
  assert sshAssertion != null && !sshAssertion.assertion;
  assert !overriddenGaming.config.programs.steam.enable;
  assert !disabledDarwin.config.services.aerospace.enable;
  assert overriddenAerospace.config.services.aerospace.settings.mode.main.binding."cmd-f" == "layout floating tiling";
  assert !disabledHome.config.programs.fish.enable;
  assert !disabledHome.config.programs.git.enable;
  assert !disabledHome.config.programs.nixvim.enable;
  assert !disabledHome.config.programs.hex.enable;
  assert !(disabledHome.config.systemd.user.services ? hex);
  assert !(builtins.tryEval invalidDictation.activationPackage.drvPath).success;
  assert !(builtins.tryEval disabledDictationService.activationPackage.drvPath).success;
  assert !(builtins.tryEval disabledDictationAutostart.activationPackage.drvPath).success;
  assert !overriddenDictation.config.programs.hex.settings.paste_with_shift;
  assert dictationSettings.enable;
  assert dictationSettings.autostart;
  assert dictationSettings.installModel;
  assert dictationSettings.model == "parakeet_unified_en";
  assert dictationSettings.language == "en";
  assert dictationSettings.settings.paste_with_shift;
  assert enabledDictation.config.systemd.user.services.hex.Install.WantedBy == ["graphical-session.target"];
  assert enabledDictation.config.systemd.user.services ? hex-model;
  assert builtins.elem (dictationBinding "SUPER + D" "start" {}) dictationBindings.bind;
  assert builtins.elem (dictationBinding "SUPER + SHIFT + D" "toggle" {}) dictationBindings.bind;
  assert builtins.elem (dictationBinding "SUPER + CTRL + D" "cancel" {}) dictationBindings.bind;
  assert builtins.elem (dictationBinding "SUPER + D" "stop" {release = true;}) dictationBindings.bind;
  assert !overriddenDevelopment.config.programs.nixvim.opts.number;
  assert !overriddenTerminal.config.programs.fish.enable;
    pkgs.runCommand "module-contracts" {} ''
      export HEX_APPLICATION_SUPPORT_DIR="$TMPDIR/hex"
      ${dictationCommand} settings apply ${
        (pkgs.formats.json {}).generate "hex-settings.json" {
          "transcription.model" = dictationSettings.model;
          "transcription.language" = dictationSettings.language;
          inherit (dictationSettings.settings) paste_with_shift;
        }
      }
      ${lib.getExe pkgs.jq} -e '
        .transcription.model == "parakeet_unified_en" and
        .transcription.language == "en" and
        .paste_with_shift == true
      ' "$HEX_APPLICATION_SUPPORT_DIR/settings.json"

      touch "$out"
    ''
