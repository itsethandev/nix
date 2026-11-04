{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.dictation;
  hex = config.programs.hex.package;
in {
  imports = [inputs.hex.homeManagerModules.hex];

  options.my.dictation.enable = lib.mkEnableOption "local Hex dictation with Hyprland controls";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "my.dictation.enable requires Linux.";
      }
      {
        assertion = config.wayland.windowManager.hyprland.enable;
        message = "my.dictation.enable requires Hyprland.";
      }
      {
        assertion = config.programs.hex.enable;
        message = "my.dictation.enable requires programs.hex.enable.";
      }
      {
        assertion = config.programs.hex.autostart;
        message = "my.dictation.enable requires programs.hex.autostart.";
      }
    ];

    programs.hex = {
      enable = lib.mkDefault true;
      autostart = lib.mkDefault true;
      model = lib.mkDefault "parakeet_unified_en";
      language = lib.mkDefault "en";
      installModel = lib.mkDefault true;
      settings.paste_with_shift = lib.mkDefault true;
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER, D, exec, ${lib.getExe hex} dictation start"
        "SUPER_SHIFT, D, exec, ${lib.getExe hex} dictation toggle"
        "SUPER_CTRL, D, exec, ${lib.getExe hex} dictation cancel"
      ];
      bindr = [
        "SUPER, D, exec, ${lib.getExe hex} dictation stop"
      ];
    };
  };
}
